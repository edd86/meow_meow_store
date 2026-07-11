class CashRegisterSession {
  final String id;
  final String cashRegisterId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double openingAmount;
  final double? closingAmount;
  final String status;

  const CashRegisterSession({
    required this.id,
    required this.cashRegisterId,
    required this.openedAt,
    this.closedAt,
    required this.openingAmount,
    this.closingAmount,
    required this.status,
  });

  factory CashRegisterSession.fromJson(Map<String, dynamic> json) {
    return CashRegisterSession(
      id: json['id'] as String,
      cashRegisterId: json['cash_register_id'] as String,
      openedAt: DateTime.parse(json['opened_at'] as String).toLocal(),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String).toLocal()
          : null,
      openingAmount: (json['opening_amount'] as num).toDouble(),
      closingAmount: json['closing_amount'] != null
          ? (json['closing_amount'] as num).toDouble()
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash_register_id': cashRegisterId,
      'opening_amount': openingAmount,
      'closing_amount': closingAmount,
      'status': status,
    };
  }

  CashRegisterSession copyWith({
    String? id,
    String? cashRegisterId,
    DateTime? openedAt,
    DateTime? closedAt,
    double? openingAmount,
    double? closingAmount,
    String? status,
  }) {
    return CashRegisterSession(
      id: id ?? this.id,
      cashRegisterId: cashRegisterId ?? this.cashRegisterId,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openingAmount: openingAmount ?? this.openingAmount,
      closingAmount: closingAmount ?? this.closingAmount,
      status: status ?? this.status,
    );
  }

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';
}
