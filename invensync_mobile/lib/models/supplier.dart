class Supplier {
  final String id;
  final String organizationId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? shopId;
  final String createdAt;
  final String updatedAt;

  const Supplier({
    required this.id, required this.organizationId, required this.name,
    this.email, this.phone, this.address, this.shopId,
    required this.createdAt, required this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      shopId: json['shopId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
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

  Supplier copyWith({
    String? id, String? organizationId, String? name,
    String? email, String? phone, String? address, String? shopId,
    String? createdAt, String? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id, organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name, email: email ?? this.email,
      phone: phone ?? this.phone, address: address ?? this.address,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}