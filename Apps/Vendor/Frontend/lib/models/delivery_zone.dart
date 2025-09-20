class DeliveryZone {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String coverageArea;
  final double deliveryFee;
  final double minOrderAmount;
  final int estimatedDeliveryTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryZone({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.coverageArea,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.estimatedDeliveryTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryZone.fromMap(Map<String, dynamic> map) {
    return DeliveryZone(
      id: map['id'] ?? '',
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      coverageArea: map['coverageArea'] ?? '',
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      minOrderAmount: (map['minOrderAmount'] ?? 0.0).toDouble(),
      estimatedDeliveryTime: map['estimatedDeliveryTime'] ?? 30,
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
      'coverageArea': coverageArea,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  DeliveryZone copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    String? coverageArea,
    double? deliveryFee,
    double? minOrderAmount,
    int? estimatedDeliveryTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryZone(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverageArea: coverageArea ?? this.coverageArea,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
