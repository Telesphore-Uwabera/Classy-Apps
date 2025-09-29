import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseWebAuthFixedService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static bool get isWeb => kIsWeb;

  // Initialize Firebase properly for web
  static Future<void> initialize() async {
    try {
      print("🌐 Initializing Firebase for web platform...");
      
      if (isWeb) {
        print("✅ Web platform detected");
        print("✅ Firebase Web SDK should be loaded from index.html");
        
        // Check if Firebase is available
        try {
          final currentUser = auth.currentUser;
          print("✅ Firebase Auth is available");
          print("✅ Current user: ${currentUser?.uid ?? 'None'}");
        } catch (e) {
          print("❌ Firebase Auth not available: $e");
          throw Exception("Firebase Auth not properly initialized for web");
        }
      } else {
        print("📱 Mobile platform detected");
        print("✅ Firebase should be initialized via Firebase.initializeApp()");
      }
      
    } catch (e) {
      print("❌ Firebase web initialization error: $e");
      rethrow;
    }
  }

  // Web-safe authentication method
  static Future<Map<String, dynamic>> authenticateUserWebSafe({
    required String email,
    required String password,
    bool isRegistration = false,
    String? displayName,
  }) async {
    try {
      print("🔐 Starting web-safe authentication...");
      print("📧 Email: $email");
      print("🔑 Password length: ${password.length}");
      print("📝 Registration: $isRegistration");
      print("👤 Display Name: $displayName");
      print("🌐 Platform: ${isWeb ? 'Web' : 'Mobile'}");
      
      // Check Firebase availability
      if (auth == null) {
        throw Exception("Firebase Auth not initialized");
      }
      
      UserCredential? userCredential;
      
      if (isRegistration) {
        print("📝 Attempting user registration...");
        
        try {
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
        } catch (e) {
          print("❌ Registration failed with error: $e");
          print("❌ Error type: ${e.runtimeType}");
          
          // Handle web-specific errors
          if (isWeb) {
            print("🌐 Web-specific error handling");
            
            // Handle TypeError (web compatibility issue)
            if (e.runtimeType.toString() == '_TypeError' || e.toString().contains('TypeError')) {
              print("❌ TypeError detected - web compatibility issue");
              return {
                'success': false,
                'error': 'Web compatibility error. Please try again.',
                'error_type': 'TypeError',
                'platform': 'web',
              };
            }
            
            // Handle FirebaseException
            if (e.toString().contains('FirebaseException') || e.runtimeType.toString().contains('FirebaseException')) {
              print("🔥 FirebaseException detected on web");
              return {
                'success': false,
                'error': 'Registration failed: ${_getWebErrorMessage(e)}',
                'error_type': 'FirebaseException',
                'platform': 'web',
              };
            }
            
            // Handle JavaScriptObject errors
            if (e.toString().contains('JavaScriptObject')) {
              print("❌ JavaScriptObject error detected");
              return {
                'success': false,
                'error': 'Web JavaScript compatibility error. Please try again.',
                'error_type': 'JavaScriptObject',
                'platform': 'web',
              };
            }
            
            // Generic web error
            return {
              'success': false,
              'error': 'Web compatibility error. Please try again.',
              'error_type': e.runtimeType.toString(),
              'platform': 'web',
            };
          }
          
          rethrow;
        }
      } else {
        print("🔑 Attempting user login...");
        
        try {
          userCredential = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print("✅ User login successful");
        } catch (e) {
          print("❌ Login failed with error: $e");
          print("❌ Error type: ${e.runtimeType}");
          
          // Handle web-specific errors
          if (isWeb) {
            print("🌐 Web-specific error handling");
            
            // Handle TypeError (web compatibility issue)
            if (e.runtimeType.toString() == '_TypeError' || e.toString().contains('TypeError')) {
              print("❌ TypeError detected - web compatibility issue");
              return {
                'success': false,
                'error': 'Web compatibility error. Please try again.',
                'error_type': 'TypeError',
                'platform': 'web',
              };
            }
            
            // Handle FirebaseException
            if (e.toString().contains('FirebaseException') || e.runtimeType.toString().contains('FirebaseException')) {
              print("🔥 FirebaseException detected on web");
              return {
                'success': false,
                'error': 'Login failed: ${_getWebErrorMessage(e)}',
                'error_type': 'FirebaseException',
                'platform': 'web',
              };
            }
            
            // Handle JavaScriptObject errors
            if (e.toString().contains('JavaScriptObject')) {
              print("❌ JavaScriptObject error detected");
              return {
                'success': false,
                'error': 'Web JavaScript compatibility error. Please try again.',
                'error_type': 'JavaScriptObject',
                'platform': 'web',
              };
            }
            
            // Generic web error
            return {
              'success': false,
              'error': 'Web compatibility error. Please try again.',
              'error_type': e.runtimeType.toString(),
              'platform': 'web',
            };
          }
          
          rethrow;
        }
      }
      
      if (userCredential?.user != null) {
        print("✅ User credential obtained");
        print("🆔 User ID: ${userCredential!.user!.uid}");
        print("📧 User Email: ${userCredential.user!.email}");
        print("👤 User Display Name: ${userCredential.user!.displayName}");
        
        return {
          'success': true,
          'user': userCredential.user!,
          'credential': userCredential,
          'platform': isWeb ? 'web' : 'mobile',
        };
      } else {
        print("❌ User credential is null");
        return {
          'success': false,
          'error': 'Authentication failed - no user returned',
          'platform': isWeb ? 'web' : 'mobile',
        };
      }
    } catch (e) {
      print("❌ Authentication error occurred");
      print("❌ Error type: ${e.runtimeType}");
      print("❌ Error message: $e");
      print("❌ Error details: ${e.toString()}");
      print("🌐 Platform: ${isWeb ? 'Web' : 'Mobile'}");
      
      // Enhanced error handling for web
      if (isWeb) {
        print("🌐 Web-specific error analysis");
        
        String errorMessage = _getWebErrorMessage(e);
        String errorType = e.runtimeType.toString();
        
        // Check for specific web errors
        if (e.toString().contains('TypeError')) {
          print("❌ TypeError detected - likely web compatibility issue");
          errorType = 'TypeError';
          errorMessage = 'Web compatibility error. Please try again.';
        } else if (e.toString().contains('FirebaseException')) {
          print("🔥 FirebaseException detected on web");
          errorType = 'FirebaseException';
        } else if (e.toString().contains('JavaScriptObject')) {
          print("❌ JavaScriptObject error detected");
          errorType = 'JavaScriptObject';
          errorMessage = 'Web JavaScript compatibility error. Please try again.';
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'error_type': errorType,
          'platform': 'web',
          'debug_info': {
            'original_error': e.toString(),
            'error_runtime_type': e.runtimeType.toString(),
            'is_web': true,
          },
        };
      } else {
        // Mobile error handling
        return {
          'success': false,
          'error': _getErrorMessage(e),
          'error_type': e.runtimeType.toString(),
          'platform': 'mobile',
        };
      }
    }
  }

  // Web-specific error message handling
  static String _getWebErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    print("🔍 Analyzing web error: $errorString");
    
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
    } else if (errorString.contains('typeerror')) {
      return "Web compatibility error. Please try again.";
    } else if (errorString.contains('javascriptobject')) {
      return "Web JavaScript error. Please try again.";
    } else {
      return "An error occurred. Please try again.";
    }
  }

  // General error message handling
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

  // Save user data to Firestore (web-safe)
  static Future<Map<String, dynamic>> saveUserToFirestore({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      print("💾 Saving user data to Firestore...");
      print("🆔 User ID: $uid");
      print("📊 User data keys: ${userData.keys.toList()}");
      
      await firestore.collection('users').doc(uid).set(userData);
      
      print("✅ User data saved successfully");
      return {
        'success': true,
        'message': 'User data saved successfully',
        'platform': isWeb ? 'web' : 'mobile',
      };
    } catch (e) {
      print("❌ Save user data error: $e");
      print("❌ Error type: ${e.runtimeType}");
      
      return {
        'success': false,
        'error': _getErrorMessage(e),
        'platform': isWeb ? 'web' : 'mobile',
      };
    }
  }

  // Get user data from Firestore (web-safe)
  static Future<Map<String, dynamic>> getUserFromFirestore(String uid) async {
    try {
      print("📖 Getting user data from Firestore...");
      print("🆔 User ID: $uid");
      
      final doc = await firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        print("✅ User data found");
        print("📊 User data keys: ${doc.data()?.keys.toList() ?? 'None'}");
        
        return {
          'success': true,
          'data': doc.data(),
          'platform': isWeb ? 'web' : 'mobile',
        };
      } else {
        print("❌ User document not found");
        return {
          'success': false,
          'error': 'User document not found',
          'data': null,
          'platform': isWeb ? 'web' : 'mobile',
        };
      }
    } catch (e) {
      print("❌ Get user data error: $e");
      print("❌ Error type: ${e.runtimeType}");
      
      return {
        'success': false,
        'error': _getErrorMessage(e),
        'data': null,
        'platform': isWeb ? 'web' : 'mobile',
      };
    }
  }

  // Get current user
  static User? get currentUser => auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  // Sign out
  static Future<void> signOut() async {
    try {
      print("🚪 Signing out user...");
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
      print("🎫 Getting user token...");
      final token = await currentUser?.getIdToken();
      print("✅ User token obtained");
      return token;
    } catch (e) {
      print("❌ Get token error: $e");
      return null;
    }
  }
}
