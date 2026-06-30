enum ConflictStrategy { lastWriteWins, serverWins, clientWins, deltaMerge, manual }

enum ConflictWinner { local, server, merged }

class ConflictInfo {
  final String entity;
  final String localId;
  final String? serverId;
  final String operation; // 'create', 'update', 'delete'
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final String localUpdatedAt;
  final String serverUpdatedAt;
  final List<String> conflictingFields;

  const ConflictInfo({
    required this.entity,
    required this.localId,
    this.serverId,
    required this.operation,
    required this.localData,
    required this.serverData,
    required this.localUpdatedAt,
    required this.serverUpdatedAt,
    required this.conflictingFields,
  });
}

class ConflictResolution {
  final ConflictStrategy strategy;
  final Map<String, dynamic>? resolvedData; // null means discard
  final ConflictWinner winner;

  const ConflictResolution({
    required this.strategy,
    this.resolvedData,
    required this.winner,
  });
}

const _baseValuesKey = '_baseValues';

const Map<String, List<String>> _deltaFields = {
  'products': ['quantity'],
  'stockMovements': ['quantity'],
  'debts': ['paidAmount'],
};

const Map<String, ConflictStrategy> _strategyMap = {
  'products': ConflictStrategy.deltaMerge,
  'stockMovements': ConflictStrategy.deltaMerge,
  'sales': ConflictStrategy.lastWriteWins,
  'saleItems': ConflictStrategy.lastWriteWins,
  'customers': ConflictStrategy.lastWriteWins,
  'suppliers': ConflictStrategy.lastWriteWins,
  'debts': ConflictStrategy.deltaMerge,
  'expenses': ConflictStrategy.lastWriteWins,
  'purchaseOrders': ConflictStrategy.lastWriteWins,
  'serviceBookings': ConflictStrategy.lastWriteWins,
  'categories': ConflictStrategy.lastWriteWins,
  'shops': ConflictStrategy.lastWriteWins,
};

ConflictStrategy getDefaultStrategy(String entity) {
  return _strategyMap[entity] ?? ConflictStrategy.lastWriteWins;
}

ConflictResolution resolveConflict(ConflictInfo conflict, {ConflictStrategy? strategy}) {
  final effectiveStrategy = strategy ?? getDefaultStrategy(conflict.entity);

  switch (effectiveStrategy) {
    case ConflictStrategy.lastWriteWins:
      return _lastWriteWins(conflict);
    case ConflictStrategy.serverWins:
      return _serverWins(conflict);
    case ConflictStrategy.clientWins:
      return _clientWins(conflict);
    case ConflictStrategy.deltaMerge:
      return _deltaMerge(conflict);
    case ConflictStrategy.manual:
      return const ConflictResolution(
        strategy: ConflictStrategy.manual,
        resolvedData: null,
        winner: ConflictWinner.merged,
      );
  }
}

ConflictResolution _lastWriteWins(ConflictInfo conflict) {
  final localTime = DateTime.parse(conflict.localUpdatedAt).millisecondsSinceEpoch;
  final serverTime = DateTime.parse(conflict.serverUpdatedAt).millisecondsSinceEpoch;

  if (localTime > serverTime) {
    return ConflictResolution(
      strategy: ConflictStrategy.lastWriteWins,
      resolvedData: Map<String, dynamic>.from(conflict.localData),
      winner: ConflictWinner.local,
    );
  }

  return ConflictResolution(
    strategy: ConflictStrategy.lastWriteWins,
    resolvedData: Map<String, dynamic>.from(conflict.serverData),
    winner: ConflictWinner.server,
  );
}

ConflictResolution _serverWins(ConflictInfo conflict) {
  return ConflictResolution(
    strategy: ConflictStrategy.serverWins,
    resolvedData: Map<String, dynamic>.from(conflict.serverData),
    winner: ConflictWinner.server,
  );
}

ConflictResolution _clientWins(ConflictInfo conflict) {
  return ConflictResolution(
    strategy: ConflictStrategy.clientWins,
    resolvedData: Map<String, dynamic>.from(conflict.localData),
    winner: ConflictWinner.local,
  );
}

ConflictResolution _deltaMerge(ConflictInfo conflict) {
  final deltaFields = _deltaFields[conflict.entity] ?? [];
  final baseValues =
      (conflict.localData[_baseValuesKey] ?? {}) as Map<String, dynamic>;

  final merged = Map<String, dynamic>.from(conflict.serverData);
  var hasMerge = false;

  for (final field in deltaFields) {
    final localVal = conflict.localData[field];
    final serverVal = conflict.serverData[field];
    final baseVal = baseValues[field];

    if (localVal is num && serverVal is num && baseVal is num) {
      final localDelta = localVal.toDouble() - baseVal.toDouble();
      merged[field] = serverVal.toDouble() + localDelta;
      hasMerge = true;
    }
  }

  // For non-delta fields, use LWW
  final lwwResult = _lastWriteWins(conflict);
  for (final field in conflict.conflictingFields) {
    if (deltaFields.contains(field)) continue;
    if (field == 'updatedAt' || field == 'createdAt' || field == 'id') continue;
    if (field == _baseValuesKey) continue;
    merged[field] = lwwResult.resolvedData?[field] ?? merged[field];
  }

  merged['updatedAt'] = DateTime.now().toIso8601String();
  merged.remove(_baseValuesKey);

  return ConflictResolution(
    strategy: ConflictStrategy.deltaMerge,
    resolvedData: merged,
    winner: hasMerge ? ConflictWinner.merged : lwwResult.winner,
  );
}

List<String> findConflictingFields(
  Map<String, dynamic> local,
  Map<String, dynamic> server,
) {
  final ignored = {'updatedAt', 'createdAt', 'id', _baseValuesKey};
  final allKeys = {...local.keys, ...server.keys};
  final conflicting = <String>[];

  for (final key in allKeys) {
    if (ignored.contains(key)) continue;
    if (!_isEqual(local[key], server[key])) {
      conflicting.add(key);
    }
  }

  return conflicting;
}

bool _isEqual(dynamic a, dynamic b) {
  if (identical(a, b)) return true;
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.runtimeType != b.runtimeType) return false;
  return a.toString() == b.toString();
}