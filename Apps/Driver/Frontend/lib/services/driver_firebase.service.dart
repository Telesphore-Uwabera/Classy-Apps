import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart';
import 'package:singleton/singleton.dart';

class DriverFirebaseService {
  /// Factory method that reuse same instance automatically
  factory DriverFirebaseService() => Singleton.lazy(() => DriverFirebaseService._());

  /// Private constructor
  DriverFirebaseService._() {}

  /// Static instance getter
  static DriverFirebaseService get instance => DriverFirebaseService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GeoFlutterFire _geoFlutterFire = GeoFlutterFire();

  // ========================================
  // DRIVER AUTHENTICATION & PROFILE
  // ========================================

  /// Register driver with Firebase
  Future<User> registerDriver(Map<String, dynamic> driverData) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: driverData['email'],
        password: driverData['password'],
      );

      final userId = userCredential.user!.uid;
      
      // Create driver profile in Firestore
      final driverProfile = {
        'id': userId,
        'name': driverData['name'],
        'email': driverData['email'],
        'phone': driverData['phone'],
        'role': 'driver',
        'service_type': driverData['service_type'], // car, boda, food
        'status': 'pending_approval',
        'is_online': false,
        'is_available': false,
        'rating': 0.0,
        'total_rides': 0,
        'total_earnings': 0.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'profile_image': driverData['profile_image'] ?? '',
        'license_number': driverData['license_number'] ?? '',
        'vehicle_info': driverData['vehicle_info'] ?? {},
        'documents': driverData['documents'] ?? [],
        'emergency_contacts': driverData['emergency_contacts'] ?? [],
        'service_areas': driverData['service_areas'] ?? [],
      };

      await _firestore.collection('users').doc(userId).set(driverProfile);
      await _firestore.collection('drivers').doc(userId).set({
        'id': userId,
        'free': 1,
        'online': 0,
        'vehicle_type_id': driverData['vehicle_type_id'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });

      return User.fromJson(driverProfile);
    } catch (e) {
      throw Exception('Failed to register driver: $e');
    }
  }

  /// Update driver profile
  Future<bool> updateDriverProfile(String driverId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await _firestore.collection('users').doc(driverId).update(updates);
      return true;
    } catch (e) {
      throw Exception('Failed to update driver profile: $e');
    }
  }

  /// Get driver profile
  Future<User?> getDriverProfile(String driverId) async {
    try {
      final doc = await _firestore.collection('users').doc(driverId).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get driver profile: $e');
    }
  }

  // ========================================
  // DRIVER LOCATION & AVAILABILITY
  // ========================================

  /// Update driver location
  Future<bool> updateDriverLocation(String driverId, Position position, {bool isOnline = true}) async {
    try {
      final geoPoint = GeoPoint(position.latitude, position.longitude);
      final geoHash = _geoFlutterFire.point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final locationData = {
        'driver_id': driverId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
        'speed': position.speed,
        'accuracy': position.accuracy,
        'coordinates': geoPoint,
        'g': geoHash.data,
        'is_online': isOnline,
        'is_available': isOnline,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('driver_locations').doc(driverId).set(locationData, SetOptions(merge: true));
      
      // Also update drivers collection
      await _firestore.collection('drivers').doc(driverId).update({
        'lat': position.latitude,
        'long': position.longitude,
        'rotation': position.heading,
        'online': isOnline ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to update driver location: $e');
    }
  }

  /// Set driver online/offline status
  Future<bool> setDriverStatus(String driverId, bool isOnline, {bool isAvailable = true}) async {
    try {
      final updates = {
        'is_online': isOnline,
        'is_available': isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(driverId).update(updates);
      await _firestore.collection('drivers').doc(driverId).update({
        'online': isOnline ? 1 : 0,
        'free': isAvailable ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (isOnline) {
        await _firestore.collection('driver_availability').doc(driverId).set({
          'driver_id': driverId,
          'is_online': true,
          'is_available': isAvailable,
          'last_seen': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } else {
        await _firestore.collection('driver_availability').doc(driverId).delete();
      }

      return true;
    } catch (e) {
      throw Exception('Failed to set driver status: $e');
    }
  }

  /// Get nearby drivers
  Future<List<Map<String, dynamic>>> getNearbyDrivers(double latitude, double longitude, {double radius = 10, int limit = 20}) async {
    try {
      // For now, return empty list until GeoFlutterFire is properly configured
      // TODO: Implement proper geospatial queries with GeoFlutterFire
      print('getNearbyDrivers: GeoFlutterFire not configured yet');
      return [];
    } catch (e) {
      throw Exception('Failed to get nearby drivers: $e');
    }
  }

  // ========================================
  // ORDER MANAGEMENT
  // ========================================

  /// Get available orders for driver
  Stream<List<Map<String, dynamic>>> getAvailableOrdersStream(String driverId, {int limit = 50}) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .where('driver_id', isNull: true)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Get driver's assigned orders
  Stream<List<Map<String, dynamic>>> getDriverOrdersStream(String driverId, {int limit = 50}) {
    return _firestore
        .collection('orders')
        .where('driver_id', isEqualTo: driverId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Accept order
  Future<bool> acceptOrder(String orderId, String driverId) async {
    try {
      final batch = _firestore.batch();
      
      // Update order with driver assignment
      final orderRef = _firestore.collection('orders').doc(orderId);
      batch.update(orderRef, {
        'driver_id': driverId,
        'status': 'accepted',
        'accepted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Create order assignment record
      final assignmentRef = _firestore.collection('order_assignments').doc();
      batch.set(assignmentRef, {
        'id': assignmentRef.id,
        'order_id': orderId,
        'driver_id': driverId,
        'status': 'accepted',
        'assigned_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update driver availability
      final driverRef = _firestore.collection('drivers').doc(driverId);
      batch.update(driverRef, {
        'free': 0,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      throw Exception('Failed to accept order: $e');
    }
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
      
      // Update assignment status
      final assignmentQuery = await _firestore
          .collection('order_assignments')
          .where('order_id', isEqualTo: orderId)
          .get();
      
      if (assignmentQuery.docs.isNotEmpty) {
        await assignmentQuery.docs.first.reference.update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Complete order
  Future<bool> completeOrder(String orderId, String driverId, {Map<String, dynamic>? completionData}) async {
    try {
      final batch = _firestore.batch();
      
      // Update order status
      final orderRef = _firestore.collection('orders').doc(orderId);
      batch.update(orderRef, {
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...?completionData,
      });

      // Update assignment status
      final assignmentQuery = await _firestore
          .collection('order_assignments')
          .where('order_id', isEqualTo: orderId)
          .get();
      
      if (assignmentQuery.docs.isNotEmpty) {
        batch.update(assignmentQuery.docs.first.reference, {
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Free up driver
      final driverRef = _firestore.collection('drivers').doc(driverId);
      batch.update(driverRef, {
        'free': 1,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      throw Exception('Failed to complete order: $e');
    }
  }

  // ========================================
  // EARNINGS & PAYOUTS
  // ========================================

  /// Get driver earnings
  Stream<List<Map<String, dynamic>>> getDriverEarningsStream(String driverId, {int limit = 50}) {
    return _firestore
        .collection('driver_earnings')
        .where('driver_id', isEqualTo: driverId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Add earning record
  Future<bool> addEarning(String driverId, Map<String, dynamic> earningData) async {
    try {
      final earningRef = _firestore.collection('driver_earnings').doc();
      final earning = {
        'id': earningRef.id,
        'driver_id': driverId,
        'order_id': earningData['order_id'],
        'amount': earningData['amount'],
        'commission_rate': earningData['commission_rate'] ?? 0.1,
        'commission_amount': earningData['commission_amount'] ?? 0.0,
        'net_amount': earningData['net_amount'],
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await earningRef.set(earning);
      return true;
    } catch (e) {
      throw Exception('Failed to add earning: $e');
    }
  }

  /// Request payout
  Future<bool> requestPayout(String driverId, double amount) async {
    try {
      final payoutRef = _firestore.collection('driver_payouts').doc();
      final payout = {
        'id': payoutRef.id,
        'driver_id': driverId,
        'amount': amount,
        'status': 'pending',
        'requested_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await payoutRef.set(payout);
      return true;
    } catch (e) {
      throw Exception('Failed to request payout: $e');
    }
  }

  /// Get driver payouts
  Stream<List<Map<String, dynamic>>> getDriverPayoutsStream(String driverId, {int limit = 50}) {
    return _firestore
        .collection('driver_payouts')
        .where('driver_id', isEqualTo: driverId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  // ========================================
  // NOTIFICATIONS
  // ========================================

  /// Send notification to driver
  Future<bool> sendDriverNotification(String driverId, Map<String, dynamic> notificationData) async {
    try {
      final notificationRef = _firestore.collection('driver_notifications').doc();
      final notification = {
        'id': notificationRef.id,
        'driver_id': driverId,
        'title': notificationData['title'],
        'body': notificationData['body'],
        'type': notificationData['type'] ?? 'general',
        'data': notificationData['data'] ?? {},
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await notificationRef.set(notification);
      return true;
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Get driver notifications
  Stream<List<Map<String, dynamic>>> getDriverNotificationsStream(String driverId, {int limit = 50}) {
    return _firestore
        .collection('driver_notifications')
        .where('driver_id', isEqualTo: driverId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('driver_notifications').doc(notificationId).update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // ========================================
  // DOCUMENTS & VERIFICATION
  // ========================================

  /// Upload driver document
  Future<bool> uploadDriverDocument(String driverId, Map<String, dynamic> documentData) async {
    try {
      final documentRef = _firestore.collection('driver_documents').doc();
      final document = {
        'id': documentRef.id,
        'driver_id': driverId,
        'type': documentData['type'], // license, registration, insurance, etc.
        'file_url': documentData['file_url'],
        'file_name': documentData['file_name'],
        'file_size': documentData['file_size'],
        'status': 'pending_verification',
        'uploaded_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await documentRef.set(document);
      return true;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Get driver documents
  Stream<List<Map<String, dynamic>>> getDriverDocumentsStream(String driverId) {
    return _firestore
        .collection('driver_documents')
        .where('driver_id', isEqualTo: driverId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  // ========================================
  // CHAT & COMMUNICATION
  // ========================================

  /// Send message to customer
  Future<bool> sendMessage(String chatId, String driverId, String customerId, String message, {String? messageType = 'text'}) async {
    try {
      final messageRef = _firestore.collection('driver_chat').doc(chatId).collection('messages').doc();
      final messageData = {
        'id': messageRef.id,
        'chat_id': chatId,
        'sender_id': driverId,
        'receiver_id': customerId,
        'message': message,
        'message_type': messageType,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await messageRef.set(messageData);
      return true;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get chat messages
  Stream<List<Map<String, dynamic>>> getChatMessagesStream(String chatId, {int limit = 100}) {
    return _firestore
        .collection('driver_chat')
        .doc(chatId)
        .collection('messages')
        .orderBy('created_at')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Calculate distance between two points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        (math.sin(lat1) * math.sin(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2));
    
    final c = 2 * math.atan(math.sqrt(a) / math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Get driver statistics
  Future<Map<String, dynamic>> getDriverStats(String driverId) async {
    try {
      final earningsSnapshot = await _firestore
          .collection('driver_earnings')
          .where('driver_id', isEqualTo: driverId)
          .get();

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('driver_id', isEqualTo: driverId)
          .get();

      final completedOrders = ordersSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;

      final totalEarnings = earningsSnapshot.docs.fold<double>(0, (sum, doc) {
        return sum + (doc.data()['net_amount'] ?? 0.0);
      });

      final pendingEarnings = earningsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .fold<double>(0, (sum, doc) {
        return sum + (doc.data()['net_amount'] ?? 0.0);
      });

      return {
        'total_rides': completedOrders,
        'total_earnings': totalEarnings,
        'pending_earnings': pendingEarnings,
        'average_rating': 0.0, // This would need to be calculated from reviews
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get driver stats: $e');
    }
  }
}
