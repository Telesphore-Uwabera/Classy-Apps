class User {
  String id; // Changed from int to String for Firebase UID compatibility

  String name;
  String? code;
  String email;
  String phone;
  String? rawPhone;
  String? countryCode;
  String photo;
  String role;
  // Wallet functionality removed - using Eversend, MoMo, and card payments only

  User({
    required this.id,
    this.code,
    required this.name,
    this.email = "",
    required this.phone,
    this.rawPhone,
    this.countryCode,
    this.photo = "",
    required this.role,
    // Wallet functionality removed
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      code: json['code'],
      name: json['name'] ?? '',
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      rawPhone: json['raw_phone'],
      // Wallet functionality removed
      countryCode: json['country_code'],
      photo: json['photo'] ?? "",
      role: json['role'] ?? json['role_name'] ?? "client",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'email': email,
      'phone': phone,
      'raw_phone': rawPhone,
      'country_code': countryCode,
      'photo': photo,
      'role_name': role,
      // Wallet functionality removed
    };
  }
}
