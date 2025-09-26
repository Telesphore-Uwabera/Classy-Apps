import 'package:flutter/foundation.dart';
import 'package:Classy/services/firebase_auth_complete.service.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/models/api_response.dart';

class AuthTestService {
  // Test complete authentication flow
  static Future<Map<String, dynamic>> testCompleteAuthFlow() async {
    print("🧪 Testing complete authentication flow...");
    
    Map<String, dynamic> results = {
      'firebase_init': false,
      'registration': false,
      'login': false,
      'logout': false,
      'errors': [],
    };
    
    try {
      // Test 1: Firebase initialization
      print("1️⃣ Testing Firebase initialization...");
      await FirebaseAuthCompleteService.initialize();
      results['firebase_init'] = true;
      print("✅ Firebase initialization: PASSED");
      
      // Test 2: Registration
      print("2️⃣ Testing user registration...");
      final testPhone = "+1234567890";
      final testEmail = "test@classy.app";
      final testPassword = "TestPassword123!";
      final testName = "Test User";
      
      final registerResult = await AuthRequest.registerRequest({
        'phone': testPhone,
        'password': testPassword,
        'name': testName,
        'email': testEmail,
      });
      
      if (registerResult.code == 200) {
        results['registration'] = true;
        print("✅ Registration: PASSED");
        
        // Test 3: Login
        print("3️⃣ Testing user login...");
        final loginResult = await AuthRequest.loginRequest({
          'phone': testPhone,
          'password': testPassword,
        });
        
        if (loginResult.code == 200) {
          results['login'] = true;
          print("✅ Login: PASSED");
          
          // Test 4: Logout
          print("4️⃣ Testing user logout...");
          final logoutResult = await AuthRequest.logoutRequest();
          
          if (logoutResult.code == 200) {
            results['logout'] = true;
            print("✅ Logout: PASSED");
          } else {
            results['errors'].add("Logout failed: ${logoutResult.message}");
            print("❌ Logout: FAILED - ${logoutResult.message}");
          }
        } else {
          results['errors'].add("Login failed: ${loginResult.message}");
          print("❌ Login: FAILED - ${loginResult.message}");
        }
      } else {
        results['errors'].add("Registration failed: ${registerResult.message}");
        print("❌ Registration: FAILED - ${registerResult.message}");
      }
      
    } catch (e) {
      results['errors'].add("Test error: $e");
      print("❌ Test error: $e");
    }
    
    // Print summary
    print("\n📊 Authentication Test Summary:");
    print("Firebase Init: ${results['firebase_init'] ? '✅' : '❌'}");
    print("Registration: ${results['registration'] ? '✅' : '❌'}");
    print("Login: ${results['login'] ? '✅' : '❌'}");
    print("Logout: ${results['logout'] ? '✅' : '❌'}");
    
    if (results['errors'].isNotEmpty) {
      print("\n❌ Errors found:");
      for (String error in results['errors']) {
        print("  - $error");
      }
    } else {
      print("\n🎉 All authentication tests PASSED!");
    }
    
    return results;
  }
  
  // Test platform-specific authentication
  static Future<Map<String, dynamic>> testPlatformAuth() async {
    print("🧪 Testing platform-specific authentication...");
    
    Map<String, dynamic> results = {
      'platform': kIsWeb ? 'Web' : 'Mobile',
      'firebase_available': false,
      'auth_state': false,
      'errors': [],
    };
    
    try {
      // Test Firebase availability
      print("1️⃣ Testing Firebase availability...");
      await FirebaseAuthCompleteService.initialize();
      results['firebase_available'] = true;
      print("✅ Firebase available: PASSED");
      
      // Test auth state
      print("2️⃣ Testing auth state...");
      final isSignedIn = FirebaseAuthCompleteService.isSignedIn;
      results['auth_state'] = true;
      print("✅ Auth state check: PASSED (Signed in: $isSignedIn)");
      
    } catch (e) {
      results['errors'].add("Platform test error: $e");
      print("❌ Platform test error: $e");
    }
    
    print("\n📊 Platform Test Summary:");
    print("Platform: ${results['platform']}");
    print("Firebase Available: ${results['firebase_available'] ? '✅' : '❌'}");
    print("Auth State: ${results['auth_state'] ? '✅' : '❌'}");
    
    return results;
  }
  
  // Test error handling
  static Future<Map<String, dynamic>> testErrorHandling() async {
    print("🧪 Testing error handling...");
    
    Map<String, dynamic> results = {
      'invalid_login': false,
      'invalid_registration': false,
      'network_error': false,
      'errors': [],
    };
    
    try {
      // Test invalid login
      print("1️⃣ Testing invalid login...");
      final invalidLoginResult = await AuthRequest.loginRequest({
        'phone': '+9999999999',
        'password': 'wrongpassword',
      });
      
      if (invalidLoginResult.code != 200) {
        results['invalid_login'] = true;
        print("✅ Invalid login handled: PASSED");
      } else {
        results['errors'].add("Invalid login should have failed");
        print("❌ Invalid login: FAILED - Should have failed");
      }
      
      // Test invalid registration
      print("2️⃣ Testing invalid registration...");
      final invalidRegisterResult = await AuthRequest.registerRequest({
        'phone': '+1111111111',
        'password': 'weak',
        'name': 'Test',
        'email': 'invalid',
      });
      
      if (invalidRegisterResult.code != 200) {
        results['invalid_registration'] = true;
        print("✅ Invalid registration handled: PASSED");
      } else {
        results['errors'].add("Invalid registration should have failed");
        print("❌ Invalid registration: FAILED - Should have failed");
      }
      
    } catch (e) {
      results['errors'].add("Error handling test error: $e");
      print("❌ Error handling test error: $e");
    }
    
    print("\n📊 Error Handling Test Summary:");
    print("Invalid Login: ${results['invalid_login'] ? '✅' : '❌'}");
    print("Invalid Registration: ${results['invalid_registration'] ? '✅' : '❌'}");
    
    return results;
  }
  
  // Run all tests
  static Future<Map<String, dynamic>> runAllTests() async {
    print("🚀 Running comprehensive authentication tests...\n");
    
    Map<String, dynamic> allResults = {
      'complete_flow': await testCompleteAuthFlow(),
      'platform_auth': await testPlatformAuth(),
      'error_handling': await testErrorHandling(),
    };
    
    // Calculate overall success
    bool overallSuccess = true;
    int totalTests = 0;
    int passedTests = 0;
    
    for (String testType in allResults.keys) {
      Map<String, dynamic> testResults = allResults[testType];
      for (String key in testResults.keys) {
        if (key != 'errors' && testResults[key] is bool) {
          totalTests++;
          if (testResults[key] == true) {
            passedTests++;
          } else {
            overallSuccess = false;
          }
        }
      }
    }
    
    allResults['overall_success'] = overallSuccess;
    allResults['total_tests'] = totalTests;
    allResults['passed_tests'] = passedTests;
    allResults['success_rate'] = totalTests > 0 ? (passedTests / totalTests * 100).toStringAsFixed(1) : '0.0';
    
    print("\n🎯 FINAL TEST RESULTS:");
    print("Overall Success: ${overallSuccess ? '✅' : '❌'}");
    print("Tests Passed: $passedTests/$totalTests");
    print("Success Rate: ${allResults['success_rate']}%");
    
    if (overallSuccess) {
      print("\n🎉 ALL AUTHENTICATION TESTS PASSED!");
      print("✅ Firebase authentication is working perfectly!");
    } else {
      print("\n⚠️ Some tests failed. Check the errors above.");
    }
    
    return allResults;
  }
}
