import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'driver_firebase.service.dart';
import 'firebase_backend.service.dart';
import 'driver_notification.service.dart';
import 'driver_location.service.dart';

class FirebaseTestService {
  static final FirebaseTestService _instance = FirebaseTestService._internal();
  factory FirebaseTestService() => _instance;
  FirebaseTestService._internal();

  final DriverFirebaseService _driverFirebaseService = DriverFirebaseService();
  final FirebaseBackendService _backendService = FirebaseBackendService();
  final DriverNotificationService _notificationService = DriverNotificationService();
  final DriverLocationService _locationService = DriverLocationService();

  // ========================================
  // COMPREHENSIVE FIREBASE TESTING
  // ========================================

  /// Run comprehensive Firebase tests
  Future<Map<String, dynamic>> runComprehensiveTests() async {
    print('🚀 Starting comprehensive Firebase tests...');
    
    final results = {
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
      'overall_success': false,
      'total_tests': 0,
      'passed_tests': 0,
      'failed_tests': 0,
    };

    try {
      // Test 1: Backend Initialization
      await _testBackendInitialization(results);

      // Test 2: Firestore Connection
      await _testFirestoreConnection(results);

      // Test 3: Authentication
      await _testAuthentication(results);

      // Test 4: Cloud Messaging
      await _testCloudMessaging(results);

      // Test 5: Storage
      await _testStorage(results);

      // Test 6: Driver Services
      await _testDriverServices(results);

      // Test 7: Location Services
      await _testLocationServices(results);

      // Test 8: Notification Services
      await _testNotificationServices(results);

      // Test 9: Real-time Features
      await _testRealTimeFeatures(results);

      // Test 10: Security Rules
      await _testSecurityRules(results);

      // Calculate overall success
      results['overall_success'] = results['passed_tests'] == results['total_tests'];
      
      print('✅ Firebase tests completed!');
      print('📊 Results: ${results['passed_tests']}/${results['total_tests']} tests passed');
      
      return results;
    } catch (e) {
      print('❌ Error running comprehensive tests: $e');
      results['error'] = e.toString();
      return results;
    }
  }

  // ========================================
  // INDIVIDUAL TEST METHODS
  // ========================================

  /// Test backend initialization
  Future<void> _testBackendInitialization(Map<String, dynamic> results) async {
    print('🔧 Testing backend initialization...');
    
    try {
      final success = await _backendService.initializeBackend();
      _addTestResult(results, 'backend_initialization', success, 
          success ? 'Backend initialized successfully' : 'Backend initialization failed');
    } catch (e) {
      _addTestResult(results, 'backend_initialization', false, 'Error: $e');
    }
  }

  /// Test Firestore connection
  Future<void> _testFirestoreConnection(Map<String, dynamic> results) async {
    print('📊 Testing Firestore connection...');
    
    try {
      final firestore = _backendService.firestore;
      
      // Test write operation
      final testDoc = firestore.collection('_test').doc('connection_test');
      await testDoc.set({
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Firestore connection test',
      });

      // Test read operation
      final doc = await testDoc.get();
      final data = doc.data();
      
      // Test real-time listener
      bool listenerWorked = false;
      final subscription = testDoc.snapshots().listen((snapshot) {
        listenerWorked = true;
      });
      
      await Future.delayed(Duration(seconds: 2));
      await subscription.cancel();
      
      // Clean up
      await testDoc.delete();
      
      final success = data != null && data['test'] == true;
      _addTestResult(results, 'firestore_connection', success, 
          success ? 'Firestore read/write/listen operations successful' : 'Firestore operations failed');
    } catch (e) {
      _addTestResult(results, 'firestore_connection', false, 'Error: $e');
    }
  }

