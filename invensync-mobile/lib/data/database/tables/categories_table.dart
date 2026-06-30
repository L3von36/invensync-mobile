import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}