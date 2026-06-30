class Organization {
  final String id;
  final String name;
  final String slug;
  final String role;
  final String? currency;
  final String? country;
  final String? subscriptionPlan;
  final String? subscriptionStatus;
  final String? businessType;
  final String? description;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? logoUrl;

  const Organization({
    required this.id,
    required this.name,
    required this.slug,
    required this.role,
    this.currency,
    this.country,
    this.subscriptionPlan,
    this.subscriptionStatus,
    this.businessType,
    this.description,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.phone,
    this.logoUrl,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      role: json['role'] as String? ?? '',
      currency: json['currency'] as String?,
      country: json['country'] as String?,
      subscriptionPlan: json['subscriptionPlan'] as String?,
      subscriptionStatus: json['subscriptionStatus'] as String?,
      businessType: json['businessType'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'name': name, 'slug': slug, 'role': role,
      if (currency != null) 'currency': currency,
      if (country != null) 'country': country,
      if (subscriptionPlan != null) 'subscriptionPlan': subscriptionPlan,
      if (subscriptionStatus != null) 'subscriptionStatus': subscriptionStatus,
      if (businessType != null) 'businessType': businessType,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (phone != null) 'phone': phone,
      if (logoUrl != null) 'logoUrl': logoUrl,
    };
  }

  Organization copyWith({
    String? id, String? name, String? slug, String? role,
    String? currency, String? country, String? subscriptionPlan,
    String? subscriptionStatus, String? businessType, String? description,
    String? address, String? city, double? latitude, double? longitude,
    String? phone, String? logoUrl,
  }) {
    return Organization(
      id: id ?? this.id, name: name ?? this.name,
      slug: slug ?? this.slug, role: role ?? this.role,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      businessType: businessType ?? this.businessType,
      description: description ?? this.description,
      address: address ?? this.address, city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone, logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}