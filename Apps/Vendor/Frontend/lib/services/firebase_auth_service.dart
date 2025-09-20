import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../models/api_response.dart';

/// Firebase Authentication Service for Vendor App
/// Handles all authentication using Firebase directly (no API calls)
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Dio _dio = Dio();

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register vendor with phone (converted to email format for Firebase)
  static Future<ApiResponse> register({
    required String businessName,
    required String fullName,
    required String phone,
    required String password,
    required String confirmPassword,
    required String businessType,
    String? businessAddress,
    String? businessDescription,
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

      // Save vendor data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'userType': 'vendor',
        'businessName': businessName,
        'businessType': businessType,
        'businessAddress': businessAddress ?? '',
        'businessDescription': businessDescription ?? '',
        'businessHours': {
          'monday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
          'tuesday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
          'wednesday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
          'thursday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
          'friday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
          'saturday': {'open': '09:00', 'close': '16:00', 'isOpen': true},
          'sunday': {'open': '10:00', 'close': '16:00', 'isOpen': false},
        },
        'isActive': true,
        'isVerified': false,
        'isApproved': false, // Vendors need admin approval
        'profileImageUrl': '',
        'businessLogo': '',
        'businessImages': [],
        'rating': 0.0,
        'totalReviews': 0,
        'totalOrders': 0,
        'totalEarnings': 0.0,
        'bankDetails': {},
        'preferences': {
          'notifications': true,
          'sms': true,
          'email': true,
          'orderNotifications': true,
          'paymentNotifications': true,
        },
        'location': {
          'latitude': 0.0,
          'longitude': 0.0,
          'address': businessAddress ?? '',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return ApiResponse(
        code: 200,
        message: "Vendor registered successfully. Awaiting admin approval.",
        body: {
          'user': {
            'uid': userCredential.user!.uid,
            'fullName': fullName,
            'phone': phone,
            'email': email,
            'businessName': businessName,
            'userType': 'vendor',
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

      // Get vendor data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return ApiResponse(code: 404, message: "Vendor profile not found");
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Check if vendor is approved
      if (userData['isApproved'] != true) {
        return ApiResponse(
          code: 403, 
          message: "Your vendor account is pending admin approval. Please wait for approval."
        );
      }

      // Check if vendor is active
      if (userData['isActive'] != true) {
        return ApiResponse(
          code: 403, 
          message: "Your vendor account has been deactivated. Please contact support."
        );
      }

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
          message = "No vendor account found with this phone number";
          break;
        case 'wrong-password':
          message = "Incorrect password";
          break;
        case 'user-disabled':
          message = "This vendor account has been disabled";
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
        'https://api.classy.app/api/otp/send', // Replace with actual API URL
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

  /// Update vendor profile
  static Future<ApiResponse> updateProfile({
    required String businessName,
    required String fullName,
    String? businessType,
    String? businessAddress,
    String? businessDescription,
    String? profileImageUrl,
    String? businessLogo,
    Map<String, dynamic>? businessHours,
    Map<String, dynamic>? location,
    Map<String, dynamic>? bankDetails,
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

      // Prepare update data
      Map<String, dynamic> updateData = {
        'fullName': fullName,
        'businessName': businessName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add optional fields if provided
      if (businessType != null) updateData['businessType'] = businessType;
      if (businessAddress != null) updateData['businessAddress'] = businessAddress;
      if (businessDescription != null) updateData['businessDescription'] = businessDescription;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      if (businessLogo != null) updateData['businessLogo'] = businessLogo;
      if (businessHours != null) updateData['businessHours'] = businessHours;
      if (location != null) updateData['location'] = location;
      if (bankDetails != null) updateData['bankDetails'] = bankDetails;

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update(updateData);

      return ApiResponse(
        code: 200,
        message: "Profile updated successfully"
      );
    } catch (e) {
      return ApiResponse(code: 500, message: "Profile update failed: ${e.toString()}");
    }
  }

  /// Get vendor profile from Firestore
  static Future<ApiResponse> getVendorProfile() async {
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
        return ApiResponse(code: 404, message: "Vendor profile not found");
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

  /// Get vendor statistics
  static Future<ApiResponse> getVendorStatistics() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Get orders for this vendor
      QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('vendorId', isEqualTo: user.uid)
          .get();

      int totalOrders = ordersSnapshot.docs.length;
      double totalEarnings = 0.0;
      int completedOrders = 0;
      int pendingOrders = 0;

      for (var doc in ordersSnapshot.docs) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
        
        if (orderData['status'] == 'completed') {
          completedOrders++;
          totalEarnings += (orderData['vendorAmount'] ?? 0.0).toDouble();
        } else if (orderData['status'] == 'pending') {
          pendingOrders++;
        }
      }

      // Get reviews for this vendor
      QuerySnapshot reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('vendorId', isEqualTo: user.uid)
          .get();

      int totalReviews = reviewsSnapshot.docs.length;
      double averageRating = 0.0;

      if (totalReviews > 0) {
        double totalRating = 0.0;
        for (var doc in reviewsSnapshot.docs) {
          Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
          totalRating += (reviewData['rating'] ?? 0.0).toDouble();
        }
        averageRating = totalRating / totalReviews;
      }

      return ApiResponse(
        code: 200,
        message: "Statistics retrieved successfully",
        body: {
          'statistics': {
            'totalOrders': totalOrders,
            'completedOrders': completedOrders,
            'pendingOrders': pendingOrders,
            'totalEarnings': totalEarnings,
            'totalReviews': totalReviews,
            'averageRating': averageRating,
          }
        }
      );
    } catch (e) {
      return ApiResponse(code: 500, message: "Failed to get statistics: ${e.toString()}");
    }
  }

  /// Listen to vendor profile changes
  static Stream<DocumentSnapshot> listenToVendorProfile() {
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

/// API Response model for consistency
class ApiResponse {
  final int code;
  final String message;
  final Map<String, dynamic>? body;

  ApiResponse({
    required this.code,
    required this.message,
    this.body,
  });

  bool get isSuccess => code >= 200 && code < 300;
}
