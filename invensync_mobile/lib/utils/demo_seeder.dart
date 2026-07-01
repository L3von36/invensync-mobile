import 'package:drift/drift.dart';
import '../db/database.dart';
import '../auth/token_storage.dart';

class DemoSeeder {
  final AppDatabase db;
  final TokenStorage storage;

  DemoSeeder(this.db, this.storage);

  static const String _demoOrgId = 'demo-org-001';
  static const String _demoUserId = 'demo-user-001';

  Future<void> seed() async {
    await storage.saveToken('demo-token');
    await storage.saveUserId(_demoUserId);
    await storage.saveOrganizationId(_demoOrgId);
    await storage.saveOrganizationName('InvenSync Demo');
    await storage.setBootstrapped(true);

    final now = DateTime.now().toIso8601String();

    await db.batch((b) {
      // Product types
      b.insertAllOnConflictUpdate(db.productTypes, [
        _pt('pt1', 'Electronics', 'memory', now),
        _pt('pt2', 'Clothing', 'checkroom', now),
        _pt('pt3', 'Food & Bev', 'local_cafe', now),
        _pt('pt4', 'Accessories', 'watch', now),
      ]);

      // Products
      b.insertAllOnConflictUpdate(db.products, [
        _product('p1', 'pt1', 'Wireless Mouse', 'Logitech M331', 45, 25.0, 55.0, now),
        _product('p2', 'pt1', 'USB-C Hub', '7-port USB-C adapter', 32, 18.0, 35.0, now),
        _product('p3', 'pt1', 'Mechanical Keyboard', 'RGB backlit 87-key', 8, 45.0, 89.0, now),
        _product('p4', 'pt1', 'Monitor Stand', 'Adjustable aluminum', 15, 30.0, 55.0, now),
        _product('p5', 'pt1', 'Webcam HD', '1080p with mic', 3, 20.0, 39.0, now),
        _product('p6', 'pt2', 'Cotton T-Shirt', 'Premium black M', 120, 8.0, 22.0, now),
        _product('p7', 'pt2', 'Denim Jacket', 'Classic fit L', 25, 35.0, 75.0, now),
        _product('p8', 'pt2', 'Running Shoes', 'Size 42, breathable', 40, 28.0, 65.0, now),
        _product('p9', 'pt3', 'Ethiopian Coffee', 'Yirgacheffe 1kg', 200, 12.0, 28.0, now),
        _product('p10', 'pt3', 'Green Tea', 'Organic 100 bags', 0, 5.0, 12.0, now),
        _product('p11', 'pt4', 'Leather Wallet', 'Genuine leather', 55, 15.0, 35.0, now),
        _product('p12', 'pt4', 'Sunglasses', 'UV400 polarized', 18, 8.0, 25.0, now),
      ]);

      // Customers
      b.insertAllOnConflictUpdate(db.customers, [
        _customer('c1', 'Abebe Kebede', 'abebe@email.com', '+251911123456', now),
        _customer('c2', 'Tigist Mengistu', 'tigist@email.com', '+251922234567', now),
        _customer('c3', 'Dawit Assefa', 'dawit@email.com', '+251933345678', now),
        _customer('c4', 'Helen Girma', 'helen@email.com', '+251944456789', now),
        _customer('c5', 'Solomon Tadesse', 'solomon@email.com', '+251955567890', now),
      ]);

      // Suppliers
      b.insertAllOnConflictUpdate(db.suppliers, [
        _supplier('s1', 'TechDistro PLC', 'orders@techdistro.com', '+251111234', now),
        _supplier('s2', 'FashionWholesale', 'info@fashionwholesale.com', '+251222345', now),
        _supplier('s3', 'GreenBean Importers', 'contact@greenbean.com', '+251333456', now),
      ]);

      // Shops
      b.insertAllOnConflictUpdate(db.shops, [
        ShopsCompanion.insert(
          id: 'shop1',
          organizationId: _demoOrgId,
          name: 'Main Store - Bole',
          address: const Value('Bole Road, Addis Ababa'),
          city: const Value('Addis Ababa'),
          phone: const Value('+25111234567'),
          isActive: const Value(true),
        ),
        ShopsCompanion.insert(
          id: 'shop2',
          organizationId: _demoOrgId,
          name: 'Branch - CMC',
          address: const Value('CMC Road, Addis Ababa'),
          city: const Value('Addis Ababa'),
          phone: const Value('+25122345678'),
          isActive: const Value(true),
        ),
      ]);

      // Sales
      b.insertAllOnConflictUpdate(db.sales, [
        _sale('sl1', 'c1', 'INV-2026-001', 'completed', 'cash', 155.0, now, 'Abebe Kebede', '+251911123456'),
        _sale('sl2', 'c2', 'INV-2026-002', 'completed', 'card', 22.0, now, 'Tigist Mengistu', '+251922234567'),
        _sale('sl3', 'c3', 'INV-2026-003', 'completed', 'cash', 89.0, now, 'Dawit Assefa', '+251933345678'),
        _sale('sl4', 'c4', 'INV-2026-004', 'pending', 'cash', 55.0, now, 'Helen Girma', '+251944456789'),
        _sale('sl5', 'c5', 'INV-2026-005', 'completed', 'mobile', 39.0, now, 'Solomon Tadesse', '+251955567890'),
      ]);
    });
  }

  ProductTypesCompanion _pt(String id, String name, String icon, String now) {
    return ProductTypesCompanion.insert(
      id: id,
      organizationId: _demoOrgId,
      name: name,
      icon: Value(icon),
      createdAt: now,
      updatedAt: now,
    );
  }

  ProductsCompanion _product(
    String id, String typeId, String name, String desc,
    int qty, double cost, double price, String now,
  ) {
    return ProductsCompanion.insert(
      id: id,
      productTypeId: typeId,
      organizationId: _demoOrgId,
      name: name,
      description: Value(desc),
      quantity: qty,
      costPrice: cost,
      sellingPrice: price,
      sku: Value('${name.substring(0, 3).toUpperCase()}-$id'),
      isActive: const Value(true),
      createdAt: now,
      updatedAt: now,
    );
  }

  CustomersCompanion _customer(String id, String name, String email, String phone, String now) {
    return CustomersCompanion.insert(
      id: id,
      organizationId: _demoOrgId,
      name: name,
      email: Value(email),
      phone: Value(phone),
      createdAt: now,
      updatedAt: now,
    );
  }

  SuppliersCompanion _supplier(String id, String name, String email, String phone, String now) {
    return SuppliersCompanion.insert(
      id: id,
      organizationId: _demoOrgId,
      name: name,
      email: Value(email),
      phone: Value(phone),
      createdAt: now,
      updatedAt: now,
    );
  }

  SalesCompanion _sale(
    String id, String custId, String inv,
    String status, String method, double total, String now,
    String custName, String custPhone,
  ) {
    return SalesCompanion(
      id: Value(id),
      organizationId: Value(_demoOrgId),
      customerId: Value(custId),
      invoiceNumber: Value(inv),
      status: Value(status),
      paymentMethod: Value(method),
      subtotal: Value(total),
      total: Value(total),
      amountPaid: Value(status == 'completed' ? total : 0),
      saleDate: Value(now.substring(0, 10)),
      createdAt: Value(now),
      updatedAt: Value(now),
      customerName: Value(custName),
      customerPhone: Value(custPhone),
    );
  }
}