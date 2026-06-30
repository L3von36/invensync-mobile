class ProductType {
  final String id;
  final String organizationId;
  final String name;
  final String? icon;
  final String createdAt;
  final String updatedAt;
  final List<AttributeDefinition>? attributes;
  final int? productCount;

  const ProductType({
    required this.id, required this.organizationId,
    required this.name, this.icon,
    required this.createdAt, required this.updatedAt,
    this.attributes, this.productCount,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((e) => AttributeDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      productCount: (json['_count']?['products'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'organizationId': organizationId,
      'name': name, 'createdAt': createdAt, 'updatedAt': updatedAt,
      if (icon != null) 'icon': icon,
    };
  }
}

class AttributeDefinition {
  final String id;
  final String productTypeId;
  final String name;
  final String fieldType;
  final String? options;
  final bool required;
  final int order;

  const AttributeDefinition({
    required this.id, required this.productTypeId,
    required this.name, required this.fieldType,
    this.options, required this.required, required this.order,
  });

  factory AttributeDefinition.fromJson(Map<String, dynamic> json) {
    return AttributeDefinition(
      id: json['id'] as String? ?? '',
      productTypeId: json['productTypeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fieldType: json['fieldType'] as String? ?? 'text',
      options: json['options'] as String?,
      required: json['required'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}