class Sale {
  final String id;
  final String? customerId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<SaleItem>? items;

  const Sale({
    required this.id,
    this.customerId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      customerId: json['customer_id'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'total_amount': totalAmount,
      'status': status,
    };
  }

  Sale copyWith({
    String? id,
    String? customerId,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] as String,
      saleId: json['sale_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}
