import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============================================
// TABLES
// ============================================

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get productTypeId => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get quantity => integer()();
  RealColumn get costPrice => real()();
  RealColumn get sellingPrice => real()();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(10))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];

  @override
  List<Set<Column>> get indexes => [
    {organizationId},
    {organizationId, isActive},
    {sku},
  ];
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {organizationId},
    {organizationId, name},
  ];
}

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [{organizationId}];
}

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get invoiceNumber => text()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get saleDate => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get itemsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {organizationId},
    {organizationId, saleDate},
    {status},
  ];
}

class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text().nullable()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get costPrice => real()();
  RealColumn get total => real()();
  TextColumn get productName => text().nullable()();
  TextColumn get productSku => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [{saleId}, {productId}];
}

class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get productId => text()();
  TextColumn get type => text()();
  IntColumn get quantity => integer()();
  IntColumn get previousStock => integer()();
  IntColumn get newStock => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get productName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {organizationId},
    {productId},
    {createdAt},
  ];
}

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
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get description => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get contactName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {organizationId},
    {customerId},
    {status},
  ];
}

class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [{organizationId}];
}

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get shopId => text().nullable()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get date => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [{organizationId}, {date}];
}

class ProductTypes extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [{organizationId}];
}

// ============================================
// OUTBOX TABLE (for offline mutations)
// ============================================

class Outbox extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get operation => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get payload => text()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get nextRetryAt =>
      dateTime().nullable()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {entity, status},
    {status},
  ];
}

// ============================================
// SYNC METADATA TABLE
// ============================================

class SyncMeta extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get lastSyncedAt => text()();
  IntColumn get lastSyncToken => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{entity}];
}

// ============================================
// DATABASE
// ============================================

@DriftDatabase(tables: [
  Products, Customers, Suppliers, Sales, SaleItems,
  StockMovements, Debts, Shops, Expenses, ProductTypes,
  Outbox, SyncMeta,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ============================================
  // PRODUCT QUERIES
  // ============================================

  Future<List<Product>> getAllProducts(String organizationId) {
    return (select(products)
          ..where((t) => t.organizationId.equals(organizationId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<Product>> getActiveProducts(String organizationId) {
    return (select(products)
          ..where((t) =>
              t.organizationId.equals(organizationId) &
              t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<Product>> searchProducts(
      String organizationId, String query) {
    return (select(products)
          ..where((t) =>
              t.organizationId.equals(organizationId) &
              (t.name.contains(query) | t.sku.contains(query)))
          ..limit(50))
        .get();
  }

  Future<List<Product>> getLowStockProducts(String organizationId) {
    return (select(products)
          ..where((t) =>
              t.organizationId.equals(organizationId) &
              t.isActive.equals(true) &
              t.quantity
                  .isBiggerOrEqualValue(0) &
              t.quantity.isSmallerOrEqualValue(10)))
        .get();
  }

  Future<Product?> getProductById(String id) {
    return (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertOrUpdateProduct(ProductsCompanion product) {
    return into(products).insertOnConflictUpdate(product);
  }

  Future<void> bulkInsertProducts(List<ProductsCompanion> items) {
    return batch((b) {
      b.insertAllOnConflictUpdate(products, items);
    });
  }

  Future<int> getProductCount(String organizationId) {
    final query = selectOnly(products)
      ..addColumns([products.id.count()])
      ..where(products.organizationId.equals(organizationId));
    return query.getSingle().then((row) => row.read(products.id.count()) ?? 0);
  }

  // ============================================
  // CUSTOMER QUERIES
  // ============================================

  Future<List<Customer>> getAllCustomers(String organizationId) {
    return (select(customers)
          ..where((t) => t.organizationId.equals(organizationId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<Customer>> searchCustomers(
      String organizationId, String query) {
    return (select(customers)
          ..where((t) =>
              t.organizationId.equals(organizationId) &
              (t.name.contains(query) |
                  t.phone.contains(query) |
                  t.email.contains(query)))
          ..limit(50))
        .get();
  }

  Future<void> insertOrUpdateCustomer(CustomersCompanion customer) {
    return into(customers).insertOnConflictUpdate(customer);
  }

  Future<void> bulkInsertCustomers(List<CustomersCompanion> items) {
    return batch((b) {
      b.insertAllOnConflictUpdate(customers, items);
    });
  }

  // ============================================
  // SALE QUERIES
  // ============================================

  Future<List<Sale>> getAllSales(String organizationId) {
    return (select(sales)
          ..where((t) => t.organizationId.equals(organizationId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<Sale>> getRecentSales(String organizationId, {int limit = 10}) {
    return (select(sales)
          ..where((t) => t.organizationId.equals(organizationId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<double> getTodayRevenue(String organizationId) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final query = selectOnly(sales)
      ..addColumns([sales.total.sum()])
      ..where(sales.organizationId.equals(organizationId) &
          sales.saleDate.like('$today%'));
    return query
        .getSingle()
        .then((row) => row.read(sales.total.sum()) ?? 0.0);
  }

  Future<void> insertOrUpdateSale(SalesCompanion sale) {
    return into(sales).insertOnConflictUpdate(sale);
  }

  Future<void> bulkInsertSales(List<SalesCompanion> items) {
    return batch((b) {
      b.insertAllOnConflictUpdate(sales, items);
    });
  }

  // ============================================
  // OUTBOX QUERIES
  // ============================================

  Future<List<OutboxData>> getPendingOutboxItems() {
    return (select(outbox)
          ..where((t) =>
              t.status.equals('pending') &
              (t.nextRetryAt.isNull() |
                  t.nextRetryAt.isSmallerOrEqualValue(DateTime.now())))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(50))
        .get();
  }

  Future<void> insertOutboxItem(OutboxCompanion item) {
    return into(outbox).insert(item);
  }

  Future<void> updateOutboxStatus(
      String id, String status, String? error) {
    return (update(outbox)..where((t) => t.id.equals(id))).write(
      OutboxCompanion(
        status: Value(status),
        lastError: Value(error),
        nextRetryAt: status == 'failed'
            ? Value(DateTime.now().add(const Duration(seconds: 30)))
            : const Value(null),
      ),
    );
  }

  Future<void> markOutboxCompleted(String id) {
    return (update(outbox)..where((t) => t.id.equals(id))).write(
      const OutboxCompanion(
        status: Value('completed'),
        lastError: Value(null),
      ),
    );
  }

  Future<void> removeCompletedOutboxItems() {
    return (delete(outbox)
          ..where((t) => t.status.equals('completed')))
        .go();
  }

  Future<int> getPendingOutboxCount() async {
    final query = selectOnly(outbox)
      ..addColumns([outbox.id.count()])
      ..where(outbox.status.equals('pending'));
    return query
        .getSingle()
        .then((row) => row.read(outbox.id.count()) ?? 0);
  }

  // ============================================
  // SYNC META QUERIES
  // ============================================

  Future<SyncMetaData?> getSyncMeta(String entity) {
    return (select(syncMeta)..where((t) => t.entity.equals(entity)))
        .getSingleOrNull();
  }

  Future<void> upsertSyncMeta(
      String entity, String lastSyncedAt) {
    return into(syncMeta).insertOnConflictUpdate(
      SyncMetaCompanion(
        id: Value(entity),
        entity: Value(entity),
        lastSyncedAt: Value(lastSyncedAt),
      ),
    );
  }

  Future<void> clearAllData() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'invensync.db'));
    return NativeDatabase.createInBackground(file);
  });
}