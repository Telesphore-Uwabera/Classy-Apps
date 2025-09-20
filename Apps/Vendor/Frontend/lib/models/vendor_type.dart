class VendorType {
  final String? id;
  final String? name;
  final String? slug;
  final String? description;

  VendorType({
    this.id,
    this.name,
    this.slug,
    this.description,
  });

  factory VendorType.fromJson(Map<String, dynamic> json) {
    return VendorType(
      id: json['id']?.toString(),
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
    };
  }
}