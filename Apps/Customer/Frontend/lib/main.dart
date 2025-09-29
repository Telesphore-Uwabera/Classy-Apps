import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Classy/my_app.dart';
import 'package:Classy/services/cart.service.dart';
import 'package:Classy/services/general_app.service.dart';
import 'package:Classy/services/local_storage.service.dart';
import 'package:Classy/services/firebase.service.dart';
import 'package:Classy/services/firebase_init.service.dart';
import 'package:Classy/services/firebase_auth_complete.service.dart';
import 'package:Classy/services/firebase_web_auth_fixed.service.dart';
import 'package:Classy/services/auth_debug.service.dart';
import 'package:Classy/services/auth_fix.service.dart';
import 'package:Classy/services/auth_test.service.dart';
import 'package:Classy/services/auth_error_analysis.service.dart';
import 'package:Classy/services/auth_comprehensive_test.service.dart';
import 'package:Classy/services/notification.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'constants/app_languages.dart';

//ssll handshake error
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
      
      // Firebase initialization using our complete service
      try {
        await FirebaseInitService.initialize();
        await FirebaseAuthCompleteService.initialize();
        await FirebaseWebAuthFixedService.initialize();
        print("✅ Firebase initialized successfully");
        
                // Debug authentication issues if in debug mode
                if (kDebugMode) {
                  print("\n🔍 Running authentication diagnostics...");
                  await AuthDebugService.debugAuthIssues();
                  
                  print("\n🔧 Applying authentication fixes...");
                  await AuthFixService.fixAllAuthIssues();
                  
                  print("\n🧪 Testing authentication after fixes...");
                  await AuthFixService.testAuthAfterFixes();
                  
                  print("\n🏥 Checking authentication health...");
                  await AuthFixService.getAuthHealthStatus();
                  
                  print("\n📊 Analyzing authentication errors...");
                  await AuthErrorAnalysisService.analyzeAndSolveErrors();
                  
                  print("\n📋 Generating detailed error report...");
                  await AuthErrorAnalysisService.getDetailedErrorReport();
                  
                  print("\n🧪 Running comprehensive authentication test...");
                  await AuthComprehensiveTestService.runCompleteAuthTest();
                  
                  print("\n📊 Current authentication status...");
                  await AuthComprehensiveTestService.printAuthStatus();
                }
        
      } catch (e) {
        print("❌ Firebase initialization error: $e");
        print("❌ Error type: ${e.runtimeType}");
        print("❌ Error details: ${e.toString()}");
        // Continue without Firebase if there's an error
      }

      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );

      //
      await LocalStorageService.getPrefs();
      await CartServices.getCartItems();
      
      // Only setup Firebase messaging if Firebase is available
      try {
        if (!kIsWeb && Firebase.apps.isNotEmpty) {
          await FirebaseService().setUpFirebaseMessaging();
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
