class Expense {
  final String id;
  final String organizationId;
  final String? shopId;
  final String category;
  final String? description;
  final double amount;
  final String date;
  final String createdAt;
  final String updatedAt;

  const Expense({
    required this.id, required this.organizationId,
    this.shopId, required this.category, this.description,
    required this.amount, required this.date,
    required this.createdAt, required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'organizationId': organizationId,
      if (shopId != null) 'shopId': shopId,
      'category': category,
      if (description != null) 'description': description,
      'amount': amount, 'date': date,
      'createdAt': createdAt, 'updatedAt': updatedAt,
    };
  }
}