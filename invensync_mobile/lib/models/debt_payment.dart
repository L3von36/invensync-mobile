class DebtPayment {
  final String id;
  final String debtId;
  final double amount;
  final String paymentMethod;
  final String? notes;
  final String paidAt;

  const DebtPayment({
    required this.id, required this.debtId,
    required this.amount, required this.paymentMethod,
    this.notes, required this.paidAt,
  });

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
      id: json['id'] as String? ?? '',
      debtId: json['debtId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      notes: json['notes'] as String?,
      paidAt: json['paidAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'debtId': debtId, 'amount': amount,
      'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
      'paidAt': paidAt,
    };
  }
}