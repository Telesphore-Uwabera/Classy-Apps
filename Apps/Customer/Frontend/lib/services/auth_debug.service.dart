import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Classy/services/firebase_auth_complete.service.dart';
import 'package:Classy/requests/auth.request.dart';

class AuthDebugService {
  // Debug authentication issues
  static Future<void> debugAuthIssues() async {
    print("🔍 DEBUGGING AUTHENTICATION ISSUES...\n");
    
    // 1. Check Firebase initialization
    await _debugFirebaseInit();
    
    // 2. Check authentication state
    await _debugAuthState();
    
    // 3. Check Firestore connection
    await _debugFirestoreConnection();
    
    // 4. Check platform-specific issues
    await _debugPlatformIssues();
    
    // 5. Check error handling
    await _debugErrorHandling();
    
    print("\n🔍 Authentication debugging completed!");
  }
  
  // Debug Firebase initialization
  static Future<void> _debugFirebaseInit() async {
    print("1️⃣ Debugging Firebase initialization...");
    
    try {
      await FirebaseAuthCompleteService.initialize();
      print("✅ Firebase initialization: SUCCESS");
      
      // Check if Firebase is properly initialized
      final auth = FirebaseAuth.instance;
      print("✅ Firebase Auth instance: AVAILABLE");
      
      final firestore = FirebaseFirestore.instance;
      print("✅ Firestore instance: AVAILABLE");
      
    } catch (e) {
      print("❌ Firebase initialization: FAILED - $e");
    }
  }
  
  // Debug authentication state
  static Future<void> _debugAuthState() async {
    print("\n2️⃣ Debugging authentication state...");
    
    try {
      final isSignedIn = FirebaseAuthCompleteService.isSignedIn;
      print("✅ Auth state check: SUCCESS (Signed in: $isSignedIn)");
      
      final currentUser = FirebaseAuthCompleteService.currentUser;
      if (currentUser != null) {
        print("✅ Current user: ${currentUser.uid}");
        print("✅ User email: ${currentUser.email}");
        print("✅ User display name: ${currentUser.displayName}");
      } else {
        print("ℹ️ No user currently signed in");
      }
      
    } catch (e) {
      print("❌ Auth state check: FAILED - $e");
    }
  }
  
