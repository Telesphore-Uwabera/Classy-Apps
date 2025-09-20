import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/services/firebase.service.dart';
import 'package:Classy/services/firebase_user_profile.service.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/services/unified_auth.service.dart';
import 'package:Classy/view_models/splash.vm.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'local_storage.service.dart';

class AuthServices {
  static final FirebaseUserProfileService _profileService = FirebaseUserProfileService();

  /// Initialize auth services
  static void initialize() {
    _profileService.initialize();
    _migrateExistingUsersToFirestore();
  }

  /// Migrate existing users to Firestore
  static Future<void> _migrateExistingUsersToFirestore() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await UnifiedAuthService.ensureUserExistsInFirestore(currentUser.uid);
      }
    } catch (e) {
      print("❌ Error migrating user to Firestore: $e");
    }
  }

  /// Check if first time on app
  static bool firstTimeOnApp() {
    return LocalStorageService.prefs?.getBool(AppStrings.firstTimeOnApp) ??
        true;
  }

  static firstTimeCompleted() async {
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  //
  static bool authenticated() {
    return LocalStorageService.prefs?.getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<bool> isAuthenticated() async {
    await LocalStorageService.rxPrefs?.write(
      AppStrings.authenticated,
      true,
      (value) {
        return value;
      },
    );
    return LocalStorageService.prefs!.setBool(AppStrings.authenticated, true);
  }

  // Token
  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs?.getString(AppStrings.userAuthToken) ?? "";
  }

  static Future<bool> setAuthBearerToken(token) async {
    return LocalStorageService.prefs!
        .setString(AppStrings.userAuthToken, token);
  }

  //Locale
  static String getLocale() {
    return LocalStorageService.prefs?.getString(AppStrings.appLocale) ?? "en";
  }

  static Future<bool> setLocale(language) async {
    return LocalStorageService.prefs!.setString(AppStrings.appLocale, language);
  }

  static Stream<bool?> listenToAuthState() {
    return LocalStorageService.rxPrefs!.getBoolStream(AppStrings.authenticated);
  }

  //
  //
  static User? currentUser;
  static Future<User> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final userStringObject = await LocalStorageService.prefs?.getString(
        AppStrings.userKey,
      );
      final userObject = json.decode(userStringObject ?? "{}");
      currentUser = User.fromJson(userObject);
    }
    return currentUser!;
  }

  ///
  ///
  ///
  static Future<User?> saveUser(dynamic jsonObject,
      {bool reload = true}) async {
    try {
      // Convert Firebase UID to integer for compatibility
      final userData = Map<String, dynamic>.from(jsonObject);
      if (userData['id'] is String) {
        // Convert string UID to integer by using hash code
        userData['id'] = userData['id'].toString().hashCode.abs();
      }
      
      final currentUser = User.fromJson(userData);
      
      await LocalStorageService.prefs?.setString(
        AppStrings.userKey,
        json.encode(currentUser.toJson()),
      );

      // Set authentication status
      await LocalStorageService.prefs?.setBool(AppStrings.authenticated, true);
      await LocalStorageService.rxPrefs?.write(
        AppStrings.authenticated,
        true,
        (value) => true,
      );

      // Subscribe to Firebase topics
      if (!kIsWeb) {
        List<String> roles = [
          "all",
          "${currentUser.id}",
          "${currentUser.role}",
          "client"
        ];

        for (var role in roles) {
          try {
            await FirebaseService().firebaseMessaging.subscribeToTopic(role);
          } catch (error) {
            print("Unable to subscribe to topic: $role - $error");
          }
        }
      }

      // Reload app settings if needed
      if (reload) {
        try {
          await SplashViewModel(AppService().navigatorKey.currentContext!)
              .loadAppSettings();
        } catch (error) {
          print("Error reloading app settings: $error");
        }
      }

      return currentUser;
    } catch (error) {
      print("Error saving user: $error");
      return null;
    }
  }

  /// Update user profile
  static Future<ApiResponse> updateUserProfile(Map<String, dynamic> updates) async {
    if (currentUser?.id == null) {
      return ApiResponse(code: 401, message: "User not authenticated");
    }
    return await _profileService.updateUserProfile(currentUser!.id.toString(), updates);
  }

  /// Update user avatar
  static Future<ApiResponse> updateUserAvatar(String avatarUrl) async {
    if (currentUser?.id == null) {
      return ApiResponse(code: 401, message: "User not authenticated");
    }
    return await _profileService.updateUserAvatar(currentUser!.id.toString(), avatarUrl);
  }

  /// Update user address
  static Future<ApiResponse> updateUserAddress(Map<String, dynamic> addressData) async {
    if (currentUser?.id == null) {
      return ApiResponse(code: 401, message: "User not authenticated");
    }
    return await _profileService.updateUserAddress(currentUser!.id.toString(), addressData);
  }

  /// Update user preferences
  static Future<ApiResponse> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (currentUser?.id == null) {
      return ApiResponse(code: 401, message: "User not authenticated");
    }
    return await _profileService.updateUserPreferences(currentUser!.id.toString(), preferences);
  }

  /// Change user password
  static Future<ApiResponse> changePassword(String currentPassword, String newPassword) async {
    return await _profileService.changePassword(currentPassword, newPassword);
  }

  /// Update user email
  static Future<ApiResponse> updateUserEmail(String newEmail) async {
    return await _profileService.updateUserEmail(newEmail);
  }

  /// Update user phone number
  static Future<ApiResponse> updateUserPhone(String phoneNumber) async {
    if (currentUser?.id == null) {
      return ApiResponse(code: 401, message: "User not authenticated");
    }
    return await _profileService.updateUserPhone(phoneNumber);
  }

  /// Delete user account
  static Future<ApiResponse> deleteUserAccount() async {
    if (currentUser?.id == null) {
      return ApiResponse(code: 401, message: "User not authenticated");
    }
    return await _profileService.deleteUserAccount(currentUser!.id.toString());
  }

  /// Get user statistics
  static Future<ApiResponse> getUserStatistics() async {
    if (currentUser?.id == null) {
      return ApiResponse(code: 401, message: "User not authenticated");
    }
    return await _profileService.getUserStatistics(currentUser!.id.toString());
  }

  /// Listen to user profile changes
  static Stream<User?> listenToUserProfile() {
    if (currentUser?.id == null) {
      return Stream.value(null);
    }
    return _profileService.listenToUserProfile(currentUser!.id.toString());
  }

  /// Start listening to user profile
  static void startListeningToUserProfile() {
    if (currentUser?.id != null) {
      _profileService.startListeningToUserProfile(currentUser!.id.toString());
    }
  }

  /// Stop listening to user profile
  static void stopListeningToUserProfile() {
    _profileService.stopListeningToUserProfile();
  }

  ///
  ///
  //
  static Future<void> logout() async {
    try {
      // Stop listening to user profile
      stopListeningToUserProfile();

      // Unsubscribe from Firebase topics
      if (!kIsWeb && currentUser != null) {
        List<String> roles = [
          "${currentUser?.id}",
          "${currentUser?.role}",
          "client",
          "all"
        ];
        for (var role in roles) {
          try {
            await FirebaseService().firebaseMessaging.unsubscribeFromTopic(role);
          } catch (error) {
            print("Unable to unsubscribe from topic: $role - $error");
          }
        }
      }

      // Sign out from Firebase
      try {
        await FirebaseAuth.instance.signOut();
      } catch (error) {
        print("Error signing out from Firebase: $error");
      }

      // Clear local storage
      await HttpService().getCacheManager().clearAll();
      await LocalStorageService.prefs?.clear();
      await LocalStorageService.rxPrefs?.clear();
      
      // Reset first time flag but keep it false
      await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
      
      // Clear current user
      currentUser = null;
      
      print("Logout completed successfully");
    } catch (error) {
      print("Error during logout: $error");
      // Still clear local data even if Firebase logout fails
      await LocalStorageService.prefs?.clear();
      await LocalStorageService.rxPrefs?.clear();
      currentUser = null;
    }
  }

  /// Dispose resources
  static void dispose() {
    _profileService.dispose();
  }
}
