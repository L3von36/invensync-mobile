import 'package:drift/drift.dart';

class Outbox extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get payload => text()(); // JSON string
  TextColumn get localId => text().nullable()();
  TextColumn get serverId => text().nullable()();
  TextColumn get createdAt => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // 'pending','syncing','synced','failed','conflict'
  TextColumn get error => text().nullable()();
  TextColumn get lastAttemptAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}