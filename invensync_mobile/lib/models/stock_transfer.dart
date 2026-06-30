class StockTransferProductRef {
  final String id;
  final String name;
  final String? sku;

  const StockTransferProductRef({
    required this.id,
    required this.name,
    this.sku,
  });

  factory StockTransferProductRef.fromJson(Map<String, dynamic> json) {
    return StockTransferProductRef(
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

  StockTransferProductRef copyWith({String? id, String? name, String? sku}) {
    return StockTransferProductRef(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransferProductRef &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class StockTransferShopRef {
  final String id;
  final String name;

  const StockTransferShopRef({
    required this.id,
    required this.name,
  });

  factory StockTransferShopRef.fromJson(Map<String, dynamic> json) {
    return StockTransferShopRef(
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

  StockTransferShopRef copyWith({String? id, String? name}) {
    return StockTransferShopRef(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransferShopRef &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class StockTransfer {
  final String id;
  final String organizationId;
  final String fromShopId;
  final String toShopId;
  final String productId;
  final int quantity;
  final String status;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final StockTransferProductRef? product;
  final StockTransferShopRef? fromShop;
  final StockTransferShopRef? toShop;

  const StockTransfer({
    required this.id,
    required this.organizationId,
    required this.fromShopId,
    required this.toShopId,
    required this.productId,
    required this.quantity,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.product,
    this.fromShop,
    this.toShop,
  });

  factory StockTransfer.fromJson(Map<String, dynamic> json) {
    return StockTransfer(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      fromShopId: json['fromShopId'] as String? ?? '',
      toShopId: json['toShopId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      product: json['product'] != null
          ? StockTransferProductRef.fromJson(
              json['product'] as Map<String, dynamic>)
          : null,
      fromShop: json['fromShop'] != null
          ? StockTransferShopRef.fromJson(
              json['fromShop'] as Map<String, dynamic>)
          : null,
      toShop: json['toShop'] != null
          ? StockTransferShopRef.fromJson(
              json['toShop'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'fromShopId': fromShopId,
      'toShopId': toShopId,
      'productId': productId,
      'quantity': quantity,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'product': product?.toJson(),
      'fromShop': fromShop?.toJson(),
      'toShop': toShop?.toJson(),
    };
  }

  StockTransfer copyWith({
    String? id,
    String? organizationId,
    String? fromShopId,
    String? toShopId,
    String? productId,
    int? quantity,
    String? status,
    String? notes,
    String? createdAt,
    String? updatedAt,
    StockTransferProductRef? product,
    StockTransferShopRef? fromShop,
    StockTransferShopRef? toShop,
  }) {
    return StockTransfer(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      fromShopId: fromShopId ?? this.fromShopId,
      toShopId: toShopId ?? this.toShopId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
      fromShop: fromShop ?? this.fromShop,
      toShop: toShop ?? this.toShop,
    );
  }

  @override
  String toString() =>
      'StockTransfer(id: $id, status: $status, qty: $quantity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransfer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}