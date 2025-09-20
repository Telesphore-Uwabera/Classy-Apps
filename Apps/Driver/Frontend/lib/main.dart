import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/firebase.service.dart';
import 'services/firebase_backend.service.dart';
import 'services/driver_firebase.service.dart';
import 'services/driver_notification.service.dart';
import 'services/driver_location.service.dart';
import 'services/general_app.service.dart';
import 'package:fuodz/my_app.dart';
import 'package:fuodz/services/local_storage.service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for all platforms
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
    debugPrint('Firebase app name: ${Firebase.app().name}');
    debugPrint('Firebase project ID: ${Firebase.app().options.projectId}');
  } catch (e) {
    // Log but do not crash the app if Firebase fails to initialize
    // Some features depending on Firebase should guard against null/absence
    debugPrint('Firebase init failed: $e');
    debugPrint('Firebase error type: ${e.runtimeType}');
    if (e is PlatformException) {
      debugPrint('Platform error code: ${e.code}');
      debugPrint('Platform error message: ${e.message}');
    }
    firebaseInitialized = false;
  }

  // Set up Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(
    GeneralAppService.onBackgroundMessageHandler,
  );

  // Initialize Firebase backend services only if Firebase is initialized
  if (firebaseInitialized) {
    try {
      final backendService = FirebaseBackendService.instance;
      final backendInitialized = await backendService.initializeBackend();

      if (backendInitialized) {
        debugPrint('Firebase backend initialized successfully');
      } else {
        debugPrint('Firebase backend initialization failed');
      }
    } catch (e) {
      debugPrint('Error initializing Firebase backend: $e');
    }
  } else {
    debugPrint('Skipping Firebase backend initialization - Firebase not available');
  }

  // Initialize driver-specific services
  try {
    // Initialize driver notification service
    await DriverNotificationService.initializeDriverNotifications();
    await DriverNotificationService.requestNotificationPermissions();
    DriverNotificationService.setupNotificationActions();

    // Initialize driver Firebase service (only if Firebase is available)
    if (firebaseInitialized) {
      try {
        DriverFirebaseService.instance;
        debugPrint('Driver Firebase service initialized');
      } catch (e) {
        debugPrint('Driver Firebase service not available: $e');
      }
    } else {
      debugPrint('Skipping Driver Firebase service - Firebase not available');
    }

    // Initialize driver location service
    DriverLocationService.instance;
    
    debugPrint('Driver services initialized successfully');
  } catch (e) {
    debugPrint('Error initializing driver services: $e');
  }

  // Foreground notifications & token sync (only if Firebase is initialized)
  if (firebaseInitialized) {
    try {
      await FirebaseService().setUpFirebaseMessaging();
      debugPrint('Firebase messaging setup completed');
    } catch (e) {
      debugPrint('Error setting up Firebase messaging: $e');
    }
  } else {
    debugPrint('Skipping Firebase messaging setup - Firebase not available');
  }

  // Initialize local storage
  await LocalStorageService.getPrefs();

  // Configure for mobile-first development
  runApp(MyApp());
}
