class OrderFee {
  final String? id;
  final String? name;
  final double? amount;
  final String? type;

  OrderFee({
    this.id,
    this.name,
    this.amount,
    this.type,
  });

  factory OrderFee.fromJson(Map<String, dynamic> json) {
    return OrderFee(
      id: json['id']?.toString(),
      name: json['name'],
      amount: json['amount']?.toDouble(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
    };
  }
}