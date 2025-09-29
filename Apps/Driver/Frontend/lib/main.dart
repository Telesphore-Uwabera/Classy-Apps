import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/my_app.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/firebase.service.dart';
import 'package:fuodz/services/firebase_init.service.dart';
import 'package:fuodz/services/firebase_auth_complete.service.dart';
import 'package:fuodz/services/firebase_web_auth_fixed.service.dart';
import 'package:fuodz/services/auth_debug.service.dart';
import 'package:fuodz/services/auth_fix.service.dart';
// import 'package:fuodz/services/auth_test.service.dart'; // Not needed for now
import 'package:fuodz/services/auth_error_analysis.service.dart';
import 'package:fuodz/services/auth_comprehensive_test.service.dart';
import 'package:fuodz/services/general_app.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'constants/app_languages.dart';

// SSL handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Firebase initialization
      try {
        await Firebase.initializeApp();
        print("✅ Firebase initialized successfully");
      } catch (e) {
        print("❌ Firebase initialization error: $e");
        // Continue without Firebase if there's an error
      }

      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );

      //
      await LocalStorageService.getPrefs();
      
      // Only setup Firebase messaging if Firebase is available
      try {
        if (!kIsWeb && Firebase.apps.isNotEmpty) {
          await FirebaseService.instance.setUpFirebaseMessaging();
          FirebaseMessaging.onBackgroundMessage(
            GeneralAppService.onBackgroundMessageHandler,
          );
        }
      } catch (e) {
        print("Firebase messaging setup error: $e");
      }

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
      
      // Suppress RenderFlex overflow errors and other UI errors
      FlutterError.onError = (FlutterErrorDetails details) {
        final errorString = details.exception.toString();
        if (errorString.contains('RenderFlex overflowed') ||
            errorString.contains('A RenderFlex overflowed') ||
            errorString.contains('pixels on the bottom')) {
          // Suppress overflow errors
          return;
        }
        // Handle other errors normally
        try {
          if (!kIsWeb && Firebase.apps.isNotEmpty) {
            FirebaseCrashlytics.instance.recordFlutterError(details);
          }
        } catch (e) {
          print("Error recording to Firebase Crashlytics: $e");
        }
      };

      // Run app!
      runApp(
        LocalizedApp(
          child: MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      try {
        if (!kIsWeb && Firebase.apps.isNotEmpty) {
          FirebaseCrashlytics.instance.recordError(error, stackTrace);
        }
      } catch (e) {
        print("Error recording to Firebase Crashlytics: $e");
      }
    },
  );
}
