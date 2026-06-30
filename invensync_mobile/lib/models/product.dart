class Product {
  final String id;
  final String productTypeId;
  final String organizationId;
  final String? shopId;
  final String? sku;
  final String name;
  final String? description;
  final String? imageUrl;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final int lowStockThreshold;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final ProductTypeRef? productType;
  final List<ProductAttributeValue>? attributeValues;

  const Product({
    required this.id, required this.productTypeId,
    required this.organizationId, this.shopId, this.sku,
    required this.name, this.description, this.imageUrl,
    required this.quantity, required this.costPrice,
    required this.sellingPrice, required this.lowStockThreshold,
    required this.isActive, required this.createdAt,
    required this.updatedAt, this.productType, this.attributeValues,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      productTypeId: json['productTypeId'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      sku: json['sku'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      productType: json['productType'] != null
          ? ProductTypeRef.fromJson(json['productType'] as Map<String, dynamic>)
          : null,
      attributeValues: (json['attributeValues'] as List<dynamic>?)
          ?.map((e) => ProductAttributeValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'productTypeId': productTypeId,
      'organizationId': organizationId,
      if (shopId != null) 'shopId': shopId,
      if (sku != null) 'sku': sku,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'quantity': quantity, 'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'lowStockThreshold': lowStockThreshold,
      'isActive': isActive,
      'createdAt': createdAt, 'updatedAt': updatedAt,
    };
  }

  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
  bool get isOutOfStock => quantity <= 0;
  double get profitMargin => costPrice > 0
      ? ((sellingPrice - costPrice) / costPrice * 100) : 0;
}

class ProductTypeRef {
  final String id;
  final String name;
  final String? icon;

  const ProductTypeRef({required this.id, required this.name, this.icon});

  factory ProductTypeRef.fromJson(Map<String, dynamic> json) {
    return ProductTypeRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }
}

class ProductAttributeValue {
  final String id;
  final String productId;
  final String attributeDefinitionId;
  final String value;
  final AttributeDefRef? attributeDefinition;

  const ProductAttributeValue({
    required this.id, required this.productId,
    required this.attributeDefinitionId, required this.value,
    this.attributeDefinition,
  });

  factory ProductAttributeValue.fromJson(Map<String, dynamic> json) {
    return ProductAttributeValue(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      attributeDefinitionId: json['attributeDefinitionId'] as String? ?? '',
      value: json['value'] as String? ?? '',
      attributeDefinition: json['attributeDefinition'] != null
          ? AttributeDefRef.fromJson(json['attributeDefinition'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AttributeDefRef {
  final String id;
  final String name;
  final String fieldType;

  const AttributeDefRef({
    required this.id, required this.name, required this.fieldType,
  });

  factory AttributeDefRef.fromJson(Map<String, dynamic> json) {
    return AttributeDefRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fieldType: json['fieldType'] as String? ?? '',
    );
  }
}