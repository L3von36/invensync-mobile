import 'package:drift/drift.dart';

class ServiceBookings extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get serviceTypeId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get status => text()();
  TextColumn get bookingDate => text()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}