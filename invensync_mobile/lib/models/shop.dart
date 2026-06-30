class Shop {
  final String id;
  final String organizationId;
  final String name;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final bool isActive;
  final int? memberCount;

  const Shop({
    required this.id, required this.organizationId, required this.name,
    this.address, this.city, this.latitude, this.longitude,
    this.phone, required this.isActive, this.memberCount,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      memberCount: (json['memberCount'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'organizationId': organizationId, 'name': name,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (phone != null) 'phone': phone,
      'isActive': isActive,
      if (memberCount != null) 'memberCount': memberCount,
    };
  }
}