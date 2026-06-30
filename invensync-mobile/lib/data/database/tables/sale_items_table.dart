import 'package:drift/drift.dart';

class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get costPrice => real()();
  RealColumn get total => real()();
  TextColumn get createdAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}