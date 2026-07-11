class Purchase {
  final String id;
  final String? supplierName;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<PurchaseItem>? items;

  const Purchase({
    required this.id,
    this.supplierName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.items,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      supplierName: json['supplier_name'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_name': supplierName,
      'total_amount': totalAmount,
      'status': status,
    };
  }

  Purchase copyWith({
    String? id,
    String? supplierName,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    List<PurchaseItem>? items,
  }) {
    return Purchase(
      id: id ?? this.id,
      supplierName: supplierName ?? this.supplierName,
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

class PurchaseItem {
  final String id;
  final String purchaseId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] as String,
      purchaseId: json['purchase_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchase_id': purchaseId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}
