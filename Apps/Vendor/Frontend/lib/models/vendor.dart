import 'vendor_type.dart';

class Vendor {
  final String? id;
  final String? name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? logo;
  final bool? isActive;
  final VendorType? vendorType;

  Vendor({
    this.id,
    this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.logo,
    this.isActive,
    this.vendorType,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id']?.toString(),
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      logo: json['logo'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      vendorType: json['vendor_type'] != null ? VendorType.fromJson(json['vendor_type']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'logo': logo,
      'is_active': isActive,
      'vendor_type': vendorType?.toJson(),
    };
  }
}