// Domain models matching InvenSync API responses.

class Product {
  final String id;
  final String? productTypeId;
  final String organizationId;
  final String? shopId;
  final String? sku;
  final String name;
  final String? description;
  final String? imageUrl;
  final double quantity;
  final double costPrice;
  final double sellingPrice;
  final double lowStockThreshold;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? productTypeName;

  const Product({
    required this.id,
    this.productTypeId,
    required this.organizationId,
    this.shopId,
    this.sku,
    required this.name,
    this.description,
    this.imageUrl,
    this.quantity = 0,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.lowStockThreshold = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.productTypeName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      productTypeId: json['productTypeId'] as String?,
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      sku: json['sku'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0,
      lowStockThreshold:
          (json['lowStockThreshold'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String? ??
          DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String? ??
          DateTime.now().toIso8601String(),
      productTypeName: json['productType']?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productTypeId': productTypeId,
        'organizationId': organizationId,
        'shopId': shopId,
        'sku': sku,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'lowStockThreshold': lowStockThreshold,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  Product copyWith({
    String? id,
    String? productTypeId,
    String? organizationId,
    String? shopId,
    String? sku,
    String? name,
    String? description,
    String? imageUrl,
    double? quantity,
    double? costPrice,
    double? sellingPrice,
    double? lowStockThreshold,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? productTypeName,
  }) {
    return Product(
      id: id ?? this.id,
      productTypeId: productTypeId ?? this.productTypeId,
      organizationId: organizationId ?? this.organizationId,
      shopId: shopId ?? this.shopId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productTypeName: productTypeName ?? this.productTypeName,
    );
  }
}

// ---------------------------------------------------------------------------
// Category (ProductType in InvenSync)
// ---------------------------------------------------------------------------

class Category {
  final String id;
  final String organizationId;
  final String name;
  final String? icon;
  final String createdAt;
  final String updatedAt;
  final int productCount;

  const Category({
    required this.id,
    required this.organizationId,
    required this.name,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      productCount:
          (json['_count']?['products'] as num?)?.toInt() ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Customer
// ---------------------------------------------------------------------------

class Customer {
  final String id;
  final String organizationId;
  final String? shopId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String createdAt;
  final String updatedAt;
  final double totalDebt;

  const Customer({
    required this.id,
    required this.organizationId,
    this.shopId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.totalDebt = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Supplier
// ---------------------------------------------------------------------------

class Supplier {
  final String id;
  final String organizationId;
  final String? shopId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String createdAt;
  final String updatedAt;

  const Supplier({
    required this.id,
    required this.organizationId,
    this.shopId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// Sale
// ---------------------------------------------------------------------------

class Sale {
  final String id;
  final String organizationId;
  final String? shopId;
  final String? customerId;
  final String invoiceNumber;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double amountPaid;
  final String? notes;
  final String saleDate;
  final String createdAt;
  final String updatedAt;
  final String? customerName;
  final List<SaleItem> items;

  const Sale({
    required this.id,
    required this.organizationId,
    this.shopId,
    this.customerId,
    required this.invoiceNumber,
    required this.status,
    required this.paymentMethod,
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.total = 0,
    this.amountPaid = 0,
    this.notes,
    required this.saleDate,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.items = const [],
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      customerId: json['customerId'] as String?,
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'completed',
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      saleDate: json['saleDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      customerName: json['customer']?['name'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  SaleItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ---------------------------------------------------------------------------
// SaleItem
// ---------------------------------------------------------------------------

class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double costPrice;
  final double total;
  final String? productName;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    required this.total,
    this.productName,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] as String,
      saleId: json['saleId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      productName: json['product']?['name'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Debt
// ---------------------------------------------------------------------------

class Debt {
  final String id;
  final String organizationId;
  final String? shopId;
  final String? customerId;
  final String? supplierId;
  final String type;
  final double amount;
  final double paidAmount;
  final String? dueDate;
  final String status;
  final String? description;
  final String createdAt;
  final String updatedAt;
  final String? customerName;

  const Debt({
    required this.id,
    required this.organizationId,
    this.shopId,
    this.customerId,
    this.supplierId,
    required this.type,
    required this.amount,
    this.paidAmount = 0,
    this.dueDate,
    required this.status,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      customerId: json['customerId'] as String?,
      supplierId: json['supplierId'] as String?,
      type: json['type'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      dueDate: json['dueDate'] as String?,
      status: json['status'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      customerName: json['customer']?['name'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Shop
// ---------------------------------------------------------------------------

class Shop {
  final String id;
  final String organizationId;
  final String name;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final bool isActive;

  const Shop({
    required this.id,
    required this.organizationId,
    required this.name,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.phone,
    this.isActive = true,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

// ---------------------------------------------------------------------------
// Expense
// ---------------------------------------------------------------------------

class Expense {
  final String id;
  final String organizationId;
  final String? shopId;
  final String category;
  final double amount;
  final String? description;
  final String date;
  final bool? isRecurring;
  final String createdAt;
  final String updatedAt;

  const Expense({
    required this.id,
    required this.organizationId,
    this.shopId,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
    this.isRecurring,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      date: json['date'] as String? ?? '',
      isRecurring: json['isRecurring'] as bool?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}