// To parse this JSON data, do
//
//     final paymentAccount = paymentAccountFromJson(jsonString);

import 'dart:convert';
import 'package:supercharged/supercharged.dart';

PaymentAccount paymentAccountFromJson(String str) =>
    PaymentAccount.fromJson(json.decode(str));

String paymentAccountToJson(PaymentAccount data) => json.encode(data.toJson());

class PaymentAccount {
  PaymentAccount({
    required this.name,
    required this.number,
    required this.instructions,
    required this.isActive,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.formattedDate,
    required this.formattedUpdatedDate,
    this.accountType = 'bank',
    this.accountName = '',
    this.accountNumber = '',
    this.routingNumber = '',
    this.bankName = '',
    this.email = '',
    this.phone = '',
    this.isDefault = false,
    this.isVerified = false,
  });

  String name;
  String number;
  String instructions;
  bool isActive;
  DateTime updatedAt;
  DateTime createdAt;
  int id;
  String formattedDate;
  String formattedUpdatedDate;
  String accountType;
  String accountName;
  String accountNumber;
  String routingNumber;
  String bankName;
  String email;
  String phone;
  bool isDefault;
  bool isVerified;

  factory PaymentAccount.fromJson(Map<String, dynamic> json) => PaymentAccount(
        name: json["name"],
        number: json["number"],
        instructions: json["instructions"] == null ? '' : json["instructions"],
        isActive: json["is_active"].toString().toInt() == 1,
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
        formattedDate: json["formatted_date"],
        formattedUpdatedDate: json["formatted_updated_date"],
        accountType: json["account_type"] ?? 'bank',
        accountName: json["account_name"] ?? json["name"] ?? '',
        accountNumber: json["account_number"] ?? json["number"] ?? '',
        routingNumber: json["routing_number"] ?? '',
        bankName: json["bank_name"] ?? '',
        email: json["email"] ?? '',
        phone: json["phone"] ?? '',
        isDefault: json["is_default"] == true || json["is_default"] == 1,
        isVerified: json["is_verified"] == true || json["is_verified"] == 1,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "number": number,
        "is_active": isActive ? "1" : "0",
        "instructions": instructions,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "id": id,
        "formatted_date": formattedDate,
        "formatted_updated_date": formattedUpdatedDate,
        "account_type": accountType,
        "account_name": accountName,
        "account_number": accountNumber,
        "routing_number": routingNumber,
        "bank_name": bankName,
        "email": email,
        "phone": phone,
        "is_default": isDefault,
        "is_verified": isVerified,
      };

  // Additional getters for compatibility
  String get accountTypeIcon {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return '🏦';
      case 'paypal':
        return '💳';
      case 'stripe':
        return '💳';
      case 'cashapp':
        return '💰';
      default:
        return '💳';
    }
  }

  String get accountTypeDisplayName {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return 'Bank Account';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'cashapp':
        return 'Cash App';
      default:
        return 'Payment Account';
    }
  }

  String get accountHolderName => accountName.isNotEmpty ? accountName : name;
  
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '****' + accountNumber.substring(accountNumber.length - 4);
  }

  // CopyWith method
  PaymentAccount copyWith({
    String? name,
    String? number,
    String? instructions,
    bool? isActive,
    DateTime? updatedAt,
    DateTime? createdAt,
    int? id,
    String? formattedDate,
    String? formattedUpdatedDate,
    String? accountType,
    String? accountName,
    String? accountNumber,
    String? routingNumber,
    String? bankName,
    String? email,
    String? phone,
    bool? isDefault,
    bool? isVerified,
  }) {
    return PaymentAccount(
      name: name ?? this.name,
      number: number ?? this.number,
      instructions: instructions ?? this.instructions,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      formattedDate: formattedDate ?? this.formattedDate,
      formattedUpdatedDate: formattedUpdatedDate ?? this.formattedUpdatedDate,
      accountType: accountType ?? this.accountType,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      routingNumber: routingNumber ?? this.routingNumber,
      bankName: bankName ?? this.bankName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
