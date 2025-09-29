import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/constants/app_strings.dart';

class AuthServices {
  static Future<bool> authenticated() async {
    final token = LocalStorageService.getString(AppStrings.userToken);
    return token != null && token.isNotEmpty;
  }
  
  static Future<void> saveUserToken(String token) async {
    await LocalStorageService.setString(AppStrings.userToken, token);
  }
  
  static Future<String?> getUserToken() async {
    return LocalStorageService.getString(AppStrings.userToken);
  }
  
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await LocalStorageService.setString(AppStrings.userData, userData.toString());
  }
  
  static Future<Map<String, dynamic>?> getUserData() async {
    final userDataString = LocalStorageService.getString(AppStrings.userData);
    if (userDataString != null) {
      // Parse the user data string back to Map
      // This is a simplified version - you might want to use JSON encoding/decoding
      return {};
    }
    return null;
  }
  
  static Future<Map<String, dynamic>?> getCurrentUser({bool force = false}) async {
    if (force) {
      // Force refresh user data from server
      return await getUserData();
    }
    return await getUserData();
  }
  
  static Future<void> logout() async {
    await LocalStorageService.remove(AppStrings.userToken);
    await LocalStorageService.remove(AppStrings.userData);
  }
  
  static bool firstTimeOnApp() {
    return LocalStorageService.getBool(AppStrings.firstTime) ?? true;
  }
  
  static Future<void> firstTimeCompleted() async {
    await LocalStorageService.setBool(AppStrings.firstTime, false);
  }
}