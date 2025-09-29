import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseInitService {
  static bool _initialized = false;
  static FirebaseApp? _app;

  // Initialize Firebase
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        // For web, Firebase is initialized in index.html
        print("🌐 Firebase Web: Using configuration from index.html");
        _initialized = true;
        return;
      }

      // For mobile platforms
      _app = await Firebase.initializeApp();
      print("📱 Firebase Mobile: Initialized successfully");
      _initialized = true;
    } catch (e) {
      print("❌ Firebase initialization error: $e");
      rethrow;
    }
  }

  // Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (!_initialized) {
      throw Exception("Firebase not initialized. Call FirebaseInitService.initialize() first.");
    }
    return FirebaseAuth.instance;
  }

  // Get Firestore instance
  static FirebaseFirestore get firestore {
    if (!_initialized) {
      throw Exception("Firebase not initialized. Call FirebaseInitService.initialize() first.");
    }
    return FirebaseFirestore.instance;
  }

  // Check if Firebase is initialized
  static bool get isInitialized => _initialized;

  // Get current user
  static User? get currentUser => auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  // Sign out
  static Future<void> signOut() async {
    try {
      await auth.signOut();
      print("✅ User signed out successfully");
    } catch (e) {
      print("❌ Sign out error: $e");
      rethrow;
    }
  }

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // Get user token
  static Future<String?> getUserToken() async {
    try {
      return await currentUser?.getIdToken();
    } catch (e) {
      print("❌ Get token error: $e");
      return null;
    }
  }
}
