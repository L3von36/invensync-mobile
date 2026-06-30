class Notification {
  final String id;
  final String organizationId;
  final String? userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  const Notification({
    required this.id, required this.organizationId,
    this.userId, required this.title, required this.message,
    required this.type, required this.isRead, required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      userId: json['userId'] as String?,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Notification copyWith({bool? isRead}) {
    return Notification(
      id: id, organizationId: organizationId, userId: userId,
      title: title, message: message, type: type,
      isRead: isRead ?? this.isRead, createdAt: createdAt,
    );
  }
}