import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthCompleteService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static bool get isWeb => kIsWeb;

  // Initialize Firebase properly
  static Future<void> initialize() async {
    try {
      if (isWeb) {
        print("🌐 Firebase Web: Using configuration from index.html");
      } else {
        print("📱 Firebase Mobile: Initialized successfully");
      }
    } catch (e) {
      print("❌ Firebase initialization error: $e");
      rethrow;
    }
  }

  // Complete authentication service
  static Future<Map<String, dynamic>> authenticateUser({
    required String email,
    required String password,
    bool isRegistration = false,
    String? displayName,
  }) async {
    try {
      print("🔐 Starting authentication process...");
      print("📧 Email: $email");
      print("🔑 Password: ${password.length} characters");
      print("📝 Registration: $isRegistration");
      print("👤 Display Name: $displayName");
      
      UserCredential? userCredential;
      
      if (isRegistration) {
        print("📝 Attempting user registration...");
        userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("✅ User registration successful");
        
        // Update display name if provided
        if (displayName != null && userCredential.user != null) {
          print("👤 Updating display name: $displayName");
          await userCredential.user!.updateDisplayName(displayName);
          print("✅ Display name updated");
        }
      } else {
        print("🔑 Attempting user login...");
        userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("✅ User login successful");
      }
      
      if (userCredential.user != null) {
        print("✅ User credential obtained");
        print("🆔 User ID: ${userCredential.user!.uid}");
        print("📧 User Email: ${userCredential.user!.email}");
        print("👤 User Display Name: ${userCredential.user!.displayName}");
        
        return {
          'success': true,
          'user': userCredential.user!,
          'credential': userCredential,
        };
      } else {
        print("❌ User credential is null");
        return {
          'success': false,
          'error': 'Authentication failed - no user returned',
        };
      }
    } catch (e) {
      print("❌ Authentication error occurred");
      print("❌ Error type: ${e.runtimeType}");
      print("❌ Error message: $e");
      print("❌ Error details: ${e.toString()}");
      
      // Handle specific Firebase exceptions
      if (e is FirebaseAuthException) {
        print("🔥 Firebase Auth Exception detected");
        print("🔥 Error code: ${e.code}");
        print("🔥 Error message: ${e.message}");
        print("🔥 Error details: ${e.toString()}");
        
        return {
          'success': false,
          'error': _getErrorMessage(e),
          'error_code': e.code,
          'error_type': 'FirebaseAuthException',
        };
      } else {
        print("❌ Non-Firebase exception");
        print("❌ Exception type: ${e.runtimeType}");
        print("❌ Exception details: ${e.toString()}");
        
        return {
          'success': false,
          'error': _getErrorMessage(e),
          'error_type': e.runtimeType.toString(),
        };
      }
    }
  }

  // Save user data to Firestore
  static Future<Map<String, dynamic>> saveUserToFirestore({
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
      print("❌ Save user data error: $e");
      return {
        'success': false,
        'error': _getErrorMessage(e),
      };
    }
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>> getUserFromFirestore(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      return {
        'success': true,
        'data': doc.data(),
      };
    } catch (e) {
      print("❌ Get user data error: $e");
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
    } else if (errorString.contains('timeout')) {
      return "Request timed out. Please try again.";
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

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // Reset password
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } catch (e) {
      print("❌ Reset password error: $e");
      return {
        'success': false,
        'error': _getErrorMessage(e),
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (currentUser != null) {
        if (displayName != null) {
          await currentUser!.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await currentUser!.updatePhotoURL(photoURL);
        }
        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'No user signed in',
        };
      }
    } catch (e) {
      print("❌ Update profile error: $e");
      return {
        'success': false,
        'error': _getErrorMessage(e),
      };
    }
  }
}
