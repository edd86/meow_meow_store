class Product {
  final String id;
  final String? categoryId;
  final String name;
  final String? barcodeQr;
  final String? description;
  final double buyingPrice;
  final double sellingPrice;
  final int stockQuantity;
  final DateTime createdAt;

  const Product({
    required this.id,
    this.categoryId,
    required this.name,
    this.barcodeQr,
    this.description,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      barcodeQr: json['barcode_qr'] as String?,
      description: json['description'] as String?,
      buyingPrice: (json['buying_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'barcode_qr': barcodeQr,
      'description': description,
      'buying_price': buyingPrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
    };
  }

  Product copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? barcodeQr,
    String? description,
    double? buyingPrice,
    double? sellingPrice,
    int? stockQuantity,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      barcodeQr: barcodeQr ?? this.barcodeQr,
      description: description ?? this.description,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get profitMargin => sellingPrice > 0
      ? ((sellingPrice - buyingPrice) / sellingPrice) * 100
      : 0;

  bool get isLowStock => stockQuantity <= 5;
}
