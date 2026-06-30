class SaleItem {
  final String id;
  final String saleId;
  final String? productId;
  final int quantity;
  final double unitPrice;
  final double costPrice;
  final double total;
  final ProductRef? product;

  const SaleItem({
    required this.id, required this.saleId, this.productId,
    required this.quantity, required this.unitPrice,
    required this.costPrice, required this.total, this.product,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] as String? ?? '',
      saleId: json['saleId'] as String? ?? '',
      productId: json['productId'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      product: json['product'] != null
          ? ProductRef.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'saleId': saleId,
      if (productId != null) 'productId': productId,
      'quantity': quantity, 'unitPrice': unitPrice,
      'costPrice': costPrice, 'total': total,
    };
  }
}

class ProductRef {
  final String id;
  final String name;
  final String? sku;
  final String? imageUrl;

  const ProductRef({required this.id, required this.name, this.sku, this.imageUrl});

  factory ProductRef.fromJson(Map<String, dynamic> json) {
    return ProductRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}