import 'user_role.dart';

class User {
  int id;
  int? vendor_id;
  String name;
  String? email;
  String phone;
  String? rawPhone;
  String? countryCode;
  String photo;
  String role;
  bool isOnline;
  bool hasMultipleVendors;
  List<UserRole> roles;

  User({
    required this.id,
    required this.vendor_id,
    required this.name,
    this.email,
    required this.phone,
    required this.photo,
    required this.role,
    required this.isOnline,
    this.rawPhone,
    this.countryCode,
    //for vendor profile switcher
    this.hasMultipleVendors = false,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      vendor_id: int.tryParse(json['vendor_id']?.toString() ?? '0'),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      rawPhone: json['raw_phone'],
      countryCode: json['country_code'],
      photo: json['photo'] ?? "",
      role: json['role_name'] ?? "client",
      isOnline: json['is_online'] == null ? false : json['is_online'] == 1,
      hasMultipleVendors: json['has_multiple_vendors'] != null
          ? (json['has_multiple_vendors'] ?? false)
          : false,
      //roles
      roles: json['roles'] != null
          ? List<UserRole>.from(
              json['roles'].map(
                (x) => UserRole.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendor_id,
      'name': name,
      'email': email,
      'phone': phone,
      'raw_phone': rawPhone,
      'country_code': countryCode,
      'photo': photo,
      'role_name': role,
      'is_online': isOnline,
      'has_multiple_vendors': hasMultipleVendors,
      //roles
      'roles': List<dynamic>.from(
        roles.map(
          (x) => (x as UserRole).toJson(),
        ),
      ),
    };
  }

  // Additional properties for compatibility
  String get userType => role;
  
  //getters
  List<String> get allPermissions {
    List<String> permissions = [];
    for (var role in roles) {
      for (var permission in role.permissions) {
        permissions.add(permission.toString());
      }
    }
    return permissions;
  }

  // Additional methods for compatibility
  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User.fromJson(map);
  }
}
