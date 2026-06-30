import 'package:drift/drift.dart';

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get invoiceNumber => text()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get paymentMethod =>
      text().withDefault(const Constant('cash'))();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get saleDate => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}