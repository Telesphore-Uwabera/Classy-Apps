import 'package:Classy/models/user.dart';
import 'package:Classy/models/vehicle.dart';

class Driver extends User {
  Vehicle? vehicle;
  double? rating;

  Driver({
    required String id,
    String? code,
    required String name,
    required String email,
    required String phone,
    String? rawPhone,
    required String countryCode,
    required String photo,
    required String role,
    // Wallet functionality removed
    this.vehicle,
    this.rating,
  }) : super(
          id: id,
          code: code,
          name: name,
          email: email,
          phone: phone,
          rawPhone: rawPhone,
          countryCode: countryCode,
          photo: photo,
          role: role,
          // Wallet functionality removed
        );

  //create fatory method to convert json to object
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? "",
      name: json['name'],
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      countryCode: json['country_code'] ?? "",
      photo: json['photo'] ?? "",
      role: json['role_name'] ?? "driver",
      rating: double.tryParse(json['rating'].toString()) ?? 3,
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      //
      rawPhone: json['raw_phone'],
      // Wallet functionality removed
    );
  }
}
