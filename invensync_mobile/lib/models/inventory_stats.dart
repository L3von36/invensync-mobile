import 'stock_movement.dart';

// ─── ProductTypeRef (re-exported here for inventory context) ────────────────

class InventoryProductTypeRef {
  final String id;
  final String name;

  const InventoryProductTypeRef({
    required this.id,
    required this.name,
  });

  factory InventoryProductTypeRef.fromJson(Map<String, dynamic> json) {
    return InventoryProductTypeRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  InventoryProductTypeRef copyWith({String? id, String? name}) {
    return InventoryProductTypeRef(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryProductTypeRef &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ─── InventoryOverview ─────────────────────────────────────────────────────

class InventoryOverview {
  final int totalProducts;
  final int outOfStock;
  final int lowStock;
  final double totalCostValue;
  final double totalRetailValue;

  const InventoryOverview({
    this.totalProducts = 0,
    this.outOfStock = 0,
    this.lowStock = 0,
    this.totalCostValue = 0.0,
    this.totalRetailValue = 0.0,
  });

  factory InventoryOverview.fromJson(Map<String, dynamic> json) {
    return InventoryOverview(
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      outOfStock: (json['outOfStock'] as num?)?.toInt() ?? 0,
      lowStock: (json['lowStock'] as num?)?.toInt() ?? 0,
      totalCostValue: (json['totalCostValue'] as num?)?.toDouble() ?? 0.0,
      totalRetailValue: (json['totalRetailValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'outOfStock': outOfStock,
      'lowStock': lowStock,
      'totalCostValue': totalCostValue,
      'totalRetailValue': totalRetailValue,
    };
  }

  InventoryOverview copyWith({
    int? totalProducts,
    int? outOfStock,
    int? lowStock,
    double? totalCostValue,
    double? totalRetailValue,
  }) {
    return InventoryOverview(
      totalProducts: totalProducts ?? this.totalProducts,
      outOfStock: outOfStock ?? this.outOfStock,
      lowStock: lowStock ?? this.lowStock,
      totalCostValue: totalCostValue ?? this.totalCostValue,
      totalRetailValue: totalRetailValue ?? this.totalRetailValue,
    );
  }
}

// ─── LowStockProduct ───────────────────────────────────────────────────────

class LowStockProduct {
  final String id;
  final String name;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final int lowStockThreshold;
  final InventoryProductTypeRef productType;

  const LowStockProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.lowStockThreshold,
    required this.productType,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 0,
      productType: json['productType'] != null
          ? InventoryProductTypeRef.fromJson(
              json['productType'] as Map<String, dynamic>)
          : const InventoryProductTypeRef(id: '', name: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'lowStockThreshold': lowStockThreshold,
      'productType': productType.toJson(),
    };
  }

  LowStockProduct copyWith({
    String? id,
    String? name,
    int? quantity,
    double? costPrice,
    double? sellingPrice,
    int? lowStockThreshold,
    InventoryProductTypeRef? productType,
  }) {
    return LowStockProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      productType: productType ?? this.productType,
    );
  }

  @override
  String toString() =>
      'LowStockProduct(id: $id, name: $name, qty: $quantity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LowStockProduct &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ─── InventoryStats ────────────────────────────────────────────────────────

class InventoryStats {
  final InventoryOverview overview;
  final List<LowStockProduct> lowStockProducts;
  final List<StockMovement> recentMovements;

  const InventoryStats({
    this.overview = const InventoryOverview(),
    this.lowStockProducts = const [],
    this.recentMovements = const [],
  });

  factory InventoryStats.fromJson(Map<String, dynamic> json) {
    return InventoryStats(
      overview: json['overview'] != null
          ? InventoryOverview.fromJson(json['overview'] as Map<String, dynamic>)
          : const InventoryOverview(),
      lowStockProducts: (json['lowStockProducts'] as List<dynamic>?)
              ?.map((e) => LowStockProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentMovements: (json['recentMovements'] as List<dynamic>?)
              ?.map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overview': overview.toJson(),
      'lowStockProducts': lowStockProducts.map((e) => e.toJson()).toList(),
      'recentMovements': recentMovements.map((e) => e.toJson()).toList(),
    };
  }

  InventoryStats copyWith({
    InventoryOverview? overview,
    List<LowStockProduct>? lowStockProducts,
    List<StockMovement>? recentMovements,
  }) {
    return InventoryStats(
      overview: overview ?? this.overview,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      recentMovements: recentMovements ?? this.recentMovements,
    );
  }
}