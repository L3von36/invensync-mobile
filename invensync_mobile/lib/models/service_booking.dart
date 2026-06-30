class ServiceBookingServiceTypeRef {
  final String id;
  final String name;
  final int duration;
  final double price;

  const ServiceBookingServiceTypeRef({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
  });

  factory ServiceBookingServiceTypeRef.fromJson(Map<String, dynamic> json) {
    return ServiceBookingServiceTypeRef(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
    };
  }

  ServiceBookingServiceTypeRef copyWith({
    String? id,
    String? name,
    int? duration,
    double? price,
  }) {
    return ServiceBookingServiceTypeRef(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceBookingServiceTypeRef &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ServiceBookingCustomerRef {
  final String id;
  final String name;
  final String? phone;

  const ServiceBookingCustomerRef({
    required this.id,
    required this.name,
    this.phone,
  });

  factory ServiceBookingCustomerRef.fromJson(Map<String, dynamic> json) {
    return ServiceBookingCustomerRef(
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

  ServiceBookingCustomerRef copyWith({String? id, String? name, String? phone}) {
    return ServiceBookingCustomerRef(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceBookingCustomerRef &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ServiceBooking {
  final String id;
  final String organizationId;
  final String serviceTypeId;
  final String? customerId;
  final String customerName;
  final String? customerPhone;
  final String status;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final ServiceBookingServiceTypeRef? serviceType;
  final ServiceBookingCustomerRef? customer;

  const ServiceBooking({
    required this.id,
    required this.organizationId,
    required this.serviceTypeId,
    this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.status,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.serviceType,
    this.customer,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      serviceTypeId: json['serviceTypeId'] as String? ?? '',
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String?,
      status: json['status'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      serviceType: json['serviceType'] != null
          ? ServiceBookingServiceTypeRef.fromJson(
              json['serviceType'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] != null
          ? ServiceBookingCustomerRef.fromJson(
              json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'serviceTypeId': serviceTypeId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'status': status,
      'bookingDate': bookingDate,
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'serviceType': serviceType?.toJson(),
      'customer': customer?.toJson(),
    };
  }

  ServiceBooking copyWith({
    String? id,
    String? organizationId,
    String? serviceTypeId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? status,
    String? bookingDate,
    String? startTime,
    String? endTime,
    String? notes,
    String? createdAt,
    String? updatedAt,
    ServiceBookingServiceTypeRef? serviceType,
    ServiceBookingCustomerRef? customer,
  }) {
    return ServiceBooking(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceType: serviceType ?? this.serviceType,
      customer: customer ?? this.customer,
    );
  }

  @override
  String toString() =>
      'ServiceBooking(id: $id, status: $status, date: $bookingDate)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceBooking &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}