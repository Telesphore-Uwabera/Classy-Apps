class PaymentMethod {
  final String id;
  final String name;
  final String type;
  final bool enabled;
  final String icon;
  final String? description;
  final String? photo;
  final String? slug;
  final int? isCash;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.enabled,
    required this.icon,
    this.description,
    this.photo,
    this.slug,
    this.isCash,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      enabled: json['enabled'] ?? false,
      icon: json['icon'] ?? '',
      description: json['description'],
      photo: json['photo'],
      slug: json['slug'],
      isCash: json['is_cash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'enabled': enabled,
      'icon': icon,
      'description': description,
      'photo': photo,
      'slug': slug,
      'is_cash': isCash,
    };
  }

  // Static methods for the three supported payment methods
  static PaymentMethod eversend() {
    return PaymentMethod(
      id: 'eversend',
      name: 'Eversend',
      type: 'eversend',
      enabled: true,
      icon: 'assets/images/eversend.png',
      description: 'Send money globally with Eversend',
    );
  }

  static PaymentMethod momo() {
    return PaymentMethod(
      id: 'momo',
      name: 'Mobile Money',
      type: 'momo',
      enabled: true,
      icon: 'assets/images/momo.png',
      description: 'Pay with Mobile Money (MTN, Airtel, etc.)',
    );
  }

  static PaymentMethod card() {
    return PaymentMethod(
      id: 'card',
      name: 'Card Payment',
      type: 'card',
      enabled: true,
      icon: 'assets/images/card.png',
      description: 'Pay with your debit or credit card',
    );
  }
}