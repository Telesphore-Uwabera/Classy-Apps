import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
// import 'models/app_notification.dart'; // Commented out - model doesn't exist
import 'models/user.dart';
import 'services/firebase.service.dart';

class FirebaseDataService {
  static final FirebaseDataService _instance = FirebaseDataService._internal();
  factory FirebaseDataService() => _instance;
  FirebaseDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  // ========================================
  // USER MANAGEMENT
  // ========================================

  /// Create or update user in Firestore
  Future<User> createOrUpdateUser(Map<String, dynamic> userData) async {
    try {
      final userId = userData['id'] ?? _auth.currentUser?.uid;
      if (userId == null) throw Exception('User ID not found');

      final userRef = _firestore.collection('users').doc(userId);
      await userRef.set(userData, SetOptions(merge: true));

      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await getUserById(user.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // ========================================
  // NOTIFICATIONS
  // ========================================

  /// Create notification - DISABLED (AppNotification model not available)
  /* Future<AppNotification> createNotification(Map<String, dynamic> notificationData) async {
    try {
      final notificationRef = _firestore.collection('notifications').doc();
      final notification = AppNotification(
        id: notificationRef.id,
        userId: notificationData['user_id'],
        userType: notificationData['user_type'],
        title: notificationData['title'],
        message: notificationData['message'],
        type: notificationData['type'],
        data: notificationData['data'] ?? {},
        isRead: false,
        createdAt: DateTime.now(),
      );

      await notificationRef.set(notification.toJson());
      return notification;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  } */

  /// Get user notifications - DISABLED (AppNotification model not available)
  /* Stream<List<AppNotification>> getUserNotificationsStream(String userId, {int limit = 50}) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson(doc.data()))
            .toList());
  } */

  /// Mark notification as read - DISABLED (AppNotification model not available)
  /* Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  } */

  /// Get unread notification count - DISABLED (AppNotification model not available)
  /* Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  } */

  // ========================================
  // ORDERS
  // ========================================

  /// Create order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final orderRef = _firestore.collection('orders').doc();
      final order = {
        'id': orderRef.id,
        'order_number': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...orderData,
      };

      await orderRef.set(order);
      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get user orders
  Stream<List<Map<String, dynamic>>> getUserOrdersStream(String userId, String userType, {int limit = 50}) {
    final field = userType == 'customer' ? 'customer_id' : 'vendor_id';
    
    return _firestore
        .collection('orders')
        .where(field, isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status, {Map<String, dynamic>? additionalData}) async {
    try {
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      await _firestore.collection('orders').doc(orderId).update(updates);
      return true;
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Get order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // ========================================
  // SERVICES
  // ========================================

  /// Create service
  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    try {
      final serviceRef = _firestore.collection('services').doc();
      final service = {
        'id': serviceRef.id,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...serviceData,
      };

      await serviceRef.set(service);
      return service;
    } catch (e) {
      throw Exception('Failed to create service: $e');
    }
  }

  /// Get vendor services
  Stream<List<Map<String, dynamic>>> getVendorServicesStream(String vendorId, {int limit = 50}) {
    return _firestore
        .collection('services')
        .where('vendor_id', isEqualTo: vendorId)
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Search services
  Future<List<Map<String, dynamic>>> searchServices(String query, {String? category, int limit = 20}) async {
    try {
      Query queryRef = _firestore.collection('services').where('status', isEqualTo: 'active');
      
      if (category != null) {
        queryRef = queryRef.where('category', isEqualTo: category);
      }

      final snapshot = await queryRef.limit(limit).get();
      final services = snapshot.docs.map((doc) => doc.data()).toList();

      // Filter by search query (client-side filtering for now)
      if (query.isNotEmpty) {
        return services.where((service) {
          final name = service['name']?.toString().toLowerCase() ?? '';
          final description = service['description']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || description.contains(searchQuery);
        }).toList();
      }

      return services;
    } catch (e) {
      throw Exception('Failed to search services: $e');
    }
  }

  // ========================================
  // DRIVER LOCATIONS
  // ========================================

  /// Update driver location
  Future<bool> updateDriverLocation(String driverId, Map<String, dynamic> locationData) async {
    try {
      locationData['updated_at'] = DateTime.now().toIso8601String();
      await _firestore.collection('driver_locations').doc(driverId).set(locationData, SetOptions(merge: true));
      return true;
    } catch (e) {
      throw Exception('Failed to update driver location: $e');
    }
  }

  /// Get nearby drivers
  Future<List<Map<String, dynamic>>> getNearbyDrivers(double latitude, double longitude, {double radius = 10, int limit = 20}) async {
    try {
      // Get all active drivers
      final snapshot = await _firestore
          .collection('driver_locations')
          .where('status', isEqualTo: 'available')
          .limit(limit)
          .get();

      final drivers = snapshot.docs.map((doc) => doc.data()).toList();
      final nearbyDrivers = <Map<String, dynamic>>[];

      for (final driver in drivers) {
        if (driver['latitude'] != null && driver['longitude'] != null) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            driver['latitude'].toDouble(),
            driver['longitude'].toDouble(),
          );

          if (distance <= radius) {
            driver['distance'] = distance;
            nearbyDrivers.add(driver);
          }
        }
      }

      // Sort by distance
      nearbyDrivers.sort((a, b) => (a['distance'] ?? 0).compareTo(b['distance'] ?? 0));
      return nearbyDrivers.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get nearby drivers: $e');
    }
  }

  /// Calculate distance between two points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        (math.sin(lat1) * math.sin(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2));
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // ========================================
  // PAYMENTS
  // ========================================

  /// Create payment
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final paymentRef = _firestore.collection('payments').doc();
      final payment = {
        'id': paymentRef.id,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...paymentData,
      };

      await paymentRef.set(payment);
      return payment;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String status, {String? transactionId}) async {
    try {
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (transactionId != null) {
        updates['transaction_id'] = transactionId;
      }

      await _firestore.collection('payments').doc(paymentId).update(updates);
      return true;
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Get payment by ID
  Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  // ========================================
  // RATINGS & REVIEWS
  // ========================================

  /// Create rating
  Future<Map<String, dynamic>> createRating(Map<String, dynamic> ratingData) async {
    try {
      final ratingRef = _firestore.collection('ratings').doc();
      final rating = {
        'id': ratingRef.id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...ratingData,
      };

      await ratingRef.set(rating);
      return rating;
    } catch (e) {
      throw Exception('Failed to create rating: $e');
    }
  }

  /// Get user ratings
  Stream<List<Map<String, dynamic>>> getUserRatingsStream(String userId, String userType, {int limit = 50}) {
    final field = userType == 'customer' ? 'customer_id' : 'vendor_id';
    
    return _firestore
        .collection('ratings')
        .where(field, isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Get average rating for user
  Future<double> getUserAverageRating(String userId, String userType) async {
    try {
      final field = userType == 'customer' ? 'customer_id' : 'vendor_id';
      
      final snapshot = await _firestore
          .collection('ratings')
          .where(field, isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final totalRating = snapshot.docs.fold<double>(0, (sum, doc) {
        final rating = doc.data()['rating'] ?? 0;
        return sum + (rating is int ? rating.toDouble() : rating);
      });

      return totalRating / snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get average rating: $e');
    }
  }

  // ========================================
  // CHAT & MESSAGES
  // ========================================

  /// Create message
  Future<Map<String, dynamic>> createMessage(Map<String, dynamic> messageData) async {
    try {
      final messageRef = _firestore.collection('messages').doc();
      final message = {
        'id': messageRef.id,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        ...messageData,
      };

      await messageRef.set(message);
      return message;
    } catch (e) {
      throw Exception('Failed to create message: $e');
    }
  }

  /// Get chat messages
  Stream<List<Map<String, dynamic>>> getChatMessagesStream(String chatId, {int limit = 100}) {
    return _firestore
        .collection('messages')
        .where('chat_id', isEqualTo: chatId)
        .orderBy('created_at', ascending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // ========================================
  // FAVORITES
  // ========================================

  /// Add to favorites
  Future<bool> addToFavorites(String userId, String itemType, String itemId) async {
    try {
      final favoriteRef = _firestore.collection('favorites').doc();
      await favoriteRef.set({
        'id': favoriteRef.id,
        'user_id': userId,
        'item_type': itemType,
        'item_id': itemId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  /// Remove from favorites
  Future<bool> removeFromFavorites(String userId, String itemType, String itemId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: userId)
          .where('item_type', isEqualTo: itemType)
          .where('item_id', isEqualTo: itemId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  /// Get user favorites
  Stream<List<Map<String, dynamic>>> getUserFavoritesStream(String userId, {int limit = 50}) {
    return _firestore
        .collection('favorites')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Check if item is favorited
  Future<bool> isItemFavorited(String userId, String itemType, String itemId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: userId)
          .where('item_type', isEqualTo: itemType)
          .where('item_id', isEqualTo: itemId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Get collection statistics
  Future<Map<String, dynamic>> getCollectionStats(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      final docs = snapshot.docs;
      
      if (docs.isEmpty) {
        return {
          'total_count': 0,
          'last_updated': 'N/A',
        };
      }

      // Get the most recent document
      final sortedDocs = docs.toList()
        ..sort((a, b) {
          final aTime = a.data()['updated_at'] ?? a.data()['created_at'] ?? '';
          final bTime = b.data()['updated_at'] ?? b.data()['created_at'] ?? '';
          return bTime.compareTo(aTime);
        });

      return {
        'total_count': docs.length,
        'last_updated': sortedDocs.first.data()['updated_at'] ?? sortedDocs.first.data()['created_at'] ?? 'N/A',
      };
    } catch (e) {
      throw Exception('Failed to get collection stats: $e');
    }
  }

  /// Batch write operations
  Future<bool> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final type = operation['type'];
        final collection = operation['collection'];
        final docId = operation['doc_id'];
        final data = operation['data'];

        switch (type) {
          case 'set':
            batch.set(_firestore.collection(collection).doc(docId), data);
            break;
          case 'update':
            batch.update(_firestore.collection(collection).doc(docId), data);
            break;
          case 'delete':
            batch.delete(_firestore.collection(collection).doc(docId));
            break;
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      throw Exception('Failed to perform batch write: $e');
    }
  }

  /// Listen to real-time updates
  Stream<Map<String, dynamic>> listenToDocument(String collection, String docId) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  /// Listen to collection changes
  Stream<List<Map<String, dynamic>>> listenToCollection(String collection, {List<List<dynamic>>? where, String? orderBy, bool descending = false, int? limit}) {
    Query query = _firestore.collection(collection);
    
    if (where != null) {
      for (final condition in where) {
        if (condition.length == 3) {
          query = query.where(condition[0], isEqualTo: condition[1]);
        }
      }
    }
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots().map((snapshot) => 
        snapshot.docs.map((doc) => doc.data()).toList());
  }
}
