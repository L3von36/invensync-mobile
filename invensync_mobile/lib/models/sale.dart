import 'sale_item.dart';

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
  final CustomerRef? customer;
  final List<SaleItem>? items;

  const Sale({
    required this.id, required this.organizationId,
    this.shopId, this.customerId,
    required this.invoiceNumber, required this.status,
    required this.paymentMethod, required this.subtotal,
    required this.discount, required this.tax, required this.total,
    required this.amountPaid, this.notes, required this.saleDate,
    required this.createdAt, required this.updatedAt,
    this.customer, this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      customerId: json['customerId'] as String?,
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'completed',
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      saleDate: json['saleDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      customer: json['customer'] != null
          ? CustomerRef.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'organizationId': organizationId,
      if (shopId != null) 'shopId': shopId,
      if (customerId != null) 'customerId': customerId,
      'invoiceNumber': invoiceNumber, 'status': status,
      'paymentMethod': paymentMethod, 'subtotal': subtotal,
      'discount': discount, 'tax': tax, 'total': total,
      'amountPaid': amountPaid,
      if (notes != null) 'notes': notes,
      'saleDate': saleDate,
      'createdAt': createdAt, 'updatedAt': updatedAt,
    };
  }

  double get changeDue => total - amountPaid;
  bool get isPaid => amountPaid >= total;
}

class CustomerRef {
  final String id;
  final String name;
  final String? phone;

  const CustomerRef({required this.id, required this.name, this.phone});

  factory CustomerRef.fromJson(Map<String, dynamic> json) {
    return CustomerRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }
}

class SupplierRef {
  final String id;
  final String name;
  final String? phone;

  const SupplierRef({required this.id, required this.name, this.phone});

  factory SupplierRef.fromJson(Map<String, dynamic> json) {
    return SupplierRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }
}