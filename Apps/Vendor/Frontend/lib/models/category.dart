import 'dart:convert';
import 'product.dart';

class Category {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final bool isActive;
  final List<Product>? products;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.isActive = true,
    this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      products: json['products'] != null
          ? List<Product>.from(
              json['products'].map((x) => Product.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'is_active': isActive,
      'products': products?.map((x) => x.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category.fromJson(map);
  }
}