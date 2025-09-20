class PackageType {
  final String? id;
  final String? name;
  final String? description;

  PackageType({
    this.id,
    this.name,
    this.description,
  });

  factory PackageType.fromJson(Map<String, dynamic> json) {
    return PackageType(
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