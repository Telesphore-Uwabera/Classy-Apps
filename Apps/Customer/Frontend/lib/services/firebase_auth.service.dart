import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/api_response.dart';
import '../models/user.dart' as AppUser;
import '../constants/api.dart';

/// Firebase Authentication Service
/// Handles all authentication using Firebase directly (no API calls)
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Dio _dio = Dio();

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register user with phone (converted to email format for Firebase)
  static Future<ApiResponse> register({
    required String fullName,
    required String phone,
    required String password,
    required String confirmPassword,
    required String userType,
  }) async {
    try {
      // Validate passwords match
      if (password != confirmPassword) {
        return ApiResponse(
          code: 400,
          message: "Password confirmation does not match password"
        );
      }

      // Convert phone to email format for Firebase Auth
      String email = '${phone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '')}@classy.app';
      
      // Create user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(fullName);

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'userType': userType, // customer, vendor, driver
        'isActive': true,
        'isVerified': false,
        'profileImageUrl': '',
        'addresses': [],
        'preferences': {
          'notifications': true,
          'sms': true,
          'email': false,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return ApiResponse(
        code: 200,
        message: "User registered successfully",
        body: {
          'user': {
            'uid': userCredential.user!.uid,
            'fullName': fullName,
            'phone': phone,
            'email': email,
            'userType': userType,
          }
        }
      );
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";
      switch (e.code) {
        case 'weak-password':
          message = "The password provided is too weak";
          break;
        case 'email-already-in-use':
          message = "An account with this phone number already exists";
          break;
        case 'invalid-email':
          message = "Invalid phone number format";
          break;
        default:
          message = e.message ?? "Registration failed";
      }
      return ApiResponse(code: 400, message: message);
    } catch (e) {
      return ApiResponse(code: 500, message: "Registration failed: ${e.toString()}");
    }
  }

  /// Login with phone and password
  static Future<ApiResponse> login({
    required String phone,
    required String password,
  }) async {
    try {
      // Convert phone to email format
      String email = '${phone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '')}@classy.app';
      
      // Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return ApiResponse(code: 404, message: "User profile not found");
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      return ApiResponse(
        code: 200,
        message: "Login successful",
        body: {
          'user': userData,
          'token': await userCredential.user!.getIdToken(),
        }
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this phone number";
          break;
        case 'wrong-password':
          message = "Incorrect password";
          break;
        case 'user-disabled':
          message = "This account has been disabled";
          break;
        case 'too-many-requests':
          message = "Too many failed attempts. Please try again later";
          break;
        default:
          message = e.message ?? "Login failed";
      }
      return ApiResponse(code: 400, message: message);
    } catch (e) {
      return ApiResponse(code: 500, message: "Login failed: ${e.toString()}");
    }
  }

  /// Send password reset OTP (uses Node.js API for OTP)
  static Future<ApiResponse> sendPasswordResetOTP(String phone) async {
    try {
      final response = await _dio.post(
        '${Api.baseUrl}/api/otp/send',
        data: {
          'phone': phone,
          'purpose': 'password_reset'
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          code: 200,
          message: "OTP sent successfully",
          body: response.data
        );
      } else {
        return ApiResponse(
          code: response.statusCode ?? 500,
          message: response.data['message'] ?? "Failed to send OTP"
        );
      }
    } catch (e) {
      return ApiResponse(code: 500, message: "Failed to send OTP: ${e.toString()}");
    }
  }

  /// Verify OTP and reset password
  static Future<ApiResponse> resetPasswordWithOTP({
    required String phone,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Validate passwords match
      if (newPassword != confirmPassword) {
        return ApiResponse(
          code: 400,
          message: "Password confirmation does not match password"
        );
      }

      // First verify OTP via Node.js API
      final otpResponse = await _dio.post(
        '${Api.baseUrl}/api/otp/verify',
        data: {
          'phone': phone,
          'otp': otp,
          'purpose': 'password_reset'
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (otpResponse.statusCode != 200 || otpResponse.data['success'] != true) {
        return ApiResponse(
          code: 400,
          message: otpResponse.data['message'] ?? "Invalid or expired OTP"
        );
      }

      // OTP verified, now update password in Firebase
      String email = '${phone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '')}@classy.app';
      
      // Send password reset email to update password
      await _auth.sendPasswordResetEmail(email: email);

      return ApiResponse(
        code: 200,
        message: "OTP verified successfully. Please check your email to complete password reset."
      );
    } catch (e) {
      return ApiResponse(code: 500, message: "Password reset failed: ${e.toString()}");
    }
  }

  /// Update user profile
  static Future<ApiResponse> updateProfile({
    required String fullName,
    String? profileImageUrl,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Update Firebase Auth profile
      await user.updateDisplayName(fullName);
      if (profileImageUrl != null) {
        await user.updatePhotoURL(profileImageUrl);
      }

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'profileImageUrl': profileImageUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return ApiResponse(
        code: 200,
        message: "Profile updated successfully"
      );
    } catch (e) {
      return ApiResponse(code: 500, message: "Profile update failed: ${e.toString()}");
    }
  }

  /// Change password
  static Future<ApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Validate passwords match
      if (newPassword != confirmPassword) {
        return ApiResponse(
          code: 400,
          message: "Password confirmation does not match password"
        );
      }

      // Re-authenticate user with current password
      String email = user.email!;
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return ApiResponse(
        code: 200,
        message: "Password changed successfully"
      );
    } on FirebaseAuthException catch (e) {
      String message = "Password change failed";
      switch (e.code) {
        case 'wrong-password':
          message = "Current password is incorrect";
          break;
        case 'weak-password':
          message = "New password is too weak";
          break;
        case 'requires-recent-login':
          message = "Please log in again to change password";
          break;
        default:
          message = e.message ?? "Password change failed";
      }
      return ApiResponse(code: 400, message: message);
    } catch (e) {
      return ApiResponse(code: 500, message: "Password change failed: ${e.toString()}");
    }
  }

  /// Get user profile from Firestore
  static Future<ApiResponse> getUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return ApiResponse(code: 404, message: "User profile not found");
      }

      return ApiResponse(
        code: 200,
        message: "Profile retrieved successfully",
        body: {'user': userDoc.data()}
      );
    } catch (e) {
      return ApiResponse(code: 500, message: "Failed to get profile: ${e.toString()}");
    }
  }

  /// Listen to user profile changes
  static Stream<DocumentSnapshot> listenToUserProfile() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  /// Sign out
  static Future<ApiResponse> signOut() async {
    try {
      await _auth.signOut();
      return ApiResponse(
        code: 200,
        message: "Signed out successfully"
      );
    } catch (e) {
      return ApiResponse(code: 500, message: "Sign out failed: ${e.toString()}");
    }
  }

  /// Get Firebase ID token for API calls
  static Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _auth.currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get current user UID
  static String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  /// Convert phone number to email format for Firebase
  static String phoneToEmail(String phone) {
    return '${phone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '')}@classy.app';
  }

  /// Convert email back to phone format
  static String emailToPhone(String email) {
    String phoneDigits = email.replaceAll('@classy.app', '');
    // Add + prefix for international format
    return '+$phoneDigits';
  }
}
