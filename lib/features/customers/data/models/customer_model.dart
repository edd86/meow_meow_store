class Customer {
  final String id;
  final String firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.firstName,
    this.lastName,
    this.email,
    this.phone,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
    };
  }

  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get fullName => lastName != null ? '$firstName $lastName' : firstName;
}
