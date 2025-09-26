import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/models/api_response.dart';

class AuthComprehensiveTestService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>> runCompleteAuthTest() async {
    print("\n🧪 COMPREHENSIVE AUTHENTICATION TEST");
    print("=" * 50);
    
    Map<String, dynamic> results = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': kIsWeb ? 'web' : 'mobile',
      'tests': <String, dynamic>{},
      'overall_success': false,
    };

    try {
      // Test 1: Firebase Initialization
      print("\n1️⃣ Testing Firebase Initialization...");
      results['tests']['firebase_init'] = await _testFirebaseInit();
      
      // Test 2: Registration Flow
      print("\n2️⃣ Testing Registration Flow...");
      results['tests']['registration'] = await _testRegistration();
      
      // Test 3: Login Flow
      print("\n3️⃣ Testing Login Flow...");
      results['tests']['login'] = await _testLogin();
      
      // Test 4: User Data Persistence
      print("\n4️⃣ Testing User Data Persistence...");
      results['tests']['user_persistence'] = await _testUserPersistence();
      
      // Test 5: Authentication State
      print("\n5️⃣ Testing Authentication State...");
      results['tests']['auth_state'] = await _testAuthState();
      
      // Test 6: Logout Flow
      print("\n6️⃣ Testing Logout Flow...");
      results['tests']['logout'] = await _testLogout();
      
      // Calculate overall success
      bool allTestsPassed = results['tests'].values.every((test) => test['success'] == true);
      results['overall_success'] = allTestsPassed;
      
      print("\n📊 COMPREHENSIVE TEST RESULTS:");
      print("=" * 50);
      print("Overall Success: ${allTestsPassed ? '✅ PASS' : '❌ FAIL'}");
      
      for (String testName in results['tests'].keys) {
        var test = results['tests'][testName];
        print("$testName: ${test['success'] ? '✅ PASS' : '❌ FAIL'} - ${test['message']}");
      }
      
      return results;
      
    } catch (e) {
      print("❌ Comprehensive test failed: $e");
      results['error'] = e.toString();
      return results;
    }
  }

  static Future<Map<String, dynamic>> _testFirebaseInit() async {
    try {
      // Check if Firebase is initialized
      final currentUser = auth.currentUser;
      print("✅ Firebase Auth instance available");
      print("✅ Firestore instance available");
      
      return {
        'success': true,
        'message': 'Firebase initialized successfully',
        'current_user': currentUser?.uid,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Firebase initialization failed: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> _testRegistration() async {
    try {
      // Generate unique test data
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testPhone = "+250788${timestamp.toString().substring(8)}";
      final testEmail = "test${timestamp}@classy.app";
      final testName = "Test User $timestamp";
      final testPassword = "TestPassword123!";
      
      print("📝 Testing registration with:");
      print("   Phone: $testPhone");
      print("   Email: $testEmail");
      print("   Name: $testName");
      
      final apiResponse = await AuthRequest.registerRequest({
        'name': testName,
        'phone': testPhone,
        'password': testPassword,
        'email': testEmail,
        'country_code': 'RW',
        'referral_code': '',
      });
      
      if (apiResponse.code == 200) {
        print("✅ Registration successful");
        print("✅ User data: ${apiResponse.body['user']}");
        
        return {
          'success': true,
          'message': 'Registration completed successfully',
          'user_id': apiResponse.body['user']['id'],
          'response_code': apiResponse.code,
        };
      } else {
        print("❌ Registration failed: ${apiResponse.message}");
        return {
          'success': false,
          'message': 'Registration failed: ${apiResponse.message}',
          'response_code': apiResponse.code,
        };
      }
    } catch (e) {
      print("❌ Registration test error: $e");
      return {
        'success': false,
        'message': 'Registration test failed: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> _testLogin() async {
    try {
      // Use a known test account or create one
      final testPhone = "+250788888116"; // Use existing test account
      final testPassword = "password123";
      
      print("🔐 Testing login with:");
      print("   Phone: $testPhone");
      
      final apiResponse = await AuthRequest.loginRequest({
        'phone': testPhone,
        'password': testPassword,
      });
      
      if (apiResponse.code == 200) {
        print("✅ Login successful");
        print("✅ User authenticated: ${apiResponse.body['user']['id']}");
        
        return {
          'success': true,
          'message': 'Login completed successfully',
          'user_id': apiResponse.body['user']['id'],
          'response_code': apiResponse.code,
        };
      } else {
        print("❌ Login failed: ${apiResponse.message}");
        return {
          'success': false,
          'message': 'Login failed: ${apiResponse.message}',
          'response_code': apiResponse.code,
        };
      }
    } catch (e) {
      print("❌ Login test error: $e");
      return {
        'success': false,
        'message': 'Login test failed: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> _testUserPersistence() async {
    try {
      // Test if user data is properly saved and retrieved
      final currentUser = await AuthServices.getCurrentUser();
      
      if (currentUser != null) {
        print("✅ User data retrieved successfully");
        print("✅ User ID: ${currentUser.id}");
        print("✅ User Name: ${currentUser.name}");
        print("✅ User Email: ${currentUser.email}");
        print("✅ User Phone: ${currentUser.phone}");
        print("✅ User Role: ${currentUser.role}");
        
        return {
          'success': true,
          'message': 'User data persistence working',
          'user_id': currentUser.id,
          'user_name': currentUser.name,
        };
      } else {
        print("❌ No user data found");
        return {
          'success': false,
          'message': 'User data not found',
        };
      }
    } catch (e) {
      print("❌ User persistence test error: $e");
      return {
        'success': false,
        'message': 'User persistence test failed: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> _testAuthState() async {
    try {
      // Test authentication state
      final isAuthenticated = AuthServices.authenticated();
      final currentUser = auth.currentUser;
      
      print("🔐 Authentication state check:");
      print("   Local auth state: $isAuthenticated");
      print("   Firebase current user: ${currentUser?.uid}");
      
      if (isAuthenticated && currentUser != null) {
        print("✅ Authentication state is correct");
        return {
          'success': true,
          'message': 'Authentication state is valid',
          'local_auth': isAuthenticated,
          'firebase_user': currentUser.uid,
        };
      } else {
        print("❌ Authentication state mismatch");
        return {
          'success': false,
          'message': 'Authentication state mismatch',
          'local_auth': isAuthenticated,
          'firebase_user': currentUser?.uid,
        };
      }
    } catch (e) {
      print("❌ Auth state test error: $e");
      return {
        'success': false,
        'message': 'Auth state test failed: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> _testLogout() async {
    try {
      // Test logout functionality
      await AuthRequest.logoutRequest();
      
      final isAuthenticated = AuthServices.authenticated();
      final currentUser = auth.currentUser;
      
      print("🚪 Logout test:");
      print("   Local auth state: $isAuthenticated");
      print("   Firebase current user: ${currentUser?.uid}");
      
      if (!isAuthenticated && currentUser == null) {
        print("✅ Logout successful");
        return {
          'success': true,
          'message': 'Logout completed successfully',
        };
      } else {
        print("❌ Logout failed - user still authenticated");
        return {
          'success': false,
          'message': 'Logout failed - user still authenticated',
        };
      }
    } catch (e) {
      print("❌ Logout test error: $e");
      return {
        'success': false,
        'message': 'Logout test failed: $e',
      };
    }
  }

  static Future<void> printAuthStatus() async {
    print("\n📊 CURRENT AUTHENTICATION STATUS");
    print("=" * 40);
    
    try {
      final currentUser = auth.currentUser;
      final isAuthenticated = AuthServices.authenticated();
      final localUser = await AuthServices.getCurrentUser();
      
      print("Firebase Current User: ${currentUser?.uid ?? 'None'}");
      print("Local Auth State: $isAuthenticated");
      print("Local User: ${localUser?.id ?? 'None'}");
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      
      if (currentUser != null) {
        print("User Email: ${currentUser.email}");
        print("User Display Name: ${currentUser.displayName}");
        print("User Creation Time: ${currentUser.metadata.creationTime}");
        print("User Last Sign In: ${currentUser.metadata.lastSignInTime}");
      }
      
    } catch (e) {
      print("❌ Error getting auth status: $e");
    }
  }
}
