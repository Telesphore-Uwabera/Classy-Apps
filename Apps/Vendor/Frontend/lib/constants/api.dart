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
  static const String vendorsCollection = "vendors";
  static const String ordersCollection = "orders";
  static const String productsCollection = "products";
  static const String servicesCollection = "services";
  static const String categoriesCollection = "categories";
  static const String settingsCollection = "settings";
  static const String notificationsCollection = "notifications";
  static const String chatsCollection = "chats";
  static const String paymentsCollection = "payments";
  static const String earningsCollection = "earnings";
  static const String reportsCollection = "reports";

  // ===== AUTH ENDPOINTS =====
  static String get verifyPhoneAccount => "auth/verify-phone";
  static String get newAccount => "auth/register";
  static String get qrlogin => "auth/qr-login";
  static String get forgotPassword => "auth/forgot-password";
  static String get logout => "auth/logout";
  static String get updateProfile => "auth/update-profile";
  static String get updatePassword => "auth/update-password";
  static String get sendOtp => "auth/send-otp";
  static String get verifyOtp => "auth/verify-otp";
  static String get accountDelete => "auth/delete-account";

  // ===== VENDOR ENDPOINTS =====
  static String get vendor => "vendor";
  static String get myVendors => "vendor/my-vendors";
  static String get switchVendor => "vendor/switch";
  static String get salesReport => "vendor/sales-report";
  static String get earningsReport => "vendor/earnings-report";
  static String get vendorAvailability => "vendor/availability";
  static String get documentSubmission => "vendor/documents";
  static String get vendorTypes => "vendor/types";

  // ===== PRODUCT ENDPOINTS =====
  static String get products => "products";
  static String get productCategories => "products/categories";
  static String get productTags => "products/tags";

  // ===== SERVICE ENDPOINTS =====
  static String get services => "services";
  static String get serviceDurations => "services/durations";

  // ===== ORDER ENDPOINTS =====
  static String get orders => "orders";

  // ===== CHAT ENDPOINTS =====
  static String get chat => "chat";

  // ===== PAYMENT ENDPOINTS =====
  static String get paymentAccount => "payment/account";
  static String get payoutRequest => "payment/payout";

  // ===== PACKAGE ENDPOINTS =====
  static String get packagePricing => "package/pricing";
  static String get packageTypes => "package/types";

  // ===== USER ENDPOINTS =====
  static String get users => "users";

  // ===== SETTINGS ENDPOINTS =====
  static String get appSettings => "inter-app/settings";
  static String get appOnboardings => "inter-app/onboardings";

  // ===== GEOCODER ENDPOINTS =====
  static String get geocoderForward => "geocoder/forward";
  static String get geocoderReserve => "geocoder/reverse";
  static String get geocoderPlaceDetails => "geocoder/place-details";
  static String get externalRedirect => "external/redirect";

  // ===== PROFILE ENDPOINTS =====
  static String get faqs => "profile/faqs";
  static String get privacyPolicy => "profile/privacy";
  static String get terms => "profile/terms";
  static String get contactUs => "profile/contact";
  static String get inappSupport => "profile/support";

  // ===== SUBSCRIPTION ENDPOINTS =====
  static String get subscription => "subscription";

  // ===== BACKEND URL =====
  static String get backendUrl => "https://classy.app";

  // ===== REDIRECT AUTH =====
  static String redirectAuth(String token) => "auth/redirect?token=$token";
}