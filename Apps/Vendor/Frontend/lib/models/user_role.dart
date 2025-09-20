import 'dart:convert';

class UserRole {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserRole.fromMap(Map<String, dynamic> map) {
    return UserRole.fromJson(map);
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  UserRole copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserRole(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}