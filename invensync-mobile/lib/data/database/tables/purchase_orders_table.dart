import 'package:drift/drift.dart';

class PurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get status => text()();
  RealColumn get totalAmount => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}