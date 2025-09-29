// Firebase-only authentication - No Laravel API calls
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase_web.service.dart';
import 'package:Classy/services/firebase_web_auth.service.dart';
import 'package:Classy/services/firebase_auth_complete.service.dart';
import 'package:Classy/services/firebase_web_compatible.service.dart';
import 'package:Classy/services/firebase_error.service.dart';

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
      
      print("🔥 Attempting login for: $email");
      print("📱 Phone number: $phoneNumber");
      print("🌐 Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      
      // Use web-safe Firebase authentication service
      final result = await FirebaseWebCompatibleService.loginUserWebCompatible(
        email: email,
        password: password,
      );
      
      print("📊 Authentication result: ${result['success']}");
      print("📊 Error type: ${result['error_type']}");
      print("📊 Platform: ${result['platform']}");
      
      if (result['success'] == true) {
        final user = result['user'] as User;
        print("✅ User authenticated: ${user.uid}");
        print("📧 User email: ${user.email}");
        print("👤 User display name: ${user.displayName}");
        
        // Get user data from Firestore
        print("📖 Getting user data from Firestore...");
        // Get user data from Firestore (simplified for web compatibility)
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.exists ? userDoc.data() : null;
        
        print("📊 User data from Firestore: ${userData != null ? 'Found' : 'Not found'}");
        
        // Ensure user data has proper structure for User model
        final formattedUserData = {
          'id': user.uid,
          'name': userData?['name'] ?? user.displayName ?? '',
          'email': userData?['email'] ?? user.email ?? '',
          'phone': userData?['phone'] ?? '',
          'role': userData?['role'] ?? 'customer',
          'photo': userData?['photo'] ?? user.photoURL ?? '',
          'country_code': userData?['country_code'] ?? '+1',
          'wallet_address': userData?['wallet_address'] ?? '',
        };
        
        print("✅ User data formatted successfully");
        print("📊 Formatted user data keys: ${formattedUserData.keys.toList()}");
        
        return ApiResponse(
          code: 200,
          message: "Login successful",
          body: {
            'user': formattedUserData,
            'token': await user.getIdToken(),
          },
        );
      } else {
        print("❌ Login failed: ${result['error']}");
        print("❌ Error type: ${result['error_type']}");
        print("❌ Platform: ${result['platform']}");
        
        if (result['debug_info'] != null) {
          print("🔍 Debug info: ${result['debug_info']}");
        }
        
        return ApiResponse(code: 400, message: result['error'] ?? "Login failed");
      }
    } catch (e) {
      // Handle other errors
      print("❌ Login error: $e");
      print("❌ Error type: ${e.runtimeType}");
      print("❌ Error details: ${e.toString()}");
      
      String errorMessage = FirebaseErrorService.getUserFriendlyMessage(e);
      return ApiResponse(code: 500, message: errorMessage);
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
      
      print("🔥 Attempting registration for: $email");
      print("📱 Phone number: $phoneNumber");
      print("👤 Name: $name");
      print("🌐 Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      
      // Use web-compatible Firebase authentication service
      final result = await FirebaseWebCompatibleService.registerUserWebCompatible(
        email: email,
        password: password,
        displayName: name,
      );
      
      print("📊 Registration result: ${result['success']}");
      print("📊 Error type: ${result['error_type']}");
      print("📊 Platform: ${result['platform']}");
      
      if (result['success'] == true) {
        final user = result['user'] as User;
        print("✅ User created: ${user.uid}");
        print("📧 User email: ${user.email}");
        print("👤 User display name: ${user.displayName}");
        
        // Save user data to Firestore
        final userData = {
          'id': user.uid,
          'name': name,
          'email': email,
          'phone': phoneNumber,
          'role': 'customer',
          'photo': '',
          'country_code': '+1', // Default country code
          'wallet_address': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        print("💾 Saving user data to Firestore...");
        print("📊 User data keys: ${userData.keys.toList()}");
        
        final saveResult = await FirebaseWebCompatibleService.saveUserToFirestore(
          uid: user.uid,
          userData: userData,
        );
        
        print("📊 Save result: ${saveResult['success']}");
        print("📊 Save platform: ${saveResult['platform']}");
        
        if (saveResult['success'] == true) {
          print("✅ User data saved to Firestore");
          return ApiResponse(
            code: 200,
            message: "Registration successful",
            body: {
              'user': userData,
              'token': await user.getIdToken(),
            },
          );
        } else {
          print("❌ Failed to save user data: ${saveResult['error']}");
          return ApiResponse(code: 400, message: saveResult['error'] ?? "Failed to save user data");
        }
      } else {
        print("❌ Registration failed: ${result['error']}");
        print("❌ Error type: ${result['error_type']}");
        print("❌ Platform: ${result['platform']}");
        
        if (result['debug_info'] != null) {
          print("🔍 Debug info: ${result['debug_info']}");
        }
        
        return ApiResponse(code: 400, message: result['error'] ?? "Registration failed");
      }
    } catch (e) {
      // Handle other errors
      print("❌ Registration error: $e");
      print("❌ Error type: ${e.runtimeType}");
      print("❌ Error details: ${e.toString()}");
      
      String errorMessage = FirebaseErrorService.getUserFriendlyMessage(e);
      return ApiResponse(code: 500, message: errorMessage);
    }
  }

  // Forgot password with Firebase
  static Future<ApiResponse> forgotPasswordRequest(String phone) async {
    try {
      final email = "${phone.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
      
      final result = await FirebaseAuthCompleteService.resetPassword(email);
      
      if (result['success'] == true) {
        return ApiResponse(code: 200, message: result['message'] ?? "Password reset email sent");
      } else {
        return ApiResponse(code: 400, message: result['error'] ?? "Failed to send reset email");
      }
    } catch (e) {
      print("❌ Forgot password error: $e");
      String errorMessage = FirebaseErrorService.getUserFriendlyMessage(e);
      return ApiResponse(code: 500, message: errorMessage);
    }
  }

  // Logout
  static Future<ApiResponse> logoutRequest() async {
    try {
      await FirebaseAuthCompleteService.signOut();
      await AuthServices.logout();
      
      return ApiResponse(
        code: 200,
        message: "Logout successful",
      );
    } catch (e) {
      print("❌ Logout error: $e");
      String errorMessage = FirebaseErrorService.getUserFriendlyMessage(e);
      return ApiResponse(code: 500, message: errorMessage);
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
      print("❌ Update profile error: $e");
      String errorMessage = FirebaseErrorService.getUserFriendlyMessage(e);
      return ApiResponse(code: 500, message: errorMessage);
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

  // ===== MOCK METHODS FOR COMPATIBILITY =====
  // These methods are kept for compatibility but return mock data
  
  static Future<ApiResponse> qrLoginRequest(Map<String, dynamic> data) async {
    return ApiResponse(code: 501, message: "QR login not implemented");
  }
  
  static Future<ApiResponse> verifyPhoneAccountRequest(Map<String, dynamic> data) async {
    return ApiResponse(code: 501, message: "Phone verification not implemented");
  }
  
  static Future<ApiResponse> verifyPhoneAccount(String phone) async {
    return verifyPhoneAccountRequest({'phone': phone});
  }
  
  static Future<ApiResponse> sendOtpRequest(Map<String, dynamic> data) async {
    return ApiResponse(code: 501, message: "OTP not implemented");
  }
  
  static Future<ApiResponse> sendOTP(String phone) async {
    return sendOtpRequest({'phone': phone});
  }
  
  static Future<ApiResponse> verifyOtpRequest(Map<String, dynamic> data) async {
    return ApiResponse(code: 501, message: "OTP not implemented");
  }
  
  static Future<ApiResponse> verifyOTP(Map<String, dynamic> data) async {
    return verifyOtpRequest(data);
  }
  
  static Future<ApiResponse> verifyFirebaseOtpRequest(Map<String, dynamic> data) async {
    return ApiResponse(code: 501, message: "Firebase OTP not implemented");
  }
  
  static Future<ApiResponse> socialLoginRequest(Map<String, dynamic> data) async {
    return ApiResponse(code: 501, message: "Social login not implemented");
  }
  
  static Future<ApiResponse> socialLogin(Map<String, dynamic> data) async {
    return socialLoginRequest(data);
  }
  
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