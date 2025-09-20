import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase_data.service.dart';

class FirebaseProductCatalogService {
  static final FirebaseProductCatalogService _instance = FirebaseProductCatalogService._internal();
  factory FirebaseProductCatalogService() => _instance;
  FirebaseProductCatalogService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDataService _firebaseDataService = FirebaseDataService();

  // Stream controllers for real-time catalog updates
  final StreamController<List<Map<String, dynamic>>> _productsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _vendorsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _categoriesController = StreamController<List<Map<String, dynamic>>>.broadcast();

  // Streams for listening to catalog data
  Stream<List<Map<String, dynamic>>> get productsStream => _productsController.stream;
  Stream<List<Map<String, dynamic>>> get vendorsStream => _vendorsController.stream;
  Stream<List<Map<String, dynamic>>> get categoriesStream => _categoriesController.stream;

  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  StreamSubscription<QuerySnapshot>? _vendorsSubscription;
  StreamSubscription<QuerySnapshot>? _categoriesSubscription;

  /// Initialize product catalog service
  void initialize() {
    _startRealTimeUpdates();
  }

  /// Start real-time updates for catalog
  void _startRealTimeUpdates() {
    // Listen to products
    _productsSubscription?.cancel();
    _productsSubscription = _firestore
        .collection('products')
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final products = snapshot.docs.map((doc) => doc.data()).toList();
      _productsController.add(products);
    });

    // Listen to vendors
    _vendorsSubscription?.cancel();
    _vendorsSubscription = _firestore
        .collection('vendors')
        .where('status', isEqualTo: 'active')
        .orderBy('rating', descending: true)
        .snapshots()
        .listen((snapshot) {
      final vendors = snapshot.docs.map((doc) => doc.data()).toList();
      _vendorsController.add(vendors);
    });

    // Listen to categories
    _categoriesSubscription?.cancel();
    _categoriesSubscription = _firestore
        .collection('categories')
        .where('is_active', isEqualTo: true)
        .orderBy('sort_order')
        .snapshots()
        .listen((snapshot) {
      final categories = snapshot.docs.map((doc) => doc.data()).toList();
      _categoriesController.add(categories);
    });
  }

  // ========================================
  // PRODUCTS
  // ========================================

  /// Get all products
  Future<ApiResponse> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? vendorId,
    String? sortBy,
    String? sortOrder,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('status', isEqualTo: 'active');

      // Apply filters
      if (category != null) {
        query = query.where('category_id', isEqualTo: category);
      }
      if (vendorId != null) {
        query = query.where('vendor_id', isEqualTo: vendorId);
      }
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Apply sorting
      if (sortBy != null) {
        bool descending = sortOrder == 'desc';
        query = query.orderBy(sortBy, descending: descending);
      } else {
        query = query.orderBy('created_at', descending: true);
      }

      // Apply pagination
      query = query.limit(limit);

      final snapshot = await query.get();
      final products = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: 'Products fetched successfully',
        body: {'products': products},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch products: $e',
        body: null,
        errors: ['Failed to fetch products: $e'],
      );
    }
  }

  /// Get product by ID
  Future<ApiResponse> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      
      if (!doc.exists) {
        return ApiResponse(code: 404, message: "Product not found");
      }

      return ApiResponse(
        code: 200,
        message: 'Product fetched successfully',
        body: doc.data(),
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch product: $e',
        body: null,
        errors: ['Failed to fetch product: $e'],
      );
    }
  }

  /// Search products
  Future<ApiResponse> searchProducts(String query, {
    String? category,
    String? vendorId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query firestoreQuery = _firestore
          .collection('products')
          .where('status', isEqualTo: 'active');

      // Apply filters
      if (category != null) {
        firestoreQuery = firestoreQuery.where('category_id', isEqualTo: category);
      }
      if (vendorId != null) {
        firestoreQuery = firestoreQuery.where('vendor_id', isEqualTo: vendorId);
      }
      if (minPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where('price', isLessThanOrEqualTo: maxPrice);
      }

      firestoreQuery = firestoreQuery.limit(limit);

      final snapshot = await firestoreQuery.get();
      final allProducts = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Client-side search filtering
      final searchQuery = query.toLowerCase();
      final filteredProducts = allProducts.where((product) {
        if (product == null) return false;
        final name = (product['name'] as String?)?.toLowerCase() ?? '';
        final description = (product['description'] as String?)?.toLowerCase() ?? '';
        final tags = (product['tags'] as List<dynamic>?)?.map((e) => e.toString().toLowerCase()).join(' ') ?? '';
        
        return name.contains(searchQuery) || 
               description.contains(searchQuery) || 
               tags.contains(searchQuery);
      }).toList();

      return ApiResponse(
        code: 200,
        message: 'Search completed successfully',
        body: {'products': filteredProducts},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Search failed: $e',
        body: null,
        errors: ['Search failed: $e'],
      );
    }
  }

  /// Get featured products
  Future<ApiResponse> getFeaturedProducts({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('status', isEqualTo: 'active')
          .where('is_featured', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final products = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: 'Featured products fetched successfully',
        body: {'products': products},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch featured products: $e',
        body: null,
        errors: ['Failed to fetch featured products: $e'],
      );
    }
  }

  /// Get best selling products
  Future<ApiResponse> getBestSellingProducts({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('status', isEqualTo: 'active')
          .orderBy('sales_count', descending: true)
          .limit(limit)
          .get();

      final products = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: 'Best selling products fetched successfully',
        body: {'products': products},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch best selling products: $e',
        body: null,
        errors: ['Failed to fetch best selling products: $e'],
      );
    }
  }

  // ========================================
  // VENDORS
  // ========================================

  /// Get all vendors
  Future<ApiResponse> getVendors({
    int page = 1,
    int limit = 20,
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      Query query = _firestore
          .collection('vendors')
          .where('status', isEqualTo: 'active');

      // Apply category filter
      if (category != null) {
        query = query.where('category_id', isEqualTo: category);
      }

      // Apply location-based filtering if coordinates provided
      if (latitude != null && longitude != null) {
        // For now, we'll get all vendors and filter by distance client-side
        // In a production app, you'd use GeoFirestore or similar for efficient geo-queries
      }

      query = query.orderBy('rating', descending: true).limit(limit);

      final snapshot = await query.get();
      var vendors = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Apply distance filtering if coordinates provided
      if (latitude != null && longitude != null && radius != null) {
        vendors = vendors.where((vendor) {
          if (vendor == null) return false;
          final vendorLat = (vendor['latitude'] as num?)?.toDouble();
          final vendorLng = (vendor['longitude'] as num?)?.toDouble();
          
          if (vendorLat == null || vendorLng == null) return false;
          
          final distance = _calculateDistance(latitude, longitude, vendorLat, vendorLng);
          return distance <= radius;
        }).toList();
      }

      return ApiResponse(
        code: 200,
        message: 'Vendors fetched successfully',
        body: {'vendors': vendors},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch vendors: $e',
        body: null,
        errors: ['Failed to fetch vendors: $e'],
      );
    }
  }

  /// Get vendor by ID
  Future<ApiResponse> getVendorById(String vendorId) async {
    try {
      final doc = await _firestore.collection('vendors').doc(vendorId).get();
      
      if (!doc.exists) {
        return ApiResponse(code: 404, message: "Vendor not found");
      }

      return ApiResponse(
        code: 200,
        message: 'Vendor fetched successfully',
        body: doc.data(),
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch vendor: $e',
        body: null,
        errors: ['Failed to fetch vendor: $e'],
      );
    }
  }

  /// Get vendor menu/products
  Future<ApiResponse> getVendorMenu(String vendorId, {
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('vendor_id', isEqualTo: vendorId)
          .where('status', isEqualTo: 'active');

      if (category != null) {
        query = query.where('category_id', isEqualTo: category);
      }

      query = query.orderBy('created_at', descending: true).limit(limit);

      final snapshot = await query.get();
      final products = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: 'Vendor menu fetched successfully',
        body: {'products': products},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch vendor menu: $e',
        body: null,
        errors: ['Failed to fetch vendor menu: $e'],
      );
    }
  }

  /// Get nearby vendors
  Future<ApiResponse> getNearbyVendors(double latitude, double longitude, {
    double radius = 10.0,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('vendors')
          .where('status', isEqualTo: 'active')
          .limit(100) // Get more vendors to filter by distance
          .get();

      final allVendors = snapshot.docs.map((doc) => doc.data()).toList();
      
      // Filter by distance
      final nearbyVendors = allVendors.where((vendor) {
        final vendorLat = vendor['latitude']?.toDouble();
        final vendorLng = vendor['longitude']?.toDouble();
        
        if (vendorLat == null || vendorLng == null) return false;
        
        final distance = _calculateDistance(latitude, longitude, vendorLat, vendorLng);
        vendor['distance'] = distance;
        return distance <= radius;
      }).toList();

      // Sort by distance
      nearbyVendors.sort((a, b) => (a['distance'] ?? 0.0).compareTo(b['distance'] ?? 0.0));
      
      // Limit results
      final limitedVendors = nearbyVendors.take(limit).toList();

      return ApiResponse(
        code: 200,
        message: 'Nearby vendors fetched successfully',
        body: {'vendors': limitedVendors},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch nearby vendors: $e',
        body: null,
        errors: ['Failed to fetch nearby vendors: $e'],
      );
    }
  }

  // ========================================
  // CATEGORIES
  // ========================================

  /// Get all categories
  Future<ApiResponse> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('is_active', isEqualTo: true)
          .orderBy('sort_order')
          .get();

      final categories = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: 'Categories fetched successfully',
        body: {'categories': categories},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch categories: $e',
        body: null,
        errors: ['Failed to fetch categories: $e'],
      );
    }
  }

  /// Get category by ID
  Future<ApiResponse> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      
      if (!doc.exists) {
        return ApiResponse(code: 404, message: "Category not found");
      }

      return ApiResponse(
        code: 200,
        message: 'Category fetched successfully',
        body: doc.data(),
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch category: $e',
        body: null,
        errors: ['Failed to fetch category: $e'],
      );
    }
  }

  /// Get category products
  Future<ApiResponse> getCategoryProducts(String categoryId, {
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('category_id', isEqualTo: categoryId)
          .where('status', isEqualTo: 'active');

      // Apply sorting
      if (sortBy != null) {
        bool descending = sortOrder == 'desc';
        query = query.orderBy(sortBy, descending: descending);
      } else {
        query = query.orderBy('created_at', descending: true);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final products = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: 'Category products fetched successfully',
        body: {'products': products},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch category products: $e',
        body: null,
        errors: ['Failed to fetch category products: $e'],
      );
    }
  }

  // ========================================
  // REVIEWS & RATINGS
  // ========================================

  /// Get product reviews
  Future<ApiResponse> getProductReviews(String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('product_id', isEqualTo: productId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      final reviews = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: 'Product reviews fetched successfully',
        body: {'reviews': reviews},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch product reviews: $e',
        body: null,
        errors: ['Failed to fetch product reviews: $e'],
      );
    }
  }

  /// Get vendor reviews
  Future<ApiResponse> getVendorReviews(String vendorId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('vendor_id', isEqualTo: vendorId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      final reviews = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: 'Vendor reviews fetched successfully',
        body: {'reviews': reviews},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch vendor reviews: $e',
        body: null,
        errors: ['Failed to fetch vendor reviews: $e'],
      );
    }
  }

  /// Add product review
  Future<ApiResponse> addProductReview(String productId, {
    required double rating,
    String? review,
    List<String>? images,
  }) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final reviewData = {
        'id': '',
        'product_id': productId,
        'customer_id': currentUser!.id.toString(),
        'customer_name': currentUser.name,
        'customer_photo': currentUser.photo,
        'rating': rating,
        'review': review,
        'images': images ?? [],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final reviewRef = _firestore.collection('reviews').doc();
      reviewData['id'] = reviewRef.id;
      await reviewRef.set(reviewData);

      // Update product rating
      await _updateProductRating(productId);

      return ApiResponse(
        code: 200,
        message: 'Review added successfully',
        body: reviewData,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to add review: $e',
        body: null,
        errors: ['Failed to add review: $e'],
      );
    }
  }

  /// Update product rating
  Future<void> _updateProductRating(String productId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('product_id', isEqualTo: productId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      final totalRating = reviewsSnapshot.docs.fold<double>(0, (sum, doc) {
        return sum + (doc.data()['rating'] ?? 0.0);
      });

      final averageRating = totalRating / reviewsSnapshot.docs.length;

      await _firestore.collection('products').doc(productId).update({
        'rating': averageRating,
        'review_count': reviewsSnapshot.docs.length,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating product rating: $e');
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Calculate distance between two points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Listen to products stream
  Stream<List<Map<String, dynamic>>> listenToProducts() {
    return _firestore
        .collection('products')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Listen to vendors stream
  Stream<List<Map<String, dynamic>>> listenToVendors() {
    return _firestore
        .collection('vendors')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Listen to categories stream
  Stream<List<Map<String, dynamic>>> listenToCategories() {
    return _firestore
        .collection('categories')
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Dispose resources
  void dispose() {
    _productsSubscription?.cancel();
    _vendorsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _productsController.close();
    _vendorsController.close();
    _categoriesController.close();
  }
}
