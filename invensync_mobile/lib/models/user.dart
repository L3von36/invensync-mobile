class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? role;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.role,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? role,
    String? phone,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}