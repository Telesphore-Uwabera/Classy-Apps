import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/user.dart' as app_user;
import 'firebase_service.dart';

class AuthService extends ChangeNotifier {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();

  final FirebaseService _firebaseService = FirebaseService.instance;
  app_user.User? _currentUser;

  app_user.User? get currentUser => _currentUser;

  /// Sign in with email and password - Simple and Clean
  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      print("🔐 Attempting email/password login: $email");
      
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create basic user data
        final basicUserData = {
          'id': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? 'Vendor',
          'email': userCredential.user!.email ?? email,
          'phone': userCredential.user!.phoneNumber ?? '',
          'userType': 'vendor',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        await _saveUser(basicUserData);
        
        // Ensure user exists in Firestore
        await _ensureUserExistsInFirestore(userCredential.user!.uid);
        
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
  Future<Map<String, dynamic>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String businessName,
    String? phone,
  }) async {
    try {
      print("📝 Attempting email/password registration: $email");
      
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(businessName);
        
        // Prepare user data
        final userData = {
          'id': userCredential.user!.uid,
          'name': businessName,
          'email': email,
          'phone': phone ?? '',
          'userType': 'vendor',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        // Save locally
        await _saveUser(userData);
        
        // Save to Firestore
        await _saveUserToFirestore(userData);
        
        // Create vendor document
        await _saveVendorToFirestore(userData);
        
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

  /// Save user data locally
  Future<void> _saveUser(Map<String, dynamic> userData) async {
    try {
      // Convert String IDs to int for User model compatibility
      final processedUserData = Map<String, dynamic>.from(userData);
      if (processedUserData['id'] is String) {
        processedUserData['id'] = int.tryParse(processedUserData['id']) ?? 0;
      }
      if (processedUserData['vendor_id'] is String) {
        processedUserData['vendor_id'] = int.tryParse(processedUserData['vendor_id']);
      }
      
      final user = app_user.User.fromJson(processedUserData);
      _currentUser = user;
      notifyListeners();
      print("✅ User saved locally: ${user.name}");
    } catch (e) {
      print("❌ Error saving user locally: $e");
    }
  }

  /// Save user to Firestore
  Future<void> _saveUserToFirestore(Map<String, dynamic> userData) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userData['id']).set(userData);
      print("✅ User saved to Firestore: ${userData['id']}");
    } catch (e) {
      print("❌ Error saving user to Firestore: $e");
      // Don't throw error - user is still authenticated
    }
  }

  /// Save vendor to Firestore
  Future<void> _saveVendorToFirestore(Map<String, dynamic> userData) async {
    try {
      final vendorData = {
        'id': userData['id'],
        'businessName': userData['name'],
        'email': userData['email'],
        'phone': userData['phone'],
        'status': 'offline',
        'isActive': true,
        'rating': 0.0,
        'totalOrders': 0,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      await FirebaseFirestore.instance.collection('vendors').doc(userData['id']).set(vendorData);
      print("✅ Vendor saved to Firestore: ${userData['id']}");
    } catch (e) {
      print("❌ Error saving vendor to Firestore: $e");
    }
  }

  /// Check if user exists in Firestore and create if not
  Future<void> _ensureUserExistsInFirestore(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) {
        // User doesn't exist in Firestore, create them
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userData = {
            'id': currentUser.uid,
            'name': currentUser.displayName ?? 'Vendor',
            'email': currentUser.email ?? '',
            'phone': currentUser.phoneNumber ?? '',
            'userType': 'vendor',
            'status': 'pending',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          };
          await _saveUserToFirestore(userData);
        }
      }
    } catch (e) {
      print("❌ Error checking/creating user in Firestore: $e");
    }
  }

  /// Legacy methods for backward compatibility
  Future<bool> signIn(String email, String password) async {
    final result = await signInWithEmailPassword(email: email, password: password);
    return result['success'] == true;
  }

  Future<bool> signUp(String email, String password, String businessName, String phone) async {
    final result = await signUpWithEmailPassword(
      email: email, 
      password: password, 
      businessName: businessName, 
      phone: phone
    );
    return result['success'] == true;
  }

  Future<void> signOut() async {
    try {
      print("🚪 Signing out...");
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear current user
      _currentUser = null;
      notifyListeners();
      
      print("✅ Sign out completed");
    } catch (e) {
      print("❌ Sign out error: $e");
      // Still clear local data even if Firebase sign out fails
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<app_user.User?> _getUserFromFirebase(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return app_user.User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  Future<bool> updateUser(app_user.User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id.toString()).update(user.toJson());
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }

  Future<bool> isVendor() async {
    if (_currentUser == null) return false;
    return _currentUser!.userType == 'vendor';
  }

  Future<bool> isAdmin() async {
    if (_currentUser == null) return false;
    return _currentUser!.userType == 'admin';
  }
}
