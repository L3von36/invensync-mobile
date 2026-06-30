import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../db/database.dart';
import '../api/api_client.dart';
import '../models/product.dart' as models;
import '../models/sale.dart' as models;
import '../models/customer.dart' as models;

export '../sync/sync_engine.dart' show SyncStatus, ConflictStrategy;

enum SyncStatus { idle, bootstrapping, syncing, pushing, error }

enum ConflictStrategy {
  lastWriteWins,
  serverWins,
  clientWins,
  deltaMerge,
  manual
}

class SyncEngine {
  final AppDatabase _db;
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  SyncEngine(this._db, this._apiClient);

  final _statusController = StreamController<SyncStatus>.broadcast();
  final _progressController = StreamController<double>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<double> get progressStream => _progressController.stream;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  static const Map<String, ConflictStrategy> _strategies = {
    'products': ConflictStrategy.deltaMerge,
    'sales': ConflictStrategy.lastWriteWins,
    'debts': ConflictStrategy.deltaMerge,
    'customers': ConflictStrategy.lastWriteWins,
    'suppliers': ConflictStrategy.lastWriteWins,
  };

  void _setStatus(SyncStatus s) {
    _status = s;
    _statusController.add(s);
  }

  void _setProgress(double p) => _progressController.add(p);

  Future<void> bootstrap(String organizationId) async {
    _setStatus(SyncStatus.bootstrapping);
    _logger.i('Bootstrap for org: $organizationId');

    try {
      final fns = [
        _bootstrapEntity('products', 'products'),
        _bootstrapEntity('customers', 'customers'),
        _bootstrapEntity('sales', 'sales'),
      ];

      int done = 0;
      for (final fn in fns) {
        await fn(organizationId);
        done++;
        _setProgress(done / fns.length);
      }

      final now = DateTime.now().toUtc().toIso8601String();
      for (final e in ['products', 'customers', 'sales']) {
        await _db.upsertSyncMeta(e, now);
      }

      _setStatus(SyncStatus.idle);
    } catch (e) {
      _logger.e('Bootstrap failed: $e');
      _setStatus(SyncStatus.error);
      rethrow;
    }
  }

  Future<void> Function(String) _bootstrapEntity(String api, String name) {
    return (String orgId) async {
      int page = 1;
      while (true) {
        try {
          final r = await _apiClient.get('/api/$api', queryParameters: {
            'limit': AppConfig.bootstrapPageSize,
            'page': page,
          });
          final data = r.data as Map<String, dynamic>;
          final items = data['data'] as List<dynamic>? ?? [];
          if (items.isEmpty) break;
          await _writeToDb(name, items);
          final pag = data['pagination'] as Map<String, dynamic>? ?? {};
          if (page >= (pag['totalPages'] as int? ?? page)) break;
          page++;
        } on DioException catch (e) {
          if (e.error == 'OFFLINE') break;
          rethrow;
        }
      }
    };
  }

  Future<void> _writeToDb(String entity, List<dynamic> items) async {
    switch (entity) {
      case 'products':
        final list = items.map((e) {
          final p = models.Product.fromJson(e as Map<String, dynamic>);
          return ProductsCompanion.insert(
            id: p.id, productTypeId: p.productTypeId,
            organizationId: p.organizationId,
            shopId: Value(p.shopId), sku: Value(p.sku),
            name: p.name, description: Value(p.description),
            imageUrl: Value(p.imageUrl), quantity: p.quantity,
            costPrice: p.costPrice, sellingPrice: p.sellingPrice,
            lowStockThreshold: Value(p.lowStockThreshold),
            isActive: Value(p.isActive),
            createdAt: p.createdAt, updatedAt: p.updatedAt,
          );
        }).toList();
        await _db.bulkInsertProducts(list);

      case 'customers':
        final list = items.map((e) {
          final c = models.Customer.fromJson(e as Map<String, dynamic>);
          return CustomersCompanion.insert(
            id: c.id, organizationId: c.organizationId,
            name: c.name, email: Value(c.email),
            phone: Value(c.phone), address: Value(c.address),
            shopId: Value(c.shopId),
            createdAt: c.createdAt, updatedAt: c.updatedAt,
          );
        }).toList();
        await _db.bulkInsertCustomers(list);

      case 'sales':
        final list = items.map((e) {
          final s = models.Sale.fromJson(e as Map<String, dynamic>);
          return SalesCompanion.insert(
            id: s.id, organizationId: s.organizationId,
            shopId: Value(s.shopId), customerId: Value(s.customerId),
            invoiceNumber: s.invoiceNumber,
            status: Value(s.status), paymentMethod: Value(s.paymentMethod),
            subtotal: Value(s.subtotal), discount: Value(s.discount),
            tax: Value(s.tax), total: Value(s.total),
            amountPaid: Value(s.amountPaid), notes: Value(s.notes),
            saleDate: s.saleDate, createdAt: s.createdAt,
            updatedAt: s.updatedAt,
            customerName: Value(s.customer?.name),
            customerPhone: Value(s.customer?.phone),
            itemsJson: Value(s.items != null
                ? jsonEncode(s.items!.map((i) => i.toJson()).toList())
                : null),
          );
        }).toList();
        await _db.bulkInsertSales(list);
    }
  }

