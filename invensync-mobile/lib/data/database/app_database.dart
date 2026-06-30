import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/products_table.dart';
import 'tables/categories_table.dart';
import 'tables/customers_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/debts_table.dart';
import 'tables/purchase_orders_table.dart';
import 'tables/purchase_order_items_table.dart';
import 'tables/service_bookings_table.dart';
import 'tables/service_types_table.dart';
import 'tables/expenses_table.dart';
import 'tables/shops_table.dart';
import 'tables/outbox_table.dart';
import 'tables/sync_meta_table.dart';
import 'tables/api_cache_table.dart';
import 'tables/user_profile_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Products,
  Categories,
  Customers,
  Suppliers,
  Sales,
  SaleItems,
  StockMovements,
  Debts,
  PurchaseOrders,
  PurchaseOrderItems,
  ServiceBookings,
  ServiceTypes,
  Expenses,
  Shops,
  Outbox,
  SyncMeta,
  ApiCache,
  UserProfile,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }

  /// Clear all data (used on logout / org switch).
  Future<void> clearAll() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  }

  /// Get record counts per table.
  Future<Map<String, int>> getTableCounts() async {
    return {
      'products': await select(products).get().then((l) => l.length),
      'categories': await select(categories).get().then((l) => l.length),
      'customers': await select(customers).get().then((l) => l.length),
      'suppliers': await select(suppliers).get().then((l) => l.length),
      'sales': await select(sales).get().then((l) => l.length),
      'saleItems': await select(saleItems).get().then((l) => l.length),
      'stockMovements':
          await select(stockMovements).get().then((l) => l.length),
      'debts': await select(debts).get().then((l) => l.length),
      'purchaseOrders':
          await select(purchaseOrders).get().then((l) => l.length),
      'serviceBookings':
          await select(serviceBookings).get().then((l) => l.length),
      'expenses': await select(expenses).get().then((l) => l.length),
      'shops': await select(shops).get().then((l) => l.length),
      'outbox': await select(outbox).get().then((l) => l.length),
    };
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'invensync.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}