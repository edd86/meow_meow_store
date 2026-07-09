class CashRegister {
  final String id;
  final String name;
  final double currentBalance;
  final DateTime updatedAt;

  const CashRegister({
    required this.id,
    required this.name,
    required this.currentBalance,
    required this.updatedAt,
  });

  factory CashRegister.fromJson(Map<String, dynamic> json) {
    return CashRegister(
      id: json['id'] as String,
      name: json['name'] as String,
      currentBalance: (json['current_balance'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  CashRegister copyWith({
    String? id,
    String? name,
    double? currentBalance,
    DateTime? updatedAt,
  }) {
    return CashRegister(
      id: id ?? this.id,
      name: name ?? this.name,
      currentBalance: currentBalance ?? this.currentBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
