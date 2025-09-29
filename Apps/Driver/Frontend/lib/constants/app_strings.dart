import 'package:fuodz/services/local_storage.service.dart';

class AppStrings {
  static const String appName = "Classy Driver";
  static const String appVersion = "1.0.0";
  static const String companyName = "Classy Inc";
  static const String currencySymbol = "\$";
  static const String countryCode = "US";
  static const String currency = "USD";
  
  // Local storage keys
  static const String appColors = "app_colors";
  static const String appSettings = "app_settings";
  static const String userToken = "user_token";
  static const String userData = "user_data";
  static const String firstTime = "first_time";
  static const String language = "language";
  static const String theme = "theme";
  static const String websocket = "websocket";
  
  // Static method for saving app settings
  static Future<void> saveAppSettingsToLocalStorage(String settingsJson) async {
    await LocalStorageService.setString(appSettings, settingsJson);
  }
}