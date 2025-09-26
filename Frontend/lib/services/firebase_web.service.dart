import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseWebService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Check if running on web
  static bool get isWeb => kIsWeb;

  // Initialize Firebase for web
  static Future<void> initializeWeb() async {
    if (isWeb) {
      try {
        // Firebase is already initialized in index.html
        print("🌐 Firebase Web initialized");
      } catch (e) {
        print("❌ Firebase Web initialization error: $e");
      }
    }
  }

  // Create user with email and password (web-compatible)
  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (isWeb) {
        // Use web-compatible method with proper error handling
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (userCredential.user != null && displayName != null) {
          await userCredential.user!.updateDisplayName(displayName);
        }
        
        return userCredential;
      } else {
        // Use standard method for mobile
        return await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } catch (e) {
      print("❌ Create user error: $e");
      // Convert to proper exception type for web
      if (isWeb && e.toString().contains('FirebaseException')) {
        throw Exception("Registration failed: ${e.toString()}");
      }
      rethrow;
    }
  }

  // Sign in with email and password (web-compatible)
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("❌ Sign in error: $e");
      // Convert to proper exception type for web
      if (isWeb && e.toString().contains('FirebaseException')) {
        throw Exception("Login failed: ${e.toString()}");
      }
      rethrow;
    }
  }

  // Save user data to Firestore
  static Future<void> saveUserData({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await firestore.collection('users').doc(uid).set(userData);
      print("✅ User data saved to Firestore");
    } catch (e) {
      print("❌ Save user data error: $e");
      rethrow;
    }
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print("❌ Get user data error: $e");
      return null;
    }
  }
}
