import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:Classy/models/user.dart' as AppUser;
import 'package:Classy/services/auth.service.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';

/// Unified Authentication Service
/// Handles authentication methods: Email/Password and Phone (OTP)
class UnifiedAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save user to Firestore
  static Future<void> _saveUserToFirestore(Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userData['id']).set(userData);
      print("✅ User saved to Firestore: ${userData['id']}");
    } catch (e) {
      print("❌ Error saving user to Firestore: $e");
      // Don't throw error - user is still authenticated
    }
  }

  /// Check if user exists in Firestore and create if not
  static Future<void> ensureUserExistsInFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        // User doesn't exist in Firestore, create them
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final userData = {
            'id': currentUser.uid,
            'name': currentUser.displayName ?? 'User',
            'email': currentUser.email ?? '',
            'phone': currentUser.phoneNumber ?? '',
            'role': 'customer',
            'photo': currentUser.photoURL ?? '',
            'country_code': 'US',
            'wallet_address': '',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          await _saveUserToFirestore(userData);
        }
      }
    } catch (e) {
      print("❌ Error checking/creating user in Firestore: $e");
    }
  }

  /// Sign in with email and password - Simple and Clean
  static Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      print("🔐 Attempting email/password login: $email");
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create basic user data
        final basicUserData = {
          'id': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? 'User',
          'email': userCredential.user!.email ?? email,
          'phone': userCredential.user!.phoneNumber ?? '',
          'role': 'customer',
          'photo': userCredential.user!.photoURL ?? '',
          'country_code': 'US',
          'wallet_address': '',
        };
        
        await AuthServices.saveUser(basicUserData);
        
        // Ensure user exists in Firestore
        await ensureUserExistsInFirestore(userCredential.user!.uid);
        
        return {
          'success': true,
          'user': basicUserData,
          'message': 'Login successful',
        };
      }
      
      return {
        'success': false,
        'message': 'Login failed - no user returned',
      };
    } catch (e) {
      print("❌ Email/password login error: $e");
      
      // Handle Firebase Auth errors
      if (e is FirebaseAuthException) {
        String message = 'Login failed. Please try again.';
        
        switch (e.code) {
          case 'user-not-found':
            message = 'No account found with this email address.';
            break;
          case 'wrong-password':
            message = 'Incorrect password.';
            break;
          case 'invalid-email':
            message = 'Invalid email address format.';
            break;
          case 'too-many-requests':
            message = 'Too many failed login attempts. Please wait a few minutes.';
            break;
          case 'user-disabled':
            message = 'This account has been disabled.';
            break;
          case 'network-request-failed':
            message = 'Network error. Please check your internet connection.';
            break;
        }
        
        return {
          'success': false,
          'message': message,
        };
      }
      
      // Return simple error message for other errors
      return {
        'success': false,
        'message': 'Login failed. Please try again.',
      };
    }
  }

  /// Sign up with email and password - Simple and Clean
  static Future<Map<String, dynamic>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? countryCode,
  }) async {
    try {
      print("📝 Attempting email/password registration: $email");
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);
        
        // Prepare user data
        final userData = {
          'id': userCredential.user!.uid,
          'name': name,
          'email': email,
          'phone': phone ?? '',
          'role': 'customer',
          'photo': '',
          'country_code': countryCode ?? 'US',
          'wallet_address': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        // Save locally
        await AuthServices.saveUser(userData);
        
        // Save to Firestore
        await _saveUserToFirestore(userData);
        
        return {
          'success': true,
          'user': userData,
          'message': 'Registration successful',
        };
      }
      
      return {
        'success': false,
        'message': 'Registration failed - no user returned',
      };
    } catch (e) {
      print("❌ Email/password registration error: $e");
      
      // Handle Firebase Auth errors
      if (e is FirebaseAuthException) {
        String message = 'Registration failed. Please try again.';
        
        switch (e.code) {
          case 'email-already-in-use':
            message = 'An account already exists with this email address.';
            break;
          case 'weak-password':
            message = 'Password should be at least 6 characters.';
            break;
          case 'invalid-email':
            message = 'Invalid email address format.';
            break;
          case 'operation-not-allowed':
            message = 'Email/password accounts are not enabled.';
            break;
          case 'network-request-failed':
            message = 'Network error. Please check your internet connection.';
            break;
        }
        
        return {
          'success': false,
          'message': message,
        };
      }
      
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  // Social login methods removed - only phone/password authentication available

  /// Sign in with phone number (OTP)
  static Future<Map<String, dynamic>> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      print("📱 Attempting phone login: $phoneNumber");
      
      final PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(phoneAuthCredential);
      
      if (userCredential.user != null) {
        // Get or create user data
        final userData = await _getUserDataFromFirestore(userCredential.user!.uid);
        
        if (userData == null) {
          // Create new user data for phone login
          final newUserData = {
            'id': userCredential.user!.uid,
            'name': userCredential.user!.displayName ?? 'User',
            'email': userCredential.user!.email ?? '',
            'phone': phoneNumber,
            'role': 'customer',
            'photo': userCredential.user!.photoURL ?? '',
            'country_code': 'US',
            'wallet_address': '',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          // await _firestore.collection('users').doc(userCredential.user!.uid).set(newUserData); // Temporarily disabled
          await AuthServices.saveUser(newUserData);
          
          return {
            'success': true,
            'user': newUserData,
            'message': 'Phone login successful',
          };
        } else {
          await AuthServices.saveUser(userData);
          
          return {
            'success': true,
            'user': userData,
            'message': 'Phone login successful',
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Phone login failed',
      };
    } catch (e) {
      print("❌ Phone login error: $e");
      return {
        'success': false,
        'message': _getFirebaseErrorMessage(e),
      };
    }
  }

  /// Send OTP to phone number
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      print("📤 Sending OTP to: $phoneNumber");
      
      if (kIsWeb) {
        return {
          'success': false,
          'message': 'Phone authentication is not supported on web',
        };
      }
      
      String? verificationId;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print("✅ Phone verification completed automatically");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ Phone verification failed: ${e.message}");
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
          print("📱 OTP sent successfully");
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
          print("⏰ OTP auto-retrieval timeout");
        },
      );
      
      if (verificationId != null) {
        return {
          'success': true,
          'verificationId': verificationId,
          'message': 'OTP sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send OTP',
        };
      }
    } catch (e) {
      print("❌ Send OTP error: $e");
      return {
        'success': false,
        'message': _getFirebaseErrorMessage(e),
      };
    }
  }

  // OTP-related methods removed to eliminate network permission issues


  /// Sign out
  static Future<void> signOut() async {
    try {
      print("🚪 Signing out...");
      
      
      
      // Sign out from Firebase
      await _auth.signOut();
      
      // Clear local data
      await AuthServices.logout();
      
      print("✅ Sign out completed");
    } catch (e) {
      print("❌ Sign out error: $e");
      // Still clear local data even if Firebase sign out fails
      await AuthServices.logout();
    }
  }

  /// Get current user
  static AppUser.User? getCurrentUser() {
    return AuthServices.currentUser;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return AuthServices.authenticated();
  }


  /// Get user data from Firestore
  static Future<Map<String, dynamic>?> _getUserDataFromFirestore(String uid) async {
    try {
      // final doc = await _firestore.collection('users').doc(uid).get(); // Temporarily disabled
      // return doc.data();
      return null; // Temporarily return null to avoid Firestore dependency
    } catch (e) {
      print("❌ Error getting user data from Firestore: $e");
      return null;
    }
  }

  /// Generate nonce for Apple sign-in
  static String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Generate SHA256 hash for Apple sign-in
  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get user-friendly error message
  static String _getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Invalid email address format.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'invalid-phone-number':
          return 'Invalid phone number format.';
        case 'invalid-verification-code':
          return 'Invalid verification code.';
        case 'invalid-verification-id':
          return 'Invalid verification ID.';
        case 'credential-already-in-use':
          return 'This credential is already associated with a different account.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email but different sign-in credentials.';
        case 'network-request-failed':
          return 'Network connection failed. Please check your internet connection and try again.';
        default:
          return error.message ?? 'An error occurred during authentication.';
      }
    }
    
    return error.toString();
  }
}

/// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
