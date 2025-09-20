class PaymentMethod {
  final String? id;
  final String? name;
  final String? slug;
  final int? isCash;

  PaymentMethod({
    this.id,
    this.name,
    this.slug,
    this.isCash,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString(),
      name: json['name'],
      slug: json['slug'],
      isCash: json['is_cash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'is_cash': isCash,
    };
  }
}