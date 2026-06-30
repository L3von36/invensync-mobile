import 'package:drift/drift.dart';

class UserProfile extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get organizations => text()(); // JSON string
  TextColumn get currentOrgId => text()();
  TextColumn get currentShopId => text().nullable()();
  TextColumn get cachedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}