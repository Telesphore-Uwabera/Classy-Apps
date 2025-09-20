import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirestoreInitService {
  static FirestoreInitService? _instance;
  static FirestoreInitService get instance => _instance ??= FirestoreInitService._();
  
  FirestoreInitService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  /// Initialize all Firestore collections with sample data
  Future<void> initializeCollections() async {
    try {
      print('🚀 Initializing Firestore collections...');
      
      // Check if collections already have data
      final hasData = await _checkExistingData();
      
      if (hasData) {
        print('📊 Firestore collections already contain data - skipping initialization');
        return;
      }
      
      // Initialize categories
      await _initializeCategories();
      print('✅ Categories initialized');
      
      // Initialize order statuses
      await _initializeOrderStatuses();
      print('✅ Order statuses initialized');
      
      // Initialize vendor settings
      await _initializeVendorSettings();
      print('✅ Vendor settings initialized');
      
      print('🎉 All Firestore collections initialized successfully!');
    } catch (e) {
      print('❌ Error initializing collections: $e');
    }
  }

  /// Check if collections already contain data
  Future<bool> _checkExistingData() async {
    try {
      final categoriesSnapshot = await _firebaseService.getCollection('categories');
      final orderStatusesSnapshot = await _firebaseService.getCollection('order_statuses');
      final vendorSettingsSnapshot = await _firebaseService.getDocument('vendor_settings', 'global');
      
      return categoriesSnapshot.docs.isNotEmpty || 
             orderStatusesSnapshot.docs.isNotEmpty || 
             vendorSettingsSnapshot.exists;
    } catch (e) {
      print('Error checking existing data: $e');
      // If permission denied, assume collections exist and skip initialization
      if (e.toString().contains('permission-denied')) {
        print('⚠️ Permission denied - skipping Firestore initialization');
        return true;
      }
      return false;
    }
  }

  /// Initialize product categories
  Future<void> _initializeCategories() async {
    final categories = [
      {
        'id': 'cat_food',
        'name': 'Food & Beverages',
        'description': 'Fresh food and drinks',
        'icon': 'restaurant',
        'status': 'active',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cat_groceries',
        'name': 'Groceries',
        'description': 'Daily groceries and household items',
        'icon': 'shopping_cart',
        'status': 'active',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cat_pharmacy',
        'name': 'Pharmacy',
        'description': 'Health and wellness products',
        'icon': 'local_pharmacy',
        'status': 'active',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cat_electronics',
        'name': 'Electronics',
        'description': 'Electronic devices and accessories',
        'icon': 'devices',
        'status': 'active',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cat_clothing',
        'name': 'Clothing & Fashion',
        'description': 'Apparel and fashion accessories',
        'icon': 'checkroom',
        'status': 'active',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cat_home',
        'name': 'Home & Garden',
        'description': 'Home improvement and garden supplies',
        'icon': 'home',
        'status': 'active',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (final category in categories) {
      try {
        await _firebaseService.setDocument('categories', category['id'] as String, category);
      } catch (e) {
        // Category might already exist, continue
        print('Category ${category['id']} might already exist: $e');
      }
    }
  }

  /// Initialize order statuses and their configurations
  Future<void> _initializeOrderStatuses() async {
    final orderStatuses = [
      {
        'id': 'pending',
        'name': 'Pending',
        'description': 'Order received, waiting for confirmation',
        'color': '#FF9800',
        'icon': 'pending',
        'isActive': true,
        'sortOrder': 1,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'confirmed',
        'name': 'Confirmed',
        'description': 'Order confirmed by vendor',
        'color': '#2196F3',
        'icon': 'check_circle',
        'isActive': true,
        'sortOrder': 2,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'preparing',
        'name': 'Preparing',
        'description': 'Order is being prepared',
        'color': '#9C27B0',
        'icon': 'restaurant',
        'isActive': true,
        'sortOrder': 3,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'ready',
        'name': 'Ready',
        'description': 'Order is ready for pickup/delivery',
        'color': '#4CAF50',
        'icon': 'done',
        'isActive': true,
        'sortOrder': 4,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'delivering',
        'name': 'Delivering',
        'description': 'Order is out for delivery',
        'color': '#00BCD4',
        'icon': 'local_shipping',
        'isActive': true,
        'sortOrder': 5,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'completed',
        'name': 'Completed',
        'description': 'Order has been delivered successfully',
        'color': '#4CAF50',
        'icon': 'check_circle',
        'isActive': true,
        'sortOrder': 6,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cancelled',
        'name': 'Cancelled',
        'description': 'Order has been cancelled',
        'color': '#F44336',
        'icon': 'cancel',
        'isActive': true,
        'sortOrder': 7,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (final status in orderStatuses) {
      try {
        await _firebaseService.setDocument('order_statuses', status['id'] as String, status);
      } catch (e) {
        print('Order status ${status['id']} might already exist: $e');
      }
    }
  }

  /// Initialize vendor settings and configurations
  Future<void> _initializeVendorSettings() async {
    final vendorSettings = {
      'id': 'vendor_settings',
      'appVersion': '1.0.0',
      'minOrderAmount': 10.0,
      'deliveryFee': 2.99,
      'serviceFee': 0.15,
      'taxRate': 0.08,
      'currency': 'USD',
      'currencySymbol': '\$',
      'businessHours': {
        'monday': {'open': '09:00', 'close': '21:00', 'isOpen': true},
        'tuesday': {'open': '09:00', 'close': '21:00', 'isOpen': true},
        'wednesday': {'open': '09:00', 'close': '21:00', 'isOpen': true},
        'thursday': {'open': '09:00', 'close': '21:00', 'isOpen': true},
        'friday': {'open': '09:00', 'close': '22:00', 'isOpen': true},
        'saturday': {'open': '10:00', 'close': '22:00', 'isOpen': true},
        'sunday': {'open': '10:00', 'close': '20:00', 'isOpen': true},
      },
      'deliveryZones': [],
      'paymentMethods': ['cash', 'card', 'digital_wallet'],
      'notificationSettings': {
        'newOrder': true,
        'orderUpdate': true,
        'lowStock': true,
        'dailyReport': true,
      },
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      await _firebaseService.setDocument('vendor_settings', 'global', vendorSettings);
    } catch (e) {
      print('Vendor settings might already exist: $e');
    }
  }

  /// Initialize sample data for a specific vendor
  Future<void> initializeVendorData(String vendorId) async {
    try {
      print('🏪 Initializing data for vendor: $vendorId');
      
      // Initialize vendor profile
      await _initializeVendorProfile(vendorId);
      
      // Initialize sample products
      await _initializeSampleProducts(vendorId);
      
      // Initialize sample orders
      await _initializeSampleOrders(vendorId);
      
      print('✅ Vendor data initialized successfully!');
    } catch (e) {
      print('❌ Error initializing vendor data: $e');
    }
  }

  /// Initialize vendor profile
  Future<void> _initializeVendorProfile(String vendorId) async {
    final vendorProfile = {
      'id': vendorId,
      'businessName': 'Sample Vendor Store',
      'businessType': 'restaurant',
      'description': 'A sample vendor store for testing',
      'phone': '+1234567890',
      'email': 'vendor@example.com',
      'address': {
        'street': '123 Main Street',
        'city': 'Sample City',
        'state': 'Sample State',
        'zipCode': '12345',
        'country': 'United States',
        'latitude': 40.7128,
        'longitude': -74.0060,
      },
      'businessHours': {
        'monday': {'open': '09:00', 'close': '21:00', 'isOpen': true},
        'tuesday': {'open': '09:00', 'close': '21:00', 'isOpen': true},
        'wednesday': {'open': '09:00', 'close': '21:00', 'isOpen': true},
        'thursday': {'open': '09:00', 'close': '21:00', 'isOpen': true},
        'friday': {'open': '09:00', 'close': '22:00', 'isOpen': true},
        'saturday': {'open': '10:00', 'close': '22:00', 'isOpen': true},
        'sunday': {'open': '10:00', 'close': '20:00', 'isOpen': true},
      },
      'isActive': true,
      'rating': 4.5,
      'totalOrders': 0,
      'totalRevenue': 0.0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      await _firebaseService.setDocument('vendors', vendorId, vendorProfile);
    } catch (e) {
      print('Vendor profile might already exist: $e');
    }
  }

  /// Initialize sample products for vendor
  Future<void> _initializeSampleProducts(String vendorId) async {
    final sampleProducts = [
      {
        'id': 'prod_1',
        'vendorId': vendorId,
        'name': 'Sample Product 1',
        'description': 'This is a sample product for testing',
        'price': 9.99,
        'categoryId': 'cat_food',
        'stock': 50,
        'status': 'active',
        'images': [],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'prod_2',
        'vendorId': vendorId,
        'name': 'Sample Product 2',
        'description': 'Another sample product for testing',
        'price': 15.99,
        'categoryId': 'cat_groceries',
        'stock': 30,
        'status': 'active',
        'images': [],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (final product in sampleProducts) {
      try {
        await _firebaseService.setDocument('products', product['id'] as String, product);
      } catch (e) {
        print('Sample product ${product['id']} might already exist: $e');
      }
    }
  }

  /// Initialize sample orders for vendor
  Future<void> _initializeSampleOrders(String vendorId) async {
    final sampleOrders = [
      {
        'id': 'order_1',
        'vendorId': vendorId,
        'customerId': 'customer_1',
        'customerName': 'John Doe',
        'customerEmail': 'john@example.com',
        'customerPhone': '+1234567890',
        'status': 'pending',
        'totalAmount': 25.98,
        'items': [
          {
            'productId': 'prod_1',
            'name': 'Sample Product 1',
            'price': 9.99,
            'quantity': 2,
            'total': 19.98,
          },
          {
            'productId': 'prod_2',
            'name': 'Sample Product 2',
            'price': 15.99,
            'quantity': 1,
            'total': 15.99,
          },
        ],
        'deliveryAddress': {
          'street': '456 Customer Street',
          'city': 'Customer City',
          'state': 'Customer State',
          'zipCode': '54321',
          'country': 'United States',
        },
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
        'updatedAt': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
      },
    ];

    for (final order in sampleOrders) {
      try {
        await _firebaseService.setDocument('orders', order['id'] as String, order);
      } catch (e) {
        print('Sample order ${order['id']} might already exist: $e');
      }
    }
  }

  /// Check if collections are initialized
  Future<bool> areCollectionsInitialized() async {
    try {
      final categoriesSnapshot = await _firebaseService.getCollection('categories');
      final orderStatusesSnapshot = await _firebaseService.getCollection('order_statuses');
      final vendorSettingsSnapshot = await _firebaseService.getDocument('vendor_settings', 'global');
      
      return categoriesSnapshot.docs.isNotEmpty && 
             orderStatusesSnapshot.docs.isNotEmpty && 
             vendorSettingsSnapshot.exists;
    } catch (e) {
      print('Error checking collections: $e');
      return false;
    }
  }
}
