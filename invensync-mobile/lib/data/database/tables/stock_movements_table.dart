import 'package:drift/drift.dart';

class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get productId => text()();
  TextColumn get type => text()();
  RealColumn get quantity => real()();
  RealColumn get previousStock => real()();
  RealColumn get newStock => real()();
  TextColumn get reason => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}