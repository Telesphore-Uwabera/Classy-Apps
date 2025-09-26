import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseWebAuthService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Check if running on web
  static bool get isWeb => kIsWeb;

  // Create user with email and password (web-safe)
  static Future<Map<String, dynamic>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Update display name if provided
        if (displayName != null) {
          await userCredential.user!.updateDisplayName(displayName);
        }
        
        return {
          'success': true,
          'user': userCredential.user!,
          'credential': userCredential,
        };
      }
      
      return {
        'success': false,
        'error': 'User creation failed',
      };
    } catch (e) {
      print("❌ Web create user error: $e");
      return {
        'success': false,
        'error': _getErrorMessage(e),
      };
    }
  }

  // Sign in with email and password (web-safe)
  static Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return {
        'success': true,
        'user': userCredential.user!,
        'credential': userCredential,
      };
    } catch (e) {
      print("❌ Web sign in error: $e");
      return {
        'success': false,
        'error': _getErrorMessage(e),
      };
    }
  }

  // Save user data to Firestore (web-safe)
  static Future<Map<String, dynamic>> saveUserData({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await firestore.collection('users').doc(uid).set(userData);
      return {
        'success': true,
        'message': 'User data saved successfully',
      };
    } catch (e) {
      print("❌ Web save user data error: $e");
      return {
        'success': false,
        'error': _getErrorMessage(e),
      };
    }
  }

  // Get user data from Firestore (web-safe)
  static Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      return {
        'success': true,
        'data': doc.data(),
      };
    } catch (e) {
      print("❌ Web get user data error: $e");
      return {
        'success': false,
        'error': _getErrorMessage(e),
        'data': null,
      };
    }
  }

  // Get user-friendly error message
  static String _getErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    if (errorString.contains('email-already-in-use')) {
      return "An account with this phone number already exists.";
    } else if (errorString.contains('weak-password')) {
      return "Password is too weak. Please choose a stronger password.";
    } else if (errorString.contains('user-not-found')) {
      return "No account found with this phone number.";
    } else if (errorString.contains('wrong-password')) {
      return "Incorrect password.";
    } else if (errorString.contains('invalid-email')) {
      return "Invalid phone number format.";
    } else if (errorString.contains('user-disabled')) {
      return "Account has been disabled.";
    } else if (errorString.contains('too-many-requests')) {
      return "Too many failed attempts. Please try again later.";
    } else if (errorString.contains('network')) {
      return "Network error. Please check your internet connection.";
    } else {
      return "An error occurred. Please try again.";
    }
  }

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