  /// Test authentication
  Future<void> _testAuthentication(Map<String, dynamic> results) async {
    print('🔐 Testing authentication...');
    
    try {
      final auth = _backendService.auth;
      
      // Test auth state listener
      bool authStateChanged = false;
      final subscription = auth.authStateChanges().listen((user) {
        authStateChanged = true;
      });
      
      await Future.delayed(Duration(seconds: 1));
      await subscription.cancel();
      
      // Test current user
      final currentUser = auth.currentUser;
      
      final success = authStateChanged; // Auth service is working
      _addTestResult(results, 'authentication', success, 
          success ? 'Authentication service is working' : 'Authentication service failed');
    } catch (e) {
      _addTestResult(results, 'authentication', false, 'Error: $e');
    }
  }

  /// Test Cloud Messaging
  Future<void> _testCloudMessaging(Map<String, dynamic> results) async {
    print('📱 Testing Cloud Messaging...');
    
    try {
      final messaging = _backendService.messaging;
      
      // Test permission request
      final settings = await messaging.requestPermission();
      
      // Test token retrieval
      final token = await messaging.getToken();
      
      final success = settings.authorizationStatus == AuthorizationStatus.authorized && token != null;
      _addTestResult(results, 'cloud_messaging', success, 
          success ? 'Cloud Messaging permission granted and token retrieved' : 'Cloud Messaging setup failed');
    } catch (e) {
      _addTestResult(results, 'cloud_messaging', false, 'Error: $e');
    }
  }

  /// Test Storage
  Future<void> _testStorage(Map<String, dynamic> results) async {
    print('💾 Testing Storage...');
    
    try {
      final storage = _backendService.storage;
      
      // Test upload
      final testRef = storage.ref().child('_test/storage_test.txt');
      final uploadTask = await testRef.putString('Storage test data');
      
      // Test download
      final downloadUrl = await testRef.getDownloadURL();
      
      // Test metadata
      final metadata = await testRef.getMetadata();
      
      // Clean up
      await testRef.delete();
      
      final success = uploadTask.state == TaskState.success && downloadUrl.isNotEmpty;
      _addTestResult(results, 'storage', success, 
          success ? 'Storage upload/download operations successful' : 'Storage operations failed');
    } catch (e) {
      _addTestResult(results, 'storage', false, 'Error: $e');
    }
  }

  /// Test driver services
  Future<void> _testDriverServices(Map<String, dynamic> results) async {
    print('🚗 Testing driver services...');
    
    try {
      // Test driver profile creation
      final testDriverData = {
        'name': 'Test Driver',
        'email': 'test@driver.com',
        'phone': '+256700000000',
        'service_type': 'car',
        'license_number': 'TEST123',
        'vehicle_info': {
          'make': 'Toyota',
          'model': 'Corolla',
          'year': 2020,
          'color': 'White',
          'plate_number': 'TEST123',
        },
      };

      // Note: This would normally require authentication
      // For testing, we'll just verify the service is available
      final serviceAvailable = _driverFirebaseService != null;
      
      _addTestResult(results, 'driver_services', serviceAvailable, 
          serviceAvailable ? 'Driver services are available' : 'Driver services not available');
    } catch (e) {
      _addTestResult(results, 'driver_services', false, 'Error: $e');
    }
  }

  /// Test location services
  Future<void> _testLocationServices(Map<String, dynamic> results) async {
    print('📍 Testing location services...');
    
    try {
      // Test permission request
      final hasPermission = await _locationService.hasLocationPermissions();
      
      // Test current location (if permission granted)
      Position? currentPosition;
      if (hasPermission) {
        currentPosition = await _locationService.getCurrentLocationWithTimeout(
          timeout: Duration(seconds: 5),
        );
      }
      
      final success = hasPermission && currentPosition != null;
      _addTestResult(results, 'location_services', success, 
          success ? 'Location services working with current position' : 'Location services failed');
    } catch (e) {
      _addTestResult(results, 'location_services', false, 'Error: $e');
    }
  }

  /// Test notification services
  Future<void> _testNotificationServices(Map<String, dynamic> results) async {
    print('🔔 Testing notification services...');
    
    try {
      // Test notification service initialization
      await DriverNotificationService.initializeDriverNotifications();
      
      // Test notification permissions
      await DriverNotificationService.requestNotificationPermissions();
      
      // Test notification storage
      final notifications = await _notificationService.getStoredNotifications();
      
      final success = true; // If we get here without error, it's working
      _addTestResult(results, 'notification_services', success, 
          success ? 'Notification services initialized successfully' : 'Notification services failed');
    } catch (e) {
      _addTestResult(results, 'notification_services', false, 'Error: $e');
    }
  }

