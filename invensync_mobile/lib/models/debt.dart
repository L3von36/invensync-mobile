import 'debt_payment.dart';

class Debt {
  final String id;
  final String organizationId;
  final String? customerId;
  final String? supplierId;
  final String type;
  final double amount;
  final double paidAmount;
  final String? dueDate;
  final String status;
  final String? description;
  final String? shopId;
  final String createdAt;
  final String updatedAt;
  final CustomerRef? customer;
  final SupplierRef? supplier;
  final List<DebtPayment>? payments;

  const Debt({
    required this.id, required this.organizationId,
    this.customerId, this.supplierId, required this.type,
    required this.amount, required this.paidAmount, this.dueDate,
    required this.status, this.description, this.shopId,
    required this.createdAt, required this.updatedAt,
    this.customer, this.supplier, this.payments,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      customerId: json['customerId'] as String?,
      supplierId: json['supplierId'] as String?,
      type: json['type'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] as String?,
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String?,
      shopId: json['shopId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      customer: json['customer'] != null
          ? CustomerRef.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      supplier: json['supplier'] != null
          ? SupplierRef.fromJson(json['supplier'] as Map<String, dynamic>)
          : null,
      payments: (json['payments'] as List<dynamic>?)
          ?.map((e) => DebtPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'organizationId': organizationId,
      if (customerId != null) 'customerId': customerId,
      if (supplierId != null) 'supplierId': supplierId,
      'type': type, 'amount': amount, 'paidAmount': paidAmount,
      if (dueDate != null) 'dueDate': dueDate,
      'status': status,
      if (description != null) 'description': description,
      if (shopId != null) 'shopId': shopId,
      'createdAt': createdAt, 'updatedAt': updatedAt,
    };
  }

  double get remainingAmount => amount - paidAmount;
  bool get isPaid => paidAmount >= amount;
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(DateTime.parse(dueDate!)) && !isPaid;
  }
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