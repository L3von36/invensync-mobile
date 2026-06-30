import 'package:drift/drift.dart';

class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  TextColumn get dueDate => text().nullable()();
  TextColumn get status => text()();
  TextColumn get description => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}