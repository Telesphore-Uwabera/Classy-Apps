import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

/// Firebase Authentication Service for Driver App
/// Handles all authentication using Firebase directly (no API calls)
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Dio _dio = Dio();

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register driver with phone (converted to email format for Firebase)
  static Future<ApiResponse> register({
    required String fullName,
    required String phone,
    required String password,
    required String confirmPassword,
    required String licenseNumber,
    required String vehicleType,
    required String vehiclePlate,
    String? vehicleModel,
    String? vehicleColor,
    String? emergencyContact,
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

      // Save driver data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'userType': 'driver',
        'licenseNumber': licenseNumber,
        'vehicleDetails': {
          'type': vehicleType,
          'plateNumber': vehiclePlate,
          'model': vehicleModel ?? '',
          'color': vehicleColor ?? '',
          'year': '',
        },
        'emergencyContact': emergencyContact ?? '',
        'workingHours': {
          'startTime': '06:00',
          'endTime': '22:00',
          'workingDays': ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'],
        },
        'isActive': true,
        'isVerified': false,
        'isApproved': false, // Drivers need admin approval
        'isOnline': false,
        'isAvailable': false,
        'profileImageUrl': '',
        'licenseImageUrl': '',
        'vehicleImages': [],
        'rating': 0.0,
        'totalReviews': 0,
        'totalDeliveries': 0,
        'totalEarnings': 0.0,
        'currentLocation': {
          'latitude': 0.0,
          'longitude': 0.0,
          'address': '',
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        'bankDetails': {},
        'preferences': {
          'notifications': true,
          'sms': true,
          'email': true,
          'orderNotifications': true,
          'locationSharing': true,
          'paymentNotifications': true,
        },
        'documents': {
          'license': {'url': '', 'verified': false},
          'insurance': {'url': '', 'verified': false},
          'registration': {'url': '', 'verified': false},
          'nationalId': {'url': '', 'verified': false},
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return ApiResponse(
        code: 200,
        message: "Driver registered successfully. Awaiting admin approval.",
        body: {
          'user': {
            'uid': userCredential.user!.uid,
            'fullName': fullName,
            'phone': phone,
            'email': email,
            'userType': 'driver',
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

      // Get driver data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return ApiResponse(code: 404, message: "Driver profile not found");
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Check if driver is approved
      if (userData['isApproved'] != true) {
        return ApiResponse(
          code: 403, 
          message: "Your driver account is pending admin approval. Please wait for approval."
        );
      }

      // Check if driver is active
      if (userData['isActive'] != true) {
        return ApiResponse(
          code: 403, 
          message: "Your driver account has been deactivated. Please contact support."
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
          message = "No driver account found with this phone number";
          break;
        case 'wrong-password':
          message = "Incorrect password";
          break;
        case 'user-disabled':
          message = "This driver account has been disabled";
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

  /// Update driver location
  static Future<ApiResponse> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      await _firestore.collection('users').doc(user.uid).update({
        'currentLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'address': address ?? '',
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return ApiResponse(
        code: 200,
        message: "Location updated successfully"
      );
    } catch (e) {
      return ApiResponse(code: 500, message: "Location update failed: ${e.toString()}");
    }
  }

  /// Update driver availability status
  static Future<ApiResponse> updateAvailability({
    required bool isOnline,
    required bool isAvailable,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return ApiResponse(
        code: 200,
        message: "Availability updated successfully"
      );
    } catch (e) {
      return ApiResponse(code: 500, message: "Availability update failed: ${e.toString()}");
    }
  }

  /// Update driver profile
  static Future<ApiResponse> updateProfile({
    required String fullName,
    String? licenseNumber,
    Map<String, dynamic>? vehicleDetails,
    String? emergencyContact,
    String? profileImageUrl,
    Map<String, dynamic>? workingHours,
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
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add optional fields if provided
      if (licenseNumber != null) updateData['licenseNumber'] = licenseNumber;
      if (vehicleDetails != null) updateData['vehicleDetails'] = vehicleDetails;
      if (emergencyContact != null) updateData['emergencyContact'] = emergencyContact;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      if (workingHours != null) updateData['workingHours'] = workingHours;
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

  /// Get driver statistics
  static Future<ApiResponse> getDriverStatistics() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Get deliveries for this driver
      QuerySnapshot deliveriesSnapshot = await _firestore
          .collection('orders')
          .where('driverId', isEqualTo: user.uid)
          .get();

      int totalDeliveries = deliveriesSnapshot.docs.length;
      double totalEarnings = 0.0;
      int completedDeliveries = 0;
      int activeDeliveries = 0;

      for (var doc in deliveriesSnapshot.docs) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
        
        if (orderData['status'] == 'delivered') {
          completedDeliveries++;
          totalEarnings += (orderData['driverAmount'] ?? 0.0).toDouble();
        } else if (orderData['status'] == 'in_transit' || orderData['status'] == 'picked_up') {
          activeDeliveries++;
        }
      }

      // Get reviews for this driver
      QuerySnapshot reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('driverId', isEqualTo: user.uid)
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
            'totalDeliveries': totalDeliveries,
            'completedDeliveries': completedDeliveries,
            'activeDeliveries': activeDeliveries,
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

  /// Listen to driver profile changes
  static Stream<DocumentSnapshot> listenToDriverProfile() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  /// Sign out
  static Future<ApiResponse> signOut() async {
    try {
      // Update availability to offline before signing out
      User? user = _auth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).update({
            'isOnline': false,
            'isAvailable': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error updating availability on logout: $e');
        }
      }

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

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] ?? json['status'] ?? 500,
      message: json['message'] ?? json['error'] ?? 'Unknown error',
      body: json['data'] ?? json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'body': body,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(code: $code, message: $message, body: $body)';
  }
}
