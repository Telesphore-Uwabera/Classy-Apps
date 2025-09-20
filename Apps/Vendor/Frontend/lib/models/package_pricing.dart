class PackagePricing {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double basePrice;
  final double pricePerKm;
  final double pricePerKg;
  final double minPrice;
  final double maxPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackagePricing({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.pricePerKm,
    required this.pricePerKg,
    required this.minPrice,
    required this.maxPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackagePricing.fromMap(Map<String, dynamic> map) {
    return PackagePricing(
      id: map['id'] ?? '',
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      pricePerKm: (map['pricePerKm'] ?? 0.0).toDouble(),
      pricePerKg: (map['pricePerKg'] ?? 0.0).toDouble(),
      minPrice: (map['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (map['maxPrice'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'pricePerKm': pricePerKm,
      'pricePerKg': pricePerKg,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  PackagePricing copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    double? basePrice,
    double? pricePerKm,
    double? pricePerKg,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PackagePricing(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate price based on distance and weight
  double calculatePrice(double distanceKm, double weightKg) {
    double totalPrice = basePrice + (distanceKm * pricePerKm) + (weightKg * pricePerKg);
    return totalPrice.clamp(minPrice, maxPrice);
  }
}
