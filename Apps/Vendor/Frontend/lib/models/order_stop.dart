class OrderStop {
  final String? id;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  OrderStop({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory OrderStop.fromJson(Map<String, dynamic> json) {
    return OrderStop(
      id: json['id']?.toString(),
      name: json['name'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}