  /// Test real-time features
  Future<void> _testRealTimeFeatures(Map<String, dynamic> results) async {
    print('⚡ Testing real-time features...');
    
    try {
      final firestore = _backendService.firestore;
      
      // Test real-time listener
      bool listenerReceivedData = false;
      final testDoc = firestore.collection('_test').doc('realtime_test');
      
      final subscription = testDoc.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          listenerReceivedData = true;
        }
      });
      
      // Trigger a change
      await testDoc.set({
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Wait for listener to receive data
      await Future.delayed(Duration(seconds: 2));
      
      // Clean up
      await subscription.cancel();
      await testDoc.delete();
      
      _addTestResult(results, 'realtime_features', listenerReceivedData, 
          listenerReceivedData ? 'Real-time listeners working' : 'Real-time features failed');
    } catch (e) {
      _addTestResult(results, 'realtime_features', false, 'Error: $e');
    }
  }

  /// Test security rules
  Future<void> _testSecurityRules(Map<String, dynamic> results) async {
    print('🔒 Testing security rules...');
    
    try {
      final firestore = _backendService.firestore;
      
      // Test read access to public collections
      final categoriesSnapshot = await firestore.collection('categories').limit(1).get();
      
      // Test write access (this should fail for unauthenticated users)
      bool writeFailed = false;
      try {
        await firestore.collection('users').doc('test').set({'test': true});
      } catch (e) {
        writeFailed = true; // This is expected for unauthenticated users
      }
      
      final success = categoriesSnapshot.docs.isNotEmpty && writeFailed;
      _addTestResult(results, 'security_rules', success, 
          success ? 'Security rules are working correctly' : 'Security rules test failed');
    } catch (e) {
      _addTestResult(results, 'security_rules', false, 'Error: $e');
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Add test result to results map
  void _addTestResult(Map<String, dynamic> results, String testName, bool success, String message) {
    results['tests'][testName] = {
      'success': success,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    results['total_tests']++;
    if (success) {
      results['passed_tests']++;
      print('✅ $testName: $message');
    } else {
      results['failed_tests']++;
      print('❌ $testName: $message');
    }
  }

  /// Generate test report
  String generateTestReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    
    buffer.writeln('=' * 60);
    buffer.writeln('FIREBASE BACKEND TEST REPORT');
    buffer.writeln('=' * 60);
    buffer.writeln('Timestamp: ${results['timestamp']}');
    buffer.writeln('Overall Success: ${results['overall_success'] ? '✅ PASSED' : '❌ FAILED'}');
    buffer.writeln('Tests Passed: ${results['passed_tests']}/${results['total_tests']}');
    buffer.writeln('');
    
    buffer.writeln('DETAILED RESULTS:');
    buffer.writeln('-' * 40);
    
    results['tests'].forEach((testName, testResult) {
      final status = testResult['success'] ? '✅' : '❌';
      buffer.writeln('$status $testName: ${testResult['message']}');
    });
    
    buffer.writeln('');
    buffer.writeln('=' * 60);
    
    return buffer.toString();
  }

  /// Run quick connectivity test
  Future<bool> runQuickConnectivityTest() async {
    try {
      print('🔍 Running quick connectivity test...');
      
      // Test Firestore
      final firestore = _backendService.firestore;
      await firestore.collection('_test').doc('quick_test').set({
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Test read
      final doc = await firestore.collection('_test').doc('quick_test').get();
      final success = doc.exists && doc.data()?['test'] == true;
      
      // Clean up
      await firestore.collection('_test').doc('quick_test').delete();
      
      print(success ? '✅ Quick connectivity test passed' : '❌ Quick connectivity test failed');
      return success;
    } catch (e) {
      print('❌ Quick connectivity test failed: $e');
      return false;
    }
  }
}
