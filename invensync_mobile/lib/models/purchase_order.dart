import 'purchase_order_item.dart';

class PurchaseOrderSupplierRef {
  final String id;
  final String name;
  final String? phone;

  const PurchaseOrderSupplierRef({
    required this.id,
    required this.name,
    this.phone,
  });

  factory PurchaseOrderSupplierRef.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderSupplierRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  PurchaseOrderSupplierRef copyWith({String? id, String? name, String? phone}) {
    return PurchaseOrderSupplierRef(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderSupplierRef &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PurchaseOrder {
  final String id;
  final String organizationId;
  final String? shopId;
  final String supplierId;
  final String status;
  final String? notes;
  final double totalAmount;
  final String createdAt;
  final String updatedAt;
  final PurchaseOrderSupplierRef? supplier;
  final List<PurchaseOrderItem>? items;

  const PurchaseOrder({
    required this.id,
    required this.organizationId,
    this.shopId,
    required this.supplierId,
    required this.status,
    this.notes,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.supplier,
    this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      supplierId: json['supplierId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      notes: json['notes'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      supplier: json['supplier'] != null
          ? PurchaseOrderSupplierRef.fromJson(
              json['supplier'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'shopId': shopId,
      'supplierId': supplierId,
      'status': status,
      'notes': notes,
      'totalAmount': totalAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'supplier': supplier?.toJson(),
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }

  PurchaseOrder copyWith({
    String? id,
    String? organizationId,
    String? shopId,
    String? supplierId,
    String? status,
    String? notes,
    double? totalAmount,
    String? createdAt,
    String? updatedAt,
    PurchaseOrderSupplierRef? supplier,
    List<PurchaseOrderItem>? items,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      shopId: shopId ?? this.shopId,
      supplierId: supplierId ?? this.supplierId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supplier: supplier ?? this.supplier,
      items: items ?? this.items,
    );
  }

  @override
  String toString() =>
      'PurchaseOrder(id: $id, status: $status, total: $totalAmount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}