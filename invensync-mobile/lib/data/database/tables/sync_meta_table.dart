import 'package:drift/drift.dart';

class SyncMeta extends Table {
  TextColumn get id => text()(); // entity name as PK
  TextColumn get lastSyncedAt => text()();
  TextColumn get lastSyncToken => text().nullable()();
  IntColumn get entityCount => integer().withDefault(const Constant(0))();
  TextColumn get lastFullSyncAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}