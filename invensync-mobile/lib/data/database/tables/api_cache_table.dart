import 'package:drift/drift.dart';

class ApiCache extends Table {
  TextColumn get id => text()(); // method:url as PK
  TextColumn get data => text()(); // JSON string
  TextColumn get cachedAt => text()();
  TextColumn get expiresAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}