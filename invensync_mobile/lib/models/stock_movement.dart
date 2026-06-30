import 'sale_item.dart';

class StockMovement {
  final String id;
  final String organizationId;
  final String? shopId;
  final String productId;
  final String type;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String? reason;
  final String? reference;
  final String createdAt;
  final ProductRef? product;

  const StockMovement({
    required this.id, required this.organizationId,
    this.shopId, required this.productId, required this.type,
    required this.quantity, required this.previousStock,
    required this.newStock, this.reason, this.reference,
    required this.createdAt, this.product,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      productId: json['productId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      previousStock: (json['previousStock'] as num?)?.toInt() ?? 0,
      newStock: (json['newStock'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String?,
      reference: json['reference'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      product: json['product'] != null
          ? ProductRef.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'organizationId': organizationId,
      if (shopId != null) 'shopId': shopId,
      'productId': productId, 'type': type,
      'quantity': quantity, 'previousStock': previousStock,
      'newStock': newStock,
      if (reason != null) 'reason': reason,
      if (reference != null) 'reference': reference,
      'createdAt': createdAt,
    };
  }
}