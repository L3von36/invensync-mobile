class Customer {
  final String id;
  final String organizationId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? shopId;
  final String createdAt;
  final String updatedAt;
  final int? salesCount;
  final int? debtsCount;

  const Customer({
    required this.id, required this.organizationId, required this.name,
    this.email, this.phone, this.address, this.shopId,
    required this.createdAt, required this.updatedAt,
    this.salesCount, this.debtsCount,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      shopId: json['shopId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      salesCount: (json['_count']?['sales'] as num?)?.toInt(),
      debtsCount: (json['_count']?['debts'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'organizationId': organizationId, 'name': name,
      'createdAt': createdAt, 'updatedAt': updatedAt,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (shopId != null) 'shopId': shopId,
    };
  }

  Customer copyWith({
    String? id, String? organizationId, String? name,
    String? email, String? phone, String? address, String? shopId,
    String? createdAt, String? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id, organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name, email: email ?? this.email,
      phone: phone ?? this.phone, address: address ?? this.address,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}