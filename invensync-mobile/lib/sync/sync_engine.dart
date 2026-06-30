import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/database/app_database.dart';
import '../data/datasources/remote/api_client.dart';
import 'conflict_resolver.dart';
import 'connectivity_service.dart';

enum SyncEventType {
  syncStart,
  syncProgress,
  syncComplete,
  syncError,
  itemSynced,
  itemFailed,
  itemConflict,
  deltaSyncStart,
  deltaSyncComplete,
  bootstrapStart,
  bootstrapProgress,
  bootstrapComplete,
}

class SyncEvent {
  final SyncEventType type;
  final String? entity;
  final String? details;
  final DateTime timestamp;
  final int? completed;
  final int? total;

  const SyncEvent({
    required this.type,
    this.entity,
    this.details,
    DateTime? timestamp,
    this.completed,
    this.total,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SyncStatus {
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final int pendingCount;
  final int failedCount;
  final int conflictCount;
  final Map<String, int> pendingByEntity;
  final List<SyncEvent> recentEvents;
  final bool isBootstrapping;
  final double bootstrapProgress;

  const SyncStatus({
    this.isSyncing = false,
    this.lastSyncedAt,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.conflictCount = 0,
    this.pendingByEntity = const {},
    this.recentEvents = const [],
    this.isBootstrapping = false,
    this.bootstrapProgress = 0,
  });
}

const _entityEndpoints = <String, String>{
  'products': '/api/products',
  'categories': '/api/product-types',
  'customers': '/api/customers',
  'suppliers': '/api/suppliers',
  'sales': '/api/sales',
  'saleItems': '/api/sales',
  'stockMovements': '/api/inventory',
  'debts': '/api/debts',
  'expenses': '/api/expenses',
  'purchaseOrders': '/api/purchase-orders',
  'serviceBookings': '/api/service-bookings',
  'serviceTypes': '/api/service-types',
  'shops': '/api/shops',
};

const _backoffDelays = [2000, 8000, 30000, 120000, 600000];
const _maxRetries = 5;

class SyncEngine {
  final AppDatabase _db;
  final ApiClient _api;
  final ConnectivityService _connectivity;
  final _uuid = const Uuid();

  final _statusController = StreamController<SyncStatus>.broadcast();
  final _eventController = StreamController<SyncEvent>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<SyncEvent> get eventStream => _eventController.stream;

  Timer? _pushTimer;
  Timer? _pullTimer;
  bool _isPushing = false;
  bool _isPulling = false;

  SyncStatus _currentStatus = const SyncStatus();
  final List<SyncEvent> _recentEvents = [];

  SyncEngine(this._db, this._api, this._connectivity);

  void start() {
    _connectivity.stream.listen((state) {
      if (state.isConnected) {
        pushOutbox();
        pullDelta();
      }
    });

    _pushTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_connectivity.state.isConnected && !_isPushing) {
        pushOutbox();
      }
    });

    _pullTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_connectivity.state.isConnected && !_isPulling) {
        pullDelta();
      }
    });

    _updateStatus();
  }

  void stop() {
    _pushTimer?.cancel();
    _pullTimer?.cancel();
  }

  // ==================== OUTBOX (PUSH) ====================

  /// Queue a mutation for later sync.
  Future<String> queueMutation({
    required String entity,
    required String operation,
    required Map<String, dynamic> payload,
    String? localId,
    String? serverId,
  }) async {
    final id = _uuid.v4();
    await _db.outbox.insertOne(
      OutboxCompanion.insert(
        id: Value(id),
        entity: Value(entity),
        operation: Value(operation),
        payload: Value(jsonEncode(payload)),
        localId: Value(localId),
        serverId: Value(serverId),
        createdAt: Value(DateTime.now().toIso8601String()),
        retryCount: const Value(0),
        status: const Value('pending'),
      ),
    );

    _emitEvent(SyncEvent(
      type: SyncEventType.itemSynced,
      entity: entity,
      details: 'Queued $operation on $entity',
    ));
    _updateStatus();

    if (_connectivity.state.isConnected) {
      pushOutbox();
    }

    return id;
  }

  /// Process all pending outbox items.
  Future<void> pushOutbox() async {
    if (_isPushing) return;
    _isPushing = true;
    _emitEvent(const SyncEvent(type: SyncEventType.syncStart));

    try {
      while (true) {
        final items = await _db.outbox
            .select()
            .where((t) => t.status.equals('pending'))
            .get();
        if (items.isEmpty) break;

        for (final item in items) {
          if (!_connectivity.state.isConnected) break;
          if (!_isReadyForRetry(item)) continue;

          await _processOutboxItem(item);
        }
        break;
      }
    } finally {
      _isPushing = false;
      _emitEvent(const SyncEvent(type: SyncEventType.syncComplete));
      _updateStatus();
    }
  }

  Future<void> _processOutboxItem(Outbox item) async {
    await _db.outbox.update().replace(
          item.copyWith(
            status: const Value('syncing'),
            lastAttemptAt: Value(DateTime.now().toIso8601String()),
          ),
        );

    try {
      final endpoint =
          _entityEndpoints[item.entity] ?? '/api/${item.entity}';
      final payload = jsonDecode(item.payload) as Map<String, dynamic>;
      String path = endpoint;

      if (item.serverId != null && item.operation != 'create') {
        path = '$endpoint/${item.serverId}';
      }

      final method = _methodForOperation(item.operation);

      await _api.pushOutboxItem(
        method: method,
        path: path,
        data: item.operation == 'delete' ? null : payload,
      );

      await _db.outbox.update().replace(
            item.copyWith(
              status: const Value('synced'),
              retryCount: Value(item.retryCount + 1),
            ),
          );

      _emitEvent(SyncEvent(
        type: SyncEventType.itemSynced,
        entity: item.entity,
        details: 'Synced ${item.operation} on ${item.entity}',
      ));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        await _handleConflict(item, e.response?.data);
      } else {
        final newRetryCount = item.retryCount + 1;
        if (newRetryCount >= _maxRetries) {
          await _db.outbox.update().replace(
                item.copyWith(
                  status: const Value('failed'),
                  retryCount: Value(newRetryCount),
                  error: Value(e.message),
                ),
              );
          _emitEvent(SyncEvent(
            type: SyncEventType.itemFailed,
            entity: item.entity,
            details: 'Failed after $_maxRetries retries: ${e.message}',
          ));
        } else {
          await _db.outbox.update().replace(
                item.copyWith(
                  status: const Value('pending'),
                  retryCount: Value(newRetryCount),
                  error: Value(e.message),
                ),
              );
        }
      }
    } catch (e) {
      final newRetryCount = item.retryCount + 1;
      await _db.outbox.update().replace(
            item.copyWith(
              status: newRetryCount >= _maxRetries
                  ? const Value('failed')
                  : const Value('pending'),
              retryCount: Value(newRetryCount),
              error: Value(e.toString()),
            ),
          );
    }
  }

  Future<void> _handleConflict(Outbox item, dynamic serverData) async {
    final localData = jsonDecode(item.payload) as Map<String, dynamic>;
    final serverMap =
        serverData is Map<String, dynamic> ? serverData : <String, dynamic>{};

    final conflict = ConflictInfo(
      entity: item.entity,
      localId: item.localId ?? item.id,
      serverId: item.serverId,
      operation: item.operation,
      localData: localData,
      serverData: serverMap,
      localUpdatedAt: item.createdAt,
      serverUpdatedAt:
          (serverMap['updatedAt'] as String?) ?? item.createdAt,
      conflictingFields: findConflictingFields(localData, serverMap),
    );

    final resolution = resolveConflict(conflict);

    if (resolution.resolvedData == null) {
      await _db.outbox.update().replace(
            item.copyWith(status: const Value('conflict')),
          );
      _emitEvent(SyncEvent(
        type: SyncEventType.itemConflict,
        entity: item.entity,
        details: 'Manual resolution needed',
      ));
    } else if (resolution.winner == ConflictWinner.server) {
      await _db.outbox.update().replace(
            item.copyWith(status: const Value('synced')),
          );
      await _updateLocalEntity(item.entity, resolution.resolvedData!);
    } else {
      await _db.outbox.update().replace(
            item.copyWith(
              status: const Value('pending'),
              payload: Value(jsonEncode(resolution.resolvedData)),
            ),
          );
    }
  }

  Future<void> _updateLocalEntity(
    String entity,
    Map<String, dynamic> data,
  ) async {
    try {
      switch (entity) {
        case 'products':
          await _db.products.insertOnConflictUpdate(
            ProductsCompanion(
              id: Value(data['id'] as String),
              organizationId:
                  Value(data['organizationId'] as String? ?? ''),
              productTypeId: Value(data['productTypeId'] as String?),
              shopId: Value(data['shopId'] as String?),
              sku: Value(data['sku'] as String?),
              name: Value(data['name'] as String? ?? ''),
              description: Value(data['description'] as String?),
              imageUrl: Value(data['imageUrl'] as String?),
              quantity:
                  Value((data['quantity'] as num?)?.toDouble() ?? 0),
              costPrice:
                  Value((data['costPrice'] as num?)?.toDouble() ?? 0),
              sellingPrice:
                  Value((data['sellingPrice'] as num?)?.toDouble() ?? 0),
              lowStockThreshold: Value(
                  (data['lowStockThreshold'] as num?)?.toDouble() ?? 0),
              isActive: Value(data['isActive'] as bool? ?? true),
              createdAt: Value(data['createdAt'] as String? ??
                  DateTime.now().toIso8601String()),
              updatedAt: Value(data['updatedAt'] as String? ??
                  DateTime.now().toIso8601String()),
            ),
          );
          break;
        case 'sales':
          await _db.sales.insertOnConflictUpdate(
            SalesCompanion(
              id: Value(data['id'] as String),
              organizationId:
                  Value(data['organizationId'] as String? ?? ''),
              shopId: Value(data['shopId'] as String?),
              customerId: Value(data['customerId'] as String?),
              invoiceNumber:
                  Value(data['invoiceNumber'] as String? ?? ''),
              status: Value(data['status'] as String? ?? 'completed'),
              paymentMethod:
                  Value(data['paymentMethod'] as String? ?? 'cash'),
              subtotal:
                  Value((data['subtotal'] as num?)?.toDouble() ?? 0),
              discount:
                  Value((data['discount'] as num?)?.toDouble() ?? 0),
              tax: Value((data['tax'] as num?)?.toDouble() ?? 0),
              total: Value((data['total'] as num?)?.toDouble() ?? 0),
              amountPaid:
                  Value((data['amountPaid'] as num?)?.toDouble() ?? 0),
              notes: Value(data['notes'] as String?),
              saleDate: Value(data['saleDate'] as String? ??
                  DateTime.now().toIso8601String()),
              createdAt: Value(data['createdAt'] as String? ??
                  DateTime.now().toIso8601String()),
              updatedAt: Value(data['updatedAt'] as String? ??
                  DateTime.now().toIso8601String()),
            ),
          );
          break;
        case 'debts':
          await _db.debts.insertOnConflictUpdate(
            DebtsCompanion(
              id: Value(data['id'] as String),
              organizationId:
                  Value(data['organizationId'] as String? ?? ''),
              shopId: Value(data['shopId'] as String?),
              customerId: Value(data['customerId'] as String?),
              supplierId: Value(data['supplierId'] as String?),
              type: Value(data['type'] as String? ?? ''),
              amount:
                  Value((data['amount'] as num?)?.toDouble() ?? 0),
              paidAmount: Value(
                  (data['paidAmount'] as num?)?.toDouble() ?? 0),
              dueDate: Value(data['dueDate'] as String?),
              status: Value(data['status'] as String? ?? ''),
              description: Value(data['description'] as String?),
              createdAt: Value(data['createdAt'] as String? ??
                  DateTime.now().toIso8601String()),
              updatedAt: Value(data['updatedAt'] as String? ??
                  DateTime.now().toIso8601String()),
            ),
          );
          break;
      }
    } catch (e) {
      debugPrint(
          '[SyncEngine] Failed to update local entity $entity: $e');
    }
  }

  // ==================== DELTA PULL ====================

  Future<void> pullDelta() async {
    if (_isPulling) return;
    _isPulling = true;
    _emitEvent(const SyncEvent(type: SyncEventType.deltaSyncStart));

    try {
      final metaEntries = await _db.syncMeta.select().get();

      for (final meta in metaEntries) {
        if (!_connectivity.state.isConnected) break;

        final entity = meta.id;
        final lastSynced = meta.lastSyncedAt;
        final endpoint = _entityEndpoints[entity];
        if (endpoint == null) continue;

        try {
          final result = await _api.getDelta(
            entity: entity,
            updatedSince: lastSynced,
          );

          final items = result['data'] as List<dynamic>? ?? [];

          for (final item in items) {
            await _updateLocalEntity(
                entity, item as Map<String, dynamic>);
          }

          await _db.syncMeta.update().replace(
                SyncMetaCompanion(
                  id: Value(meta.id),
                  lastSyncedAt:
                      Value(DateTime.now().toIso8601String()),
                  lastSyncToken:
                      Value(result['nextCursor'] as String?),
                  entityCount:
                      Value(items.length + (meta.entityCount)),
                ),
              );
        } catch (e) {
          debugPrint(
              '[SyncEngine] Delta pull failed for $entity: $e');
        }
      }
    } finally {
      _isPulling = false;
      _emitEvent(const SyncEvent(type: SyncEventType.deltaSyncComplete));
      _updateStatus();
    }
  }

  // ==================== BOOTSTRAP ====================

  Future<void> bootstrap({
    required String orgId,
    String? shopId,
  }) async {
    _emitEvent(const SyncEvent(type: SyncEventType.bootstrapStart));

    try {
      final data = await _api.bootstrapData(
        orgId: orgId,
        shopId: shopId,
      );

      final totalEntities = data.length;
      var completed = 0;

      for (final entry in data.entries) {
        final entity = entry.key;
        final items = entry.value;

        for (final item in items) {
          await _updateLocalEntity(
              entity, item as Map<String, dynamic>);
        }

        final existing = await _db.syncMeta
            .select()
            .where((t) => t.id.equals(entity))
            .getSingleOrNull();
        if (existing != null) {
          await _db.syncMeta.update().replace(
                SyncMetaCompanion(
                  id: Value(entity),
                  lastSyncedAt:
                      Value(DateTime.now().toIso8601String()),
                  entityCount: Value(items.length),
                  lastFullSyncAt:
                      Value(DateTime.now().toIso8601String()),
                ),
              );
        } else {
          await _db.syncMeta.insertOnConflictUpdate(
                SyncMetaCompanion.insert(
                  id: entity,
                  lastSyncedAt:
                      DateTime.now().toIso8601String(),
                  entityCount: items.length,
                  lastFullSyncAt:
                      DateTime.now().toIso8601String(),
                ),
              );
        }

        completed++;
        _emitEvent(SyncEvent(
          type: SyncEventType.bootstrapProgress,
          entity: entity,
          completed: completed,
          total: totalEntities,
          details: 'Loaded ${items.length} $entity',
        ));
      }

      _emitEvent(const SyncEvent(type: SyncEventType.bootstrapComplete));
    } catch (e) {
      _emitEvent(SyncEvent(
        type: SyncEventType.syncError,
        details: 'Bootstrap failed: $e',
      ));
      rethrow;
    }
  }

  // ==================== HELPERS ====================

  bool _isReadyForRetry(Outbox item) {
    if (item.retryCount == 0) return true;
    if (item.lastAttemptAt == null) return true;
    final delay = _getBackoffDelay(item.retryCount);
    final elapsed = DateTime.now()
        .difference(DateTime.parse(item.lastAttemptAt!))
        .inMilliseconds;
    return elapsed >= delay;
  }

  int _getBackoffDelay(int retryCount) {
    final index =
        (retryCount - 1).clamp(0, _backoffDelays.length - 1);
    return _backoffDelays[index];
  }

  String _methodForOperation(String operation) {
    switch (operation) {
      case 'create':
        return 'POST';
      case 'update':
        return 'PUT';
      case 'delete':
        return 'DELETE';
      default:
        return 'POST';
    }
  }

  void _emitEvent(SyncEvent event) {
    _recentEvents.insert(0, event);
    if (_recentEvents.length > 50) {
      _recentEvents.removeRange(50, _recentEvents.length);
    }
    _eventController.add(event);
    _updateStatus();
  }

  Future<void> _updateStatus() async {
    final pending = await _db.outbox
        .select()
        .where((t) => t.status.equals('pending'))
        .get();
    final failed = await _db.outbox
        .select()
        .where((t) => t.status.equals('failed'))
        .get();
    final conflicts = await _db.outbox
        .select()
        .where((t) => t.status.equals('conflict'))
        .get();

    final pendingByEntity = <String, int>{};
    for (final item in pending) {
      pendingByEntity[item.entity] =
          (pendingByEntity[item.entity] ?? 0) + 1;
    }

    _currentStatus = SyncStatus(
      isSyncing: _isPushing || _isPulling,
      lastSyncedAt: _currentStatus.lastSyncedAt,
      pendingCount: pending.length,
      failedCount: failed.length,
      conflictCount: conflicts.length,
      pendingByEntity: pendingByEntity,
      recentEvents: List.unmodifiable(_recentEvents.take(20)),
    );
    _statusController.add(_currentStatus);
  }

  void dispose() {
    stop();
    _statusController.close();
    _eventController.close();
  }
}