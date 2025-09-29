import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseWebCompatibleService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static bool get isWeb => kIsWeb;

  // Web-compatible user registration
  static Future<Map<String, dynamic>> registerUserWebCompatible({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      print("🌐 Starting web-compatible registration...");
      print("📧 Email: $email");
      print("👤 Display Name: $displayName");
      
      // Use try-catch with proper web error handling
      UserCredential userCredential;
      
      try {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("✅ User created successfully");
      } catch (e) {
        print("❌ Firebase createUser error: $e");
        print("❌ Error type: ${e.runtimeType}");
        
        // Convert all web errors to user-friendly messages
        String errorMessage = _getUserFriendlyErrorMessage(e);
        return {
          'success': false,
          'error': errorMessage,
          'error_type': e.runtimeType.toString(),
          'platform': 'web',
        };
      }
      
      // Update display name if provided
      if (displayName != null && userCredential.user != null) {
        try {
          await userCredential.user!.updateDisplayName(displayName);
          print("✅ Display name updated");
        } catch (e) {
          print("⚠️ Failed to update display name: $e");
          // Don't fail registration for this
        }
      }
      
      return {
        'success': true,
        'user': userCredential.user!,
        'credential': userCredential,
        'platform': 'web',
      };
      
    } catch (e) {
      print("❌ Registration failed: $e");
      return {
        'success': false,
        'error': 'Registration failed. Please try again.',
        'error_type': e.runtimeType.toString(),
        'platform': 'web',
      };
    }
  }

  // Web-compatible user login
  static Future<Map<String, dynamic>> loginUserWebCompatible({
    required String email,
    required String password,
  }) async {
    try {
      print("🌐 Starting web-compatible login...");
      print("📧 Email: $email");
      
      UserCredential userCredential;
      
      try {
        userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("✅ User login successful");
      } catch (e) {
        print("❌ Firebase signIn error: $e");
        print("❌ Error type: ${e.runtimeType}");
        
        String errorMessage = _getUserFriendlyErrorMessage(e);
        return {
          'success': false,
          'error': errorMessage,
          'error_type': e.runtimeType.toString(),
          'platform': 'web',
        };
      }
      
      return {
        'success': true,
        'user': userCredential.user!,
        'credential': userCredential,
        'platform': 'web',
      };
      
    } catch (e) {
      print("❌ Login failed: $e");
      return {
        'success': false,
        'error': 'Login failed. Please try again.',
        'error_type': e.runtimeType.toString(),
        'platform': 'web',
      };
    }
  }

  // Save user data to Firestore (web-compatible)
  static Future<Map<String, dynamic>> saveUserToFirestore({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      print("💾 Saving user data to Firestore...");
      print("🆔 User ID: $uid");
      
      await firestore.collection('users').doc(uid).set(userData);
      print("✅ User data saved successfully");
      
      return {
        'success': true,
        'platform': 'web',
      };
    } catch (e) {
      print("❌ Failed to save user data: $e");
      return {
        'success': false,
        'error': 'Failed to save user data. Please try again.',
        'platform': 'web',
      };
    }
  }

  // Get user-friendly error messages
  static String _getUserFriendlyErrorMessage(dynamic error) {
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
    } else if (errorString.contains('timeout')) {
      return "Request timed out. Please try again.";
    } else if (errorString.contains('typeerror') || errorString.contains('javascriptobject')) {
      return "Web compatibility error. Please try again.";
    } else {
      return "An error occurred. Please try again.";
    }
  }
}
