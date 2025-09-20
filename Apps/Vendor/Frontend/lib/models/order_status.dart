class OrderStatus {
  final String? name;
  final String? message;
  final DateTime? createdAt;

  OrderStatus({
    this.name,
    this.message,
    this.createdAt,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      name: json['name'],
      message: json['message'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}