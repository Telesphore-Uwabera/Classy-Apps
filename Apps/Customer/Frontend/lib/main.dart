import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Classy/my_app.dart';
import 'package:Classy/services/cart.service.dart';
import 'package:Classy/services/general_app.service.dart';
import 'package:Classy/services/local_storage.service.dart';
import 'package:Classy/services/firebase.service.dart';
import 'package:Classy/services/notification.service.dart';
import 'package:Classy/services/firestore_init.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/chat.service.dart';
import 'package:Classy/services/order.service.dart';
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
      
      // Firebase initialization for all platforms using FlutterFire options
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print("✅ Firebase initialized successfully");
        
        // Configure Firestore settings
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        print("✅ Firestore configured successfully");
        
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
      await CartServices.getCartItems();
      
      // Setup Firebase messaging if Firebase is available
      try {
        if (!kIsWeb && Firebase.apps.isNotEmpty) {
          await FirebaseService().setUpFirebaseMessaging();
          FirebaseMessaging.onBackgroundMessage(
            GeneralAppService.onBackgroundMessageHandler,
          );
          print("✅ Firebase messaging setup completed");
        }
      } catch (e) {
        print("❌ Firebase messaging setup error: $e");
        // Continue without Firebase messaging if there's an error
      }

      // Initialize Firestore collections (only if Firebase is available and network is accessible)
      try {
        if (!kIsWeb && Firebase.apps.isNotEmpty) {
          // Add a small delay to ensure Firebase is fully initialized
          await Future.delayed(Duration(milliseconds: 500));
          await FirestoreInitService.initializeCollections();
          print("✅ Firestore collections initialized");
        }
      } catch (e) {
        print("❌ Firestore initialization error: $e");
        // Don't crash the app if Firestore can't initialize
      }

      // Initialize Firebase services
      try {
        if (!kIsWeb && Firebase.apps.isNotEmpty) {
          // Initialize all Firebase services
          await Future.delayed(Duration(milliseconds: 1000));
          
          // Import and initialize services
          await _initializeFirebaseServices();
          print("✅ Firebase services initialized");
        }
      } catch (e) {
        print("❌ Firebase services initialization error: $e");
        // Don't crash the app if services can't initialize
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

/// Initialize all Firebase services
Future<void> _initializeFirebaseServices() async {
  try {
    // Initialize authentication services
    AuthServices.initialize();
    print("✅ Auth services initialized");

    // Initialize cart services
    CartServices.initialize();
    print("✅ Cart services initialized");

    // Initialize chat services
    ChatService.initialize();
    print("✅ Chat services initialized");

    // Initialize order services
    OrderService.initialize();
    print("✅ Order services initialized");

    // Initialize notification services
    NotificationService().initialize();
    print("✅ Notification services initialized");

    print("✅ All Firebase services initialized successfully");
  } catch (e) {
    print("❌ Error initializing Firebase services: $e");
    rethrow;
  }
}
