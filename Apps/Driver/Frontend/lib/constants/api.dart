// Firebase-only API configuration - No Laravel backend
import 'package:flutter/foundation.dart';

class Api {
  // ===== FIREBASE CONFIGURATION =====
  static const bool useMockData = false;
  
  // ===== NODE.JS API BACKEND =====
  static String get baseUrl {
    if (kDebugMode) {
      return "http://localhost:8000/api";
    } else {
      return "https://api.classy.app/api";
    }
  }
  
  static bool get isDevelopment => false;
  
  static String get apiStatus {
    return "Node.js API Mode - Connected to Firebase Backend via Node.js";
  }

  // ===== FIRESTORE COLLECTIONS =====
  static const String usersCollection = "users";
  static const String driversCollection = "drivers";
  static const String ordersCollection = "orders";
  static const String vehiclesCollection = "vehicles";
  static const String earningsCollection = "earnings";
  static const String paymentsCollection = "payments";
  static const String settingsCollection = "settings";
  static const String notificationsCollection = "notifications";
  static const String chatsCollection = "chats";
  static const String reportsCollection = "reports";

  // ===== AUTH ENDPOINTS =====
  static String get login => "auth/login";
  static String get driverRegister => "auth/driver-register";
  static String get verifyFirebaseOtp => "auth/verify-firebase-otp";
  static String get qrlogin => "auth/qr-login";
  static String get forgotPassword => "auth/forgot-password";
  static String get logout => "auth/logout";
  static String get updateProfile => "auth/update-profile";
  static String get updatePassword => "auth/update-password";
  static String get verifyPhoneAccount => "auth/verify-phone";
  static String get sendOtp => "auth/send-otp";
  static String get verifyOtp => "auth/verify-otp";
  static String get myProfile => "auth/my-profile";
  static String get accountDelete => "auth/delete-account";
  static String get documentSubmission => "auth/documents";

  // ===== DRIVER ENDPOINTS =====
  static String get driverLocationSync => "driver/location-sync";
  static String get updateDriverStatus => "driver/update-status";
  static String get getAvailableDrivers => "driver/available";
  static String get acceptRideRequest => "driver/accept-ride";
  static String get rejectRideRequest => "driver/reject-ride";
  static String get completeRide => "driver/complete-ride";

  // ===== DRIVER TYPE ENDPOINTS =====
  static String get driverTypeSwitch => "driver/type-switch";

  // ===== EARNING ENDPOINTS =====
  static String get earning => "earning";

  // ===== GENERAL ENDPOINTS =====
  static String get vehicleTypes => "general/vehicle-types";
  static String get carMakes => "general/car-makes";
  static String get carModels => "general/car-models";

  // ===== ORDER ENDPOINTS =====
  static String get orders => "orders";
  static String get orderStopVerification => "orders/stop-verification";
  static String get acceptTaxiBookingAssignment => "orders/accept-taxi-booking";

  // ===== PAYMENT ENDPOINTS =====
  static String get paymentAccount => "payment/account";
  static String get payoutRequest => "payment/payout";

  // ===== REPORT ENDPOINTS =====
  static String get payoutsReport => "reports/payouts";
  static String get earningsReport => "reports/earnings";
  static String get driverMetrics => "reports/driver-metrics";

  // ===== SETTINGS ENDPOINTS =====
  static String get appSettings => "settings/app";
  static String get appOnboardings => "settings/onboardings";

  // ===== TAXI ENDPOINTS =====
  static String get currentTaxiBooking => "taxi/current-booking";
  static String get cancelTaxiBooking => "taxi/cancel-booking";
  static String get rating => "taxi/rating";
  static String get rejectTaxiBookingAssignment => "taxi/reject-booking";

  // ===== VEHICLE ENDPOINTS =====
  static String get vehicles => "vehicles";
  static String get driverVehicleRegister => "vehicles/register";
  static String get activateVehicle => "vehicles/activate";

  // ===== WALLET ENDPOINTS =====
  static String get walletBalance => "wallet/balance";
  static String get walletTopUp => "wallet/top-up";
  static String get walletTransactions => "wallet/transactions";
  static String get transferWalletBalance => "wallet/transfer";

  // ===== CHAT ENDPOINTS =====
  static String get chat => "chat";

  // ===== PROFILE ENDPOINTS =====
  static String get faqs => "profile/faqs";
  static String get privacyPolicy => "profile/privacy";
  static String get terms => "profile/terms";
  static String get contactUs => "profile/contact";
  static String get inappSupport => "profile/support";
}