import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:Classy/models/user.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/firebase_data.service.dart';

class FirebaseUserProfileService {
  static final FirebaseUserProfileService _instance = FirebaseUserProfileService._internal();
  factory FirebaseUserProfileService() => _instance;
  FirebaseUserProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDataService _firebaseDataService = FirebaseDataService();

  // Stream controllers for real-time user profile updates
  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  final StreamController<Map<String, dynamic>> _profileUpdatesController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams for listening to user profile data
  Stream<User?> get userStream => _userController.stream;
  Stream<Map<String, dynamic>> get profileUpdatesStream => _profileUpdatesController.stream;

  // Stream subscription
  StreamSubscription<User?>? _userSubscription;

  /// Initialize user profile service
  void initialize() {
    _startRealTimeUpdates();
  }

  /// Start real-time updates for user profile
  void _startRealTimeUpdates() {
    final currentUser = _auth.currentUser;
    if (currentUser?.uid == null) return;

    _userSubscription?.cancel();
    _userSubscription = listenToUserProfile(currentUser!.uid).listen((user) {
      _userController.add(user);
      if (user != null) {
        _profileUpdatesController.add(user.toJson());
      }
    });
  }

  /// Get user profile
  Future<ApiResponse> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        return ApiResponse(code: 404, message: "User not found");
      }

      final userData = doc.data()!;
      final user = User.fromJson(userData);

      return ApiResponse(
        code: 200,
        message: "User profile fetched successfully",
        body: user.toJson(),
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to fetch user profile: $e",
        body: null,
        errors: ["Failed to fetch user profile: $e"],
      );
    }
  }

  /// Update user profile
  Future<ApiResponse> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.uid != userId) {
        return ApiResponse(code: 403, message: "Unauthorized to update this profile");
      }

      // Add timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _firestore.collection('users').doc(userId).update(updates);

      return ApiResponse(
        code: 200,
        message: "User profile updated successfully",
        body: updates,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to update user profile: $e",
        body: null,
        errors: ["Failed to update user profile: $e"],
      );
    }
  }

  /// Update user avatar
  Future<ApiResponse> updateUserAvatar(String userId, String avatarUrl) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.uid != userId) {
        return ApiResponse(code: 403, message: "Unauthorized to update this profile");
      }

      await _firestore.collection('users').doc(userId).update({
        'photo': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return ApiResponse(
        code: 200,
        message: "User avatar updated successfully",
        body: {'photo': avatarUrl},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to update user avatar: $e",
        body: null,
        errors: ["Failed to update user avatar: $e"],
      );
    }
  }

  /// Update user address
  Future<ApiResponse> updateUserAddress(String userId, Map<String, dynamic> addressData) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.uid != userId) {
        return ApiResponse(code: 403, message: "Unauthorized to update this profile");
      }

      await _firestore.collection('users').doc(userId).update({
        'address': addressData,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return ApiResponse(
        code: 200,
        message: "User address updated successfully",
        body: addressData,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to update user address: $e",
        body: null,
        errors: ["Failed to update user address: $e"],
      );
    }
  }

  /// Update user preferences
  Future<ApiResponse> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.uid != userId) {
        return ApiResponse(code: 403, message: "Unauthorized to update this profile");
      }

      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return ApiResponse(
        code: 200,
        message: "User preferences updated successfully",
        body: preferences,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to update user preferences: $e",
        body: null,
        errors: ["Failed to update user preferences: $e"],
      );
    }
  }

  /// Change user password
  Future<ApiResponse> changePassword(String currentPassword, String newPassword) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Update password
      await currentUser.updatePassword(newPassword);

      return ApiResponse(
        code: 200,
        message: "Password changed successfully",
        body: null,
        errors: null,
      );
    } catch (e) {
      String errorMessage = "Failed to change password";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            errorMessage = "Current password is incorrect";
            break;
          case 'weak-password':
            errorMessage = "New password is too weak";
            break;
          case 'requires-recent-login':
            errorMessage = "Please log in again to change your password";
            break;
        }
      }

      return ApiResponse(
        code: 400,
        message: errorMessage,
        body: null,
        errors: [errorMessage],
      );
    }
  }

  /// Update user email
  Future<ApiResponse> updateUserEmail(String newEmail) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      await currentUser.updateEmail(newEmail);

      // Update email in Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'email': newEmail,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return ApiResponse(
        code: 200,
        message: "Email updated successfully",
        body: {'email': newEmail},
        errors: null,
      );
    } catch (e) {
      String errorMessage = "Failed to update email";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = "Email is already in use";
            break;
          case 'invalid-email':
            errorMessage = "Invalid email address";
            break;
          case 'requires-recent-login':
            errorMessage = "Please log in again to update your email";
            break;
        }
      }

      return ApiResponse(
        code: 400,
        message: errorMessage,
        body: null,
        errors: [errorMessage],
      );
    }
  }

  /// Update user phone number
  Future<ApiResponse> updateUserPhone(String phoneNumber) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Update phone in Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'phone': phoneNumber,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return ApiResponse(
        code: 200,
        message: "Phone number updated successfully",
        body: {'phone': phoneNumber},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to update phone number: $e",
        body: null,
        errors: ["Failed to update phone number: $e"],
      );
    }
  }

  /// Delete user account
  Future<ApiResponse> deleteUserAccount(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.uid != userId) {
        return ApiResponse(code: 403, message: "Unauthorized to delete this account");
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete user from Firebase Auth
      await currentUser!.delete();

      return ApiResponse(
        code: 200,
        message: "User account deleted successfully",
        body: null,
        errors: null,
      );
    } catch (e) {
      String errorMessage = "Failed to delete user account";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            errorMessage = "Please log in again to delete your account";
            break;
        }
      }

      return ApiResponse(
        code: 400,
        message: errorMessage,
        body: null,
        errors: [errorMessage],
      );
    }
  }

  /// Get user statistics
  Future<ApiResponse> getUserStatistics(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.uid != userId) {
        return ApiResponse(code: 403, message: "Unauthorized to view this data");
      }

      // Get user orders count
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('customer_id', isEqualTo: userId)
          .get();

      // Get user reviews count
      final reviewsSnapshot = await _firestore
          .collection('ratings')
          .where('customer_id', isEqualTo: userId)
          .get();

      // Get user favorites count
      final favoritesSnapshot = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: userId)
          .get();

      final stats = {
        'total_orders': ordersSnapshot.docs.length,
        'total_reviews': reviewsSnapshot.docs.length,
        'total_favorites': favoritesSnapshot.docs.length,
        'member_since': currentUser!.metadata.creationTime?.toIso8601String(),
        'last_sign_in': currentUser.metadata.lastSignInTime?.toIso8601String(),
      };

      return ApiResponse(
        code: 200,
        message: "User statistics fetched successfully",
        body: stats,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to fetch user statistics: $e",
        body: null,
        errors: ["Failed to fetch user statistics: $e"],
      );
    }
  }

  /// Listen to user profile changes
  Stream<User?> listenToUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromJson(doc.data()!) : null);
  }

  /// Start listening to user profile
  void startListeningToUserProfile(String userId) {
    _userSubscription?.cancel();
    _userSubscription = listenToUserProfile(userId).listen((user) {
      _userController.add(user);
      if (user != null) {
        _profileUpdatesController.add(user.toJson());
      }
    });
  }

  /// Stop listening to user profile
  void stopListeningToUserProfile() {
    _userSubscription?.cancel();
  }

  /// Dispose resources
  void dispose() {
    _userSubscription?.cancel();
    _userController.close();
    _profileUpdatesController.close();
  }
}
