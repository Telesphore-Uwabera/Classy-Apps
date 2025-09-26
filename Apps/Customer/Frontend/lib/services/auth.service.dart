import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/services/firebase.service.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/view_models/splash.vm.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

import 'local_storage.service.dart';

class AuthServices {
  //
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
    try {
      // Set authentication state in both storage systems
      await LocalStorageService.rxPrefs?.write(
        AppStrings.authenticated,
        true,
        (value) {
          return value;
        },
      );
      await LocalStorageService.prefs!.setBool(AppStrings.authenticated, true);
      
      print("✅ Authentication state set to true");
      return true;
    } catch (e) {
      print("❌ Error setting authentication state: $e");
      return false;
    }
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
      print("💾 Saving user data...");
      print("📊 User data type: ${jsonObject.runtimeType}");
      print("📊 User data: $jsonObject");
      
      // Ensure jsonObject is a Map
      Map<String, dynamic> userData;
      if (jsonObject is Map<String, dynamic>) {
        userData = jsonObject;
      } else if (jsonObject is Map) {
        userData = Map<String, dynamic>.from(jsonObject);
      } else {
        print("❌ Invalid user data type: ${jsonObject.runtimeType}");
        return null;
      }

      print("📊 Processed user data: $userData");
      
      final currentUser = User.fromJson(userData);
      print("✅ User object created: ${currentUser.id}");
      
      await LocalStorageService.prefs?.setString(
        AppStrings.userKey,
        json.encode(
          currentUser.toJson(),
        ),
      );
      
      print("✅ User data saved to local storage");

      //subscribe to firebase topic
      List<String> roles = [
        "all",
        "${currentUser.id}",
        "${currentUser.role}",
        "client"
      ];

      for (var role in roles) {
        try {
          FirebaseService().firebaseMessaging.subscribeToTopic(role);
          print("✅ Subscribed to topic: $role");
        } catch (error) {
          print("❌ Unable to subscribe to topic: $role - $error");
        }
      }

      //log the new
      if (reload) {
        try {
          await SplashViewModel(AppService().navigatorKey.currentContext!)
              .loadAppSettings();
          print("✅ App settings reloaded");
        } catch (error) {
          print("❌ Error reloading app settings: $error");
        }
      }

      print("✅ User data saved successfully");
      return currentUser;
    } catch (error) {
      print("❌ Error saving user: $error");
      print("❌ Error type: ${error.runtimeType}");
      print("❌ Error details: ${error.toString()}");
      return null;
    }
  }

  ///
  ///
  //
  static Future<void> logout() async {
    await HttpService().getCacheManager().clearAll();
    await LocalStorageService.prefs?.clear();
    await LocalStorageService.rxPrefs?.clear();
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);

    //
    List<String> roles = [
      "${currentUser?.id}",
      "${currentUser?.role}",
      "client",
      "all"
    ];
    for (var role in roles) {
      try {
        FirebaseService().firebaseMessaging.unsubscribeFromTopic(role);
      } catch (error) {
        print("Unable to unsubscribe to:: $role");
      }
    }
    await FirebaseAuth.instance.signOut();
  }
}
