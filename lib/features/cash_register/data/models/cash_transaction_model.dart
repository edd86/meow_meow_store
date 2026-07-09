class CashTransaction {
  final String id;
  final String sessionId;
  final String transactionType;
  final double amount;
  final String description;
  final String? saleId;
  final String? purchaseId;
  final DateTime createdAt;

  const CashTransaction({
    required this.id,
    required this.sessionId,
    required this.transactionType,
    required this.amount,
    required this.description,
    this.saleId,
    this.purchaseId,
    required this.createdAt,
  });

  factory CashTransaction.fromJson(Map<String, dynamic> json) {
    return CashTransaction(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      transactionType: json['transaction_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      saleId: json['sale_id'] as String?,
      purchaseId: json['purchase_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CashTransaction copyWith({
    String? id,
    String? sessionId,
    String? transactionType,
    double? amount,
    String? description,
    String? saleId,
    String? purchaseId,
    DateTime? createdAt,
  }) {
    return CashTransaction(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      saleId: saleId ?? this.saleId,
      purchaseId: purchaseId ?? this.purchaseId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isIncome => transactionType == 'income';
  bool get isExpense => transactionType == 'expense';
}
