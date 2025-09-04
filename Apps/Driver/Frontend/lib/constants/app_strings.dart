import 'dart:convert';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:supercharged/supercharged.dart';

class AppStrings {
  // App Branding
  static String get appName => "Classy Driver";
  static String get companyName => "Classy Provider";
  static String get appTagline => "Connecting Providers to Opportunities";
  static String get googleMapApiKey => env('google_maps_key');
  static String get fcmApiKey => env('fcm_key');
  static String get currencySymbol => env('currency') ?? "UGX";
  static String get countryCode => env('country_code') ?? "UG";

  // Authentication & Security
  static bool get enableOtp => env('enble_otp') == "1";
  static bool get enableOTPLogin => env('enableOTPLogin') == "1";
  static bool get enableEmailLogin => env('enableEmailLogin') ?? false;
  static bool get enableProfileUpdate => env('enableProfileUpdate') ?? true;

  // Driver Features
  static bool get enableProofOfDelivery => env('enableProofOfDelivery') == "1";
  static bool get signatureVerify =>
      env('orderVerificationType') == "signature";
  static bool get verifyOrderByPhoto => env('orderVerificationType') == "photo";
  static bool get enableDriverWallet => env('enableDriverWallet') == "1";
  static bool get enableChat => env('enableChat') == "1";
  static bool get partnersCanRegister =>
      ["1", 1].contains(env('partnersCanRegister'));
  static double get driverSearchRadius =>
      double.parse((env('driverSearchRadius') ?? 10).toString());
  static int get maxDriverOrderAtOnce =>
      int.parse((env('maxDriverOrderAtOnce') ?? 1).toString());

  // Location & Tracking
  static double get distanceCoverLocationUpdate =>
      double.parse((env('distanceCoverLocationUpdate') ?? 10).toString());
  static int get timePassLocationUpdate =>
      int.parse((env('timePassLocationUpdate') ?? 10).toString());

  // Alerts & Notifications
  static int get alertDuration {
    final duration = env('alertDuration').toString().toInt();
    if (duration == null || duration < 10) {
      return 10;
    }
    return duration;
  }

  // Driver Assignment System
  static bool get driverMatchingNewSystem =>
      ((env('autoassignmentsystem') ?? 0) == 1);

  static bool get useWebsocketAssignment {
    return (env('useWebsocketAssignment') ?? false);
  }

  // OTP & Authentication
  static String get otpGateway => env('otpGateway') ?? "none";
  static bool get isFirebaseOtp => otpGateway.toLowerCase() == "firebase";
  static bool get isCustomOtp =>
      !["none", "firebase"].contains(otpGateway.toLowerCase());
  static String get emergencyContact => env('emergencyContact') ?? "999";

  // UI Configuration
  static dynamic get uiConfig {
    return env('ui') ?? null;
  }

  static bool get qrcodeLogin => env('auth')?['qrcodeLogin'] ?? false;

  // Notification Channel
  static const String notificationChannel = "high_importance_channel";

  // Local Storage Keys (DON'T TOUCH)
  static const String firstTimeOnApp = "first_time";
  static const String authenticated = "authenticated";
  static const String userAuthToken = "auth_token";
  static const String userKey = "user";
  static const String driverVehicleKey = "driver_vehicle";
  static const String appLocale = "locale";
  static const String notificationsKey = "notifications";
  static const String appCurrency = "currency";
  static const String appColors = "colors";
  static const String appRemoteSettings = "appRemoteSettings";
  static const String onlineOnApp = "online";

  // App Store IDs
  static String appStoreId = "";

  // Emergency & Support
  static const String supportHotline = "+256 700 123456";
  static const String policeHotline = "999";
  static const String ambulanceHotline = "912";

  // Driver Status
  static const String statusOnline = "online";
  static const String statusOffline = "offline";
  static const String statusBusy = "busy";
  static const String statusAvailable = "available";

  // Vehicle Types
  static const String vehicleTypeCar = "car";
  static const String vehicleTypeBoda = "boda";
  static const String vehicleTypeTruck = "truck";

  // Document Status
  static const String documentStatusPending = "pending";
  static const String documentStatusVerified = "verified";
  static const String documentStatusRejected = "rejected";

  // Saving
  static Future<bool> saveAppSettingsToLocalStorage(String colorsMap) async {
    return await LocalStorageService.prefs!.setString(
      AppStrings.appRemoteSettings,
      colorsMap,
    );
  }

  static dynamic appSettingsObject;

  static Future<void> getAppSettingsFromLocalStorage() async {
    appSettingsObject = LocalStorageService.prefs!.getString(
      AppStrings.appRemoteSettings,
    );
    if (appSettingsObject != null) {
      appSettingsObject = jsonDecode(appSettingsObject);
    }
  }

  static dynamic env(String ref) {
    getAppSettingsFromLocalStorage();
    return appSettingsObject != null ? appSettingsObject[ref] : "";
  }
}
