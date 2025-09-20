class OrderService {
  final String? id;
  final String? name;
  final String? description;

  OrderService({
    this.id,
    this.name,
    this.description,
  });

  factory OrderService.fromJson(Map<String, dynamic> json) {
    return OrderService(
      id: json['id']?.toString(),
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}