  Future<void> pullDelta() async {
    if (_status != SyncStatus.idle) return;
    _setStatus(SyncStatus.syncing);
    try {
      for (final entity in ['products', 'customers', 'sales']) {
        final meta = await _db.getSyncMeta(entity);
        if (meta == null) continue;
        try {
          final r = await _apiClient.get('/api/$entity', queryParameters: {
            'updatedSince': meta.lastSyncedAt, 'limit': 500,
          });
          final data = r.data as Map<String, dynamic>;
          final items = data['data'] as List<dynamic>? ?? [];
          if (items.isNotEmpty) await _writeToDb(entity, items);
          await _db.upsertSyncMeta(
              entity, DateTime.now().toUtc().toIso8601String());
        } on DioException catch (e) {
          if (e.error == 'OFFLINE') continue;
          rethrow;
        }
      }
      _setStatus(SyncStatus.idle);
    } catch (e) {
      _logger.e('Delta sync error: $e');
      _setStatus(SyncStatus.error);
    }
  }

  Future<void> pushOutbox() async {
    if (_status != SyncStatus.idle) return;
    final items = await _db.getPendingOutboxItems();
    if (items.isEmpty) return;
    _setStatus(SyncStatus.pushing);

    for (final item in items) {
      try {
        Map<String, dynamic> payload;
        try {
          payload = jsonDecode(item.payload) as Map<String, dynamic>;
        } catch (_) {
          payload = {};
        }

        String endpoint = '/api/${item.entity}';
        if (item.operation == 'delete') {
          if (item.entityId != null) endpoint += '/${item.entityId}';
          await _apiClient.dio.delete(endpoint);
        } else if (item.operation == 'update' && item.entityId != null) {
          endpoint += '/${item.entityId}';
          await _apiClient.dio.put(endpoint, data: payload);
        } else {
          await _apiClient.dio.post(endpoint, data: payload);
        }
        await _db.markOutboxCompleted(item.id);
      } on DioException catch (e) {
        if (e.error == 'OFFLINE') break;
        final retryCount = item.retryCount + 1;
        await _db.updateOutboxStatus(
          item.id,
          retryCount >= AppConfig.maxOutboxRetries ? 'failed' : 'pending',
          e.message,
        );
      } catch (e) {
        await _db.updateOutboxStatus(item.id, 'failed', e.toString());
      }
    }
    await _db.removeCompletedOutboxItems();
    _setStatus(SyncStatus.idle);
  }

  Future<String> queueMutation({
    required String entity,
    required String operation,
    String? entityId,
    required Map<String, dynamic> payload,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.insertOutboxItem(OutboxCompanion.insert(
      id: id, entity: entity, operation: operation,
      entityId: Value(entityId),
      payload: jsonEncode(payload),
      createdAt: DateTime.now().toUtc().toIso8601String(),
    ));
    return id;
  }

  Future<void> fullSyncCycle() async {
    await pushOutbox();
    await pullDelta();
  }

  void dispose() {
    _statusController.close();
    _progressController.close();
  }
}