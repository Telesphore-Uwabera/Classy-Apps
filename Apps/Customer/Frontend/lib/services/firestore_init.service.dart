import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreInitService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize essential collections and documents
  static Future<void> initializeCollections() async {
    try {
      print('🚀 Initializing Firestore collections...');

      // Test Firestore connectivity first
      await _testFirestoreConnectivity();

      // 1. Initialize app settings
      await _initializeAppSettings();

      // 2. Initialize categories
      await _initializeCategories();

      // 3. Initialize sample data
      await _initializeSampleData();

      print('✅ Firestore collections initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firestore collections: $e');
      // Don't rethrow the error to prevent app crashes
    }
  }

  /// Test Firestore connectivity
  static Future<void> _testFirestoreConnectivity() async {
    try {
      // Try a simple read operation to test connectivity
      await _firestore.collection('_test').limit(1).get();
      print('✅ Firestore connectivity test passed');
    } catch (e) {
      print('⚠️ Firestore connectivity test failed: $e');
      // If connectivity fails, we'll skip initialization
      throw Exception('Firestore connectivity failed: $e');
    }
  }

  /// Initialize app settings
  static Future<void> _initializeAppSettings() async {
    try {
      final docRef = _firestore.collection('app_settings').doc('general');
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'app_name': 'Classy',
          'app_version': '1.0.0',
          'maintenance_mode': false,
          'currency': 'USD',
          'currency_symbol': '\$',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        print('✅ App settings created');
      } else {
        print('ℹ️ App settings already exist');
      }
    } catch (e) {
      print('❌ Error creating app settings: $e');
    }
  }

  /// Initialize categories
  static Future<void> _initializeCategories() async {
    try {
      final categories = [
        {
          'id': 'food',
          'name': 'Food & Groceries',
          'description': 'Fresh food and grocery items',
          'image': 'https://via.placeholder.com/300x200?text=Food',
          'is_active': true,
          'sort_order': 1,
        },
        {
          'id': 'pharmacy',
          'name': 'Pharmacy',
          'description': 'Medicines and health products',
          'image': 'https://via.placeholder.com/300x200?text=Pharmacy',
          'is_active': true,
          'sort_order': 2,
        },
        {
          'id': 'parcel',
          'name': 'Parcel Delivery',
          'description': 'Package delivery services',
          'image': 'https://via.placeholder.com/300x200?text=Parcel',
          'is_active': true,
          'sort_order': 3,
        },
      ];

      for (final category in categories) {
        final docRef = _firestore.collection('categories').doc(category['id'] as String);
        final doc = await docRef.get();

        if (!doc.exists) {
          await docRef.set({
            ...category,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
      print('✅ Categories initialized');
    } catch (e) {
      print('❌ Error creating categories: $e');
    }
  }

  /// Initialize sample data
  static Future<void> _initializeSampleData() async {
    try {
      // Create sample restaurant
      final restaurantRef = _firestore.collection('restaurants').doc('sample_restaurant');
      final restaurantDoc = await restaurantRef.get();

      if (!restaurantDoc.exists) {
        await restaurantRef.set({
          'name': 'Sample Restaurant',
          'description': 'A sample restaurant for testing',
          'address': '123 Main St, City',
          'phone': '+1234567890',
          'email': 'info@samplerestaurant.com',
          'rating': 4.5,
          'delivery_fee': 2.99,
          'minimum_order': 15.00,
          'is_active': true,
          'category_id': 'food',
          'location': {
            'latitude': 40.7128,
            'longitude': -74.0060,
          },
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        print('✅ Sample restaurant created');
      }

      // Create sample driver
      final driverRef = _firestore.collection('drivers').doc('sample_driver');
      final driverDoc = await driverRef.get();

      if (!driverDoc.exists) {
        await driverRef.set({
          'name': 'Sample Driver',
          'email': 'driver@example.com',
          'phone': '+1234567891',
          'vehicle_type': 'motorcycle',
          'vehicle_number': 'ABC123',
          'is_active': true,
          'is_online': false,
          'rating': 4.8,
          'location': {
            'latitude': 40.7505,
            'longitude': -73.9934,
          },
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        print('✅ Sample driver created');
      }
    } catch (e) {
      print('❌ Error creating sample data: $e');
    }
  }

  /// Get all collections (for debugging - limited functionality)
  static Future<List<String>> getAvailableCollections() async {
    // Note: Firestore doesn't allow listing collections from client
    // This is a workaround by checking known collections
    final knownCollections = [
      'app_settings',
      'categories',
      'restaurants',
      'drivers',
      'vendors',
      'users',
      'orders',
    ];

    final existingCollections = <String>[];

    for (final collectionName in knownCollections) {
      try {
        final snapshot = await _firestore.collection(collectionName).limit(1).get();
        if (snapshot.docs.isNotEmpty) {
          existingCollections.add(collectionName);
        }
      } catch (e) {
        // Collection might not exist or have permission issues
        print('⚠️ Could not access collection $collectionName: $e');
      }
    }

    return existingCollections;
  }

  /// Check if a collection exists
  static Future<bool> collectionExists(String collectionName) async {
    try {
      final snapshot = await _firestore.collection(collectionName).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get collection document count
  static Future<int> getCollectionCount(String collectionName) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting count for $collectionName: $e');
      return 0;
    }
  }
}
