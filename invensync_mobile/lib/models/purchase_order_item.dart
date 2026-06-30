class PurchaseOrderItemProductRef {
  final String id;
  final String name;
  final String? sku;

  const PurchaseOrderItemProductRef({
    required this.id,
    required this.name,
    this.sku,
  });

  factory PurchaseOrderItemProductRef.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemProductRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
    };
  }

  PurchaseOrderItemProductRef copyWith({
    String? id,
    String? name,
    String? sku,
  }) {
    return PurchaseOrderItemProductRef(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderItemProductRef &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PurchaseOrderItem {
  final String id;
  final String purchaseOrderId;
  final String productId;
  final int quantity;
  final double unitCost;
  final double total;
  final PurchaseOrderItemProductRef? product;

  const PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.quantity,
    required this.unitCost,
    required this.total,
    this.product,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'] as String? ?? '',
      purchaseOrderId: json['purchaseOrderId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitCost: (json['unitCost'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      product: json['product'] != null
          ? PurchaseOrderItemProductRef.fromJson(
              json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseOrderId': purchaseOrderId,
      'productId': productId,
      'quantity': quantity,
      'unitCost': unitCost,
      'total': total,
      'product': product?.toJson(),
    };
  }

  PurchaseOrderItem copyWith({
    String? id,
    String? purchaseOrderId,
    String? productId,
    int? quantity,
    double? unitCost,
    double? total,
    PurchaseOrderItemProductRef? product,
  }) {
    return PurchaseOrderItem(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      total: total ?? this.total,
      product: product ?? this.product,
    );
  }

  @override
  String toString() =>
      'PurchaseOrderItem(id: $id, productId: $productId, qty: $quantity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}