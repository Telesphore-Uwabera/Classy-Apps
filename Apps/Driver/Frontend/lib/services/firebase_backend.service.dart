import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:singleton/singleton.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseBackendService {
  /// Factory method that reuse same instance automatically
  factory FirebaseBackendService() => Singleton.lazy(() => FirebaseBackendService._());

  /// Private constructor
  FirebaseBackendService._() {}

  /// Static instance getter
  static FirebaseBackendService get instance => FirebaseBackendService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isInitialized = false;

  // ========================================
  // INITIALIZATION
  // ========================================

  /// Initialize Firebase backend services
  Future<bool> initializeBackend() async {
    try {
      if (_isInitialized) return true;

      print('Initializing Firebase backend services...');

      // Initialize Firestore
      await _initializeFirestore();

      // Initialize Authentication
      await _initializeAuthentication();

      // Initialize Cloud Messaging
      await _initializeMessaging();

      // Initialize Storage
      await _initializeStorage();

      // Create default collections and documents
      await _createDefaultCollections();

      _isInitialized = true;
      print('Firebase backend services initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing Firebase backend: $e');
      return false;
    }
  }

  /// Initialize Firestore
  Future<void> _initializeFirestore() async {
    try {
      // Enable offline persistence
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Test Firestore connection
      await _firestore.collection('_test').doc('_test').set({
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      });

      print('Firestore initialized successfully');
    } catch (e) {
      print('Error initializing Firestore: $e');
      rethrow;
    }
  }

  /// Initialize Authentication
  Future<void> _initializeAuthentication() async {
    try {
      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          print('User authenticated: ${user.uid}');
        } else {
          print('User signed out');
        }
      });

      print('Authentication initialized successfully');
    } catch (e) {
      print('Error initializing Authentication: $e');
      rethrow;
    }
  }

  /// Initialize Cloud Messaging
  Future<void> _initializeMessaging() async {
    try {
      if (kIsWeb) {
        print('Skipping Cloud Messaging initialization on web');
        return;
      }

      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Cloud Messaging permission granted');
      } else {
        print('Cloud Messaging permission denied');
      }

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _saveFCMToken(token);
      }

      print('Cloud Messaging initialized successfully');
    } catch (e) {
      print('Error initializing Cloud Messaging: $e');
      rethrow;
    }
  }

  /// Initialize Storage
  Future<void> _initializeStorage() async {
    try {
      // Test storage connection
      final ref = _storage.ref().child('_test/_test.txt');
      await ref.putString('test');
      await ref.delete();

      print('Storage initialized successfully');
    } catch (e) {
      print('Error initializing Storage: $e');
      rethrow;
    }
  }

  // ========================================
  // DEFAULT COLLECTIONS SETUP
  // ========================================

  /// Create default collections and documents
  Future<void> _createDefaultCollections() async {
    try {
      // Create app configuration document
      await _createAppConfiguration();

      // Create default categories
      await _createDefaultCategories();

      // Create default order statuses
      await _createDefaultOrderStatuses();

      // Create default service areas
      await _createDefaultServiceAreas();

      print('Default collections created successfully');
    } catch (e) {
      print('Error creating default collections: $e');
    }
  }

  /// Create app configuration
  Future<void> _createAppConfiguration() async {
    try {
      final configRef = _firestore.collection('app_config').doc('driver_app');
      final configDoc = await configRef.get();

      if (!configDoc.exists) {
        await configRef.set({
          'app_name': 'Classy Driver',
          'version': '1.0.0',
          'driver_settings': {
            'max_orders_per_driver': 3,
            'search_radius_km': 10.0,
            'location_update_interval_seconds': 10,
            'auto_accept_orders': false,
            'emergency_contact_required': true,
            'document_verification_required': true,
          },
          'notification_settings': {
            'new_order_sound': true,
            'earnings_notifications': true,
            'emergency_alerts': true,
            'chat_notifications': true,
          },
          'payment_settings': {
            'commission_rate': 0.15,
            'minimum_payout_amount': 50.0,
            'payout_methods': ['bank_transfer', 'mobile_money'],
          },
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error creating app configuration: $e');
    }
  }

  /// Create default categories
  Future<void> _createDefaultCategories() async {
    try {
      final categories = [
        {
          'id': 'food_delivery',
          'name': 'Food Delivery',
          'description': 'Restaurant and food delivery services',
          'icon': 'food',
          'color': '#FF5722',
          'is_active': true,
        },
        {
          'id': 'grocery_delivery',
          'name': 'Grocery Delivery',
          'description': 'Grocery and supermarket delivery',
          'icon': 'shopping_cart',
          'color': '#4CAF50',
          'is_active': true,
        },
        {
          'id': 'pharmacy_delivery',
          'name': 'Pharmacy Delivery',
          'description': 'Medicine and pharmacy delivery',
          'icon': 'local_pharmacy',
          'color': '#2196F3',
          'is_active': true,
        },
        {
          'id': 'parcel_delivery',
          'name': 'Parcel Delivery',
          'description': 'Package and parcel delivery services',
          'icon': 'local_shipping',
          'color': '#9C27B0',
          'is_active': true,
        },
        {
          'id': 'taxi_service',
          'name': 'Taxi Service',
          'description': 'Passenger transportation services',
          'icon': 'local_taxi',
          'color': '#FF9800',
          'is_active': true,
        },
      ];

      final batch = _firestore.batch();
      for (final category in categories) {
        final categoryRef = _firestore.collection('categories').doc(category['id'] as String);
        batch.set(categoryRef, {
          ...category,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error creating default categories: $e');
    }
  }

  /// Create default order statuses
  Future<void> _createDefaultOrderStatuses() async {
    try {
      final statuses = [
        {
          'id': 'pending',
          'name': 'Pending',
          'description': 'Order is pending assignment',
          'color': '#FF9800',
          'is_active': true,
        },
        {
          'id': 'accepted',
          'name': 'Accepted',
          'description': 'Order accepted by driver',
          'color': '#2196F3',
          'is_active': true,
        },
        {
          'id': 'picked_up',
          'name': 'Picked Up',
          'description': 'Order picked up from vendor',
          'color': '#9C27B0',
          'is_active': true,
        },
        {
          'id': 'in_transit',
          'name': 'In Transit',
          'description': 'Order is being delivered',
          'color': '#3F51B5',
          'is_active': true,
        },
        {
          'id': 'delivered',
          'name': 'Delivered',
          'description': 'Order delivered successfully',
          'color': '#4CAF50',
          'is_active': true,
        },
        {
          'id': 'cancelled',
          'name': 'Cancelled',
          'description': 'Order was cancelled',
          'color': '#F44336',
          'is_active': true,
        },
      ];

      final batch = _firestore.batch();
      for (final status in statuses) {
        final statusRef = _firestore.collection('order_statuses').doc(status['id'] as String);
        batch.set(statusRef, {
          ...status,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error creating default order statuses: $e');
    }
  }

  /// Create default service areas
  Future<void> _createDefaultServiceAreas() async {
    try {
      final serviceAreas = [
        {
          'id': 'kampala_central',
          'name': 'Kampala Central',
          'description': 'Central business district of Kampala',
          'coordinates': {
            'center': {'lat': 0.3476, 'lng': 32.5825},
            'radius': 5.0, // 5km radius
          },
          'is_active': true,
        },
        {
          'id': 'kampala_north',
          'name': 'Kampala North',
          'description': 'Northern suburbs of Kampala',
          'coordinates': {
            'center': {'lat': 0.4000, 'lng': 32.6000},
            'radius': 8.0, // 8km radius
          },
          'is_active': true,
        },
        {
          'id': 'kampala_south',
          'name': 'Kampala South',
          'description': 'Southern suburbs of Kampala',
          'coordinates': {
            'center': {'lat': 0.3000, 'lng': 32.5500},
            'radius': 6.0, // 6km radius
          },
          'is_active': true,
        },
      ];

      final batch = _firestore.batch();
      for (final area in serviceAreas) {
        final areaRef = _firestore.collection('service_areas').doc(area['id'] as String);
        batch.set(areaRef, {
          ...area,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error creating default service areas: $e');
    }
  }

  // ========================================
  // FCM TOKEN MANAGEMENT
  // ========================================

  /// Save FCM token to Firestore
  Future<void> _saveFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('fcm_tokens').doc(user.uid).set({
          'token': token,
          'user_id': user.uid,
          'platform': kIsWeb ? 'web' : 'mobile',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Update FCM token
  Future<void> updateFCMToken(String token) async {
    try {
      await _saveFCMToken(token);
      print('FCM token updated successfully');
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // ========================================
  // HEALTH CHECK
  // ========================================

  /// Check Firebase backend health
  Future<Map<String, dynamic>> checkBackendHealth() async {
      final health = <String, dynamic>{
        'firestore': false,
        'auth': false,
        'messaging': false,
        'storage': false,
        'overall': false,
      };

    try {
      // Test Firestore
      await _firestore.collection('_health_check').doc('test').set({
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      health['firestore'] = true;
    } catch (e) {
      print('Firestore health check failed: $e');
    }

    try {
      // Test Auth
      final user = _auth.currentUser;
      health['auth'] = true; // Auth service is working
    } catch (e) {
      print('Auth health check failed: $e');
    }

    try {
      // Test Messaging
      if (!kIsWeb) {
        final token = await _messaging.getToken();
        health['messaging'] = token != null;
      } else {
        health['messaging'] = true; // Skip on web
      }
    } catch (e) {
      print('Messaging health check failed: $e');
    }

    try {
      // Test Storage
      final ref = _storage.ref().child('_health_check/test.txt');
      await ref.putString('test');
      await ref.delete();
      health['storage'] = true;
    } catch (e) {
      print('Storage health check failed: $e');
    }

    // Overall health
    health['overall'] = (health['firestore'] as bool) && (health['auth'] as bool) && (health['messaging'] as bool) && (health['storage'] as bool);

    return health;
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Get app configuration
  Future<Map<String, dynamic>?> getAppConfiguration() async {
    try {
      final doc = await _firestore.collection('app_config').doc('driver_app').get();
      return doc.data();
    } catch (e) {
      print('Error getting app configuration: $e');
      return null;
    }
  }

  /// Update app configuration
  Future<bool> updateAppConfiguration(Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('app_config').doc('driver_app').update({
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating app configuration: $e');
      return false;
    }
  }

  /// Get service status
  bool get isInitialized => _isInitialized;

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Get Auth instance
  FirebaseAuth get auth => _auth;

  /// Get Messaging instance
  FirebaseMessaging get messaging => _messaging;

  /// Get Storage instance
  FirebaseStorage get storage => _storage;
}