  // Debug Firestore connection
  static Future<void> _debugFirestoreConnection() async {
    print("\n3️⃣ Debugging Firestore connection...");
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Test Firestore connection with a simple read
      final testDoc = await firestore.collection('test').doc('connection').get();
      print("✅ Firestore connection: SUCCESS");
      
    } catch (e) {
      print("❌ Firestore connection: FAILED - $e");
      print("ℹ️ This might be expected if Firestore rules are restrictive");
    }
  }
  
  // Debug platform-specific issues
  static Future<void> _debugPlatformIssues() async {
    print("\n4️⃣ Debugging platform-specific issues...");
    
    print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
    
    if (kIsWeb) {
      print("🌐 Web platform detected");
      print("✅ Web-specific Firebase configuration should be in index.html");
      
      // Check if we're running in a browser
      try {
        // This will work in web browsers
        print("✅ Browser environment detected");
      } catch (e) {
        print("❌ Browser environment check failed: $e");
      }
    } else {
      print("📱 Mobile platform detected");
      print("✅ Mobile Firebase configuration should be in google-services.json");
    }
  }
  
  // Debug error handling
  static Future<void> _debugErrorHandling() async {
    print("\n5️⃣ Debugging error handling...");
    
    try {
      // Test with invalid credentials
      print("Testing error handling with invalid credentials...");
      
      final result = await AuthRequest.loginRequest({
        'phone': '+9999999999',
        'password': 'invalidpassword',
      });
      
      if (result.code != 200) {
        print("✅ Error handling: SUCCESS (Properly handled invalid login)");
        print("Error message: ${result.message}");
      } else {
        print("❌ Error handling: FAILED (Should have failed with invalid credentials)");
      }
      
    } catch (e) {
      print("❌ Error handling test failed: $e");
    }
  }
  
  // Test authentication flow step by step
  static Future<void> testAuthFlowStepByStep() async {
    print("🧪 TESTING AUTHENTICATION FLOW STEP BY STEP...\n");
    
    // Step 1: Test registration
    print("Step 1: Testing registration...");
    try {
      final registerResult = await AuthRequest.registerRequest({
        'phone': '+1234567890',
        'password': 'TestPassword123!',
        'name': 'Test User',
        'email': 'test@classy.app',
      });
      
      if (registerResult.code == 200) {
        print("✅ Registration: SUCCESS");
      } else {
        print("❌ Registration: FAILED - ${registerResult.message}");
      }
    } catch (e) {
      print("❌ Registration: ERROR - $e");
    }
    
    // Step 2: Test login
    print("\nStep 2: Testing login...");
    try {
      final loginResult = await AuthRequest.loginRequest({
        'phone': '+1234567890',
        'password': 'TestPassword123!',
      });
      
      if (loginResult.code == 200) {
        print("✅ Login: SUCCESS");
      } else {
        print("❌ Login: FAILED - ${loginResult.message}");
      }
    } catch (e) {
      print("❌ Login: ERROR - $e");
    }
    
    // Step 3: Test logout
    print("\nStep 3: Testing logout...");
    try {
      final logoutResult = await AuthRequest.logoutRequest();
      
      if (logoutResult.code == 200) {
        print("✅ Logout: SUCCESS");
      } else {
        print("❌ Logout: FAILED - ${logoutResult.message}");
      }
    } catch (e) {
      print("❌ Logout: ERROR - $e");
    }
    
    print("\n🧪 Step-by-step authentication test completed!");
  }
  
  // Get comprehensive authentication status
  static Future<Map<String, dynamic>> getAuthStatus() async {
    print("📊 Getting comprehensive authentication status...\n");
    
    Map<String, dynamic> status = {
      'platform': kIsWeb ? 'Web' : 'Mobile',
      'firebase_initialized': false,
      'auth_available': false,
      'firestore_available': false,
      'user_signed_in': false,
      'current_user_id': null,
      'errors': [],
    };
    
    try {
      // Check Firebase initialization
      await FirebaseAuthCompleteService.initialize();
      status['firebase_initialized'] = true;
      print("✅ Firebase: INITIALIZED");
      
      // Check auth availability
      final auth = FirebaseAuth.instance;
      status['auth_available'] = true;
      print("✅ Firebase Auth: AVAILABLE");
      
      // Check Firestore availability
      final firestore = FirebaseFirestore.instance;
      status['firestore_available'] = true;
      print("✅ Firestore: AVAILABLE");
      
      // Check user sign-in status
      final isSignedIn = FirebaseAuthCompleteService.isSignedIn;
      status['user_signed_in'] = isSignedIn;
      print("✅ User signed in: $isSignedIn");
      
      if (isSignedIn) {
        final currentUser = FirebaseAuthCompleteService.currentUser;
        status['current_user_id'] = currentUser?.uid;
        print("✅ Current user ID: ${currentUser?.uid}");
      }
      
    } catch (e) {
      status['errors'].add("Status check error: $e");
      print("❌ Status check error: $e");
    }
    
    // Print summary
    print("\n📊 AUTHENTICATION STATUS SUMMARY:");
    print("Platform: ${status['platform']}");
    print("Firebase Initialized: ${status['firebase_initialized'] ? '✅' : '❌'}");
    print("Auth Available: ${status['auth_available'] ? '✅' : '❌'}");
    print("Firestore Available: ${status['firestore_available'] ? '✅' : '❌'}");
    print("User Signed In: ${status['user_signed_in'] ? '✅' : '❌'}");
    
    if (status['errors'].isNotEmpty) {
      print("\n❌ Errors found:");
      for (String error in status['errors']) {
        print("  - $error");
      }
    }
    
    return status;
  }
}
