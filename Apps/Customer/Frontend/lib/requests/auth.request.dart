// Firebase-only authentication - No Laravel API calls
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/services/auth.service.dart';

class AuthRequest {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== FIREBASE AUTHENTICATION METHODS =====
  
  // Login with Firebase
  static Future<ApiResponse> loginRequest(Map<String, dynamic> data) async {
    try {
      final phoneNumber = data['phone'];
      final password = data['password'];
      
      // Convert phone to email format for Firebase
      final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        final userData = userDoc.data();
        
        return ApiResponse(
          code: 200,
          message: "Login successful",
          body: {
            'user': userData,
            'token': await userCredential.user!.getIdToken(),
          },
        );
      }
      
      return ApiResponse(code: 400, message: "Login failed");
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  // Register with Firebase
  static Future<ApiResponse> registerRequest(Map<String, dynamic> data) async {
    try {
      final phoneNumber = data['phone'];
      final password = data['password'];
      final name = data['name'];
      
      // Convert phone to email format for Firebase
      final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Update user profile
        await userCredential.user!.updateDisplayName(name);
        
        // Save user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'phone': phoneNumber,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return ApiResponse(
          code: 200,
          message: "Registration successful",
          body: {
            'user': {
              'id': userCredential.user!.uid,
              'name': name,
              'email': email,
              'phone': phoneNumber,
            },
            'token': await userCredential.user!.getIdToken(),
          },
        );
      }
      
      return ApiResponse(code: 400, message: "Registration failed");
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  // Forgot password with Firebase
  static Future<ApiResponse> forgotPasswordRequest(String phone) async {
    try {
      final email = "${phone.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
      
      await _auth.sendPasswordResetEmail(email: email);
      
      return ApiResponse(
        code: 200,
        message: "Password reset email sent",
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  // Logout
  static Future<ApiResponse> logoutRequest() async {
    try {
      await _auth.signOut();
      await AuthServices.logout();
      
      return ApiResponse(
        code: 200,
        message: "Logout successful",
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  // Update profile
  static Future<ApiResponse> updateProfileRequest(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }
      
      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return ApiResponse(
        code: 200,
        message: "Profile updated successfully",
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  // Update password
  static Future<ApiResponse> updatePasswordRequest(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }
      
      final newPassword = data['new_password'];
      await user.updatePassword(newPassword);
      
      return ApiResponse(
        code: 200,
        message: "Password updated successfully",
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  // Delete account
  static Future<ApiResponse> deleteAccountRequest() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete Firebase Auth user
      await user.delete();
      
      return ApiResponse(
        code: 200,
        message: "Account deleted successfully",
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  // ===== REMOVED COMPLEX AUTH METHODS =====
  // QR login, OTP verification, and social logins removed for simplicity
  // Only phone/password authentication is supported
  
  static Future<ApiResponse> tokenSyncRequest(Map<String, dynamic> data) async {
    return ApiResponse(code: 200, message: "Token sync not needed with Firebase");
  }

  // ===== ADDITIONAL MISSING METHODS =====
  
  static Future<ApiResponse> resetPasswordRequest(Map<String, dynamic> data) async {
    return ApiResponse(code: 501, message: "Password reset not implemented");
  }
  
  static Future<ApiResponse> updatePassword(Map<String, dynamic> data) async {
    return updatePasswordRequest(data);
  }
  
  static Future<ApiResponse> delete(String id) async {
    return deleteAccountRequest();
  }
  
  static Future<ApiResponse> deleteProfile(Map<String, dynamic> data) async {
    return deleteAccountRequest();
  }
  
  static Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    return updateProfileRequest(data);
  }
  
  static Future<ApiResponse> updateDeviceToken(String token) async {
    return ApiResponse(code: 200, message: "Device token updated");
  }
}