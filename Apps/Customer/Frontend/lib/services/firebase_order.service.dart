import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase_data.service.dart';
import 'package:Classy/services/firebase_notification.service.dart';

class FirebaseOrderService {
  static final FirebaseOrderService _instance = FirebaseOrderService._internal();
  factory FirebaseOrderService() => _instance;
  FirebaseOrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDataService _firebaseDataService = FirebaseDataService();
  final FirebaseNotificationService _notificationService = FirebaseNotificationService();

  // Stream controllers for real-time order updates
  final StreamController<List<Map<String, dynamic>>> _ordersController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderUpdatesController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams for listening to order data
  Stream<List<Map<String, dynamic>>> get ordersStream => _ordersController.stream;
  Stream<Map<String, dynamic>> get orderUpdatesStream => _orderUpdatesController.stream;

  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  Map<String, StreamSubscription<Map<String, dynamic>>> _orderSubscriptions = {};

  /// Initialize order service
  void initialize() {
    _startRealTimeUpdates();
  }

  /// Start real-time updates for orders
  void _startRealTimeUpdates() {
    final currentUser = AuthServices.currentUser;
    if (currentUser?.id == null) return;

    // Listen to user's orders
    _ordersSubscription?.cancel();
    _ordersSubscription = _firestore
        .collection('orders')
        .where('customer_id', isEqualTo: currentUser!.id.toString())
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final orders = snapshot.docs.map((doc) => doc.data()).toList();
      _ordersController.add(orders);
    });
  }

  /// Create order
  Future<ApiResponse> createOrder(Map<String, dynamic> orderData) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final orderRef = _firestore.collection('orders').doc();
      final order = {
        'id': orderRef.id,
        'order_number': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        'customer_id': currentUser!.id.toString(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...orderData,
      };

      await orderRef.set(order);

      // Send notification to customer
      await _notificationService.createNotification(
        title: "Order Placed Successfully",
        body: "Your order #${order['order_number']} has been placed and is being processed.",
        type: 'order',
        data: {
          'is_order': true,
          'order_id': order['id'],
          'order_number': order['order_number'],
        },
      );

      return ApiResponse(
        code: 200,
        message: "Order created successfully",
        body: order,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to create order: $e",
        body: null,
        errors: ["Failed to create order: $e"],
      );
    }
  }

  /// Get user orders
  Future<ApiResponse> getUserOrders({
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      Query query = _firestore
          .collection('orders')
          .where('customer_id', isEqualTo: currentUser!.id.toString())
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      final orders = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(
        code: 200,
        message: "Orders fetched successfully",
        body: {'orders': orders},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to fetch orders: $e",
        body: null,
        errors: ["Failed to fetch orders: $e"],
      );
    }
  }

  /// Get order by ID
  Future<ApiResponse> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      
      if (!doc.exists) {
        return ApiResponse(code: 404, message: "Order not found");
      }

      return ApiResponse(
        code: 200,
        message: "Order fetched successfully",
        body: doc.data(),
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to fetch order: $e",
        body: null,
        errors: ["Failed to fetch order: $e"],
      );
    }
  }

  /// Update order status
  Future<ApiResponse> updateOrderStatus(String orderId, String status, {Map<String, dynamic>? additionalData}) async {
    try {
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      await _firestore.collection('orders').doc(orderId).update(updates);

      // Get order details for notification
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data()!;
        
        // Send notification to customer
        await _notificationService.createNotification(
          title: "Order Status Updated",
          body: "Your order #${orderData['order_number']} status has been updated to ${status.toUpperCase()}.",
          type: 'order',
          data: {
            'is_order': true,
            'order_id': orderId,
            'order_number': orderData['order_number'],
            'status': status,
          },
        );
      }

      return ApiResponse(
        code: 200,
        message: "Order status updated successfully",
        body: updates,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to update order status: $e",
        body: null,
        errors: ["Failed to update order status: $e"],
      );
    }
  }

  /// Cancel order
  Future<ApiResponse> cancelOrder(String orderId, {String? reason}) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Check if order can be cancelled
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        return ApiResponse(code: 404, message: "Order not found");
      }

      final orderData = orderDoc.data()!;
      final currentStatus = orderData['status'] as String?;

      if (['cancelled', 'delivered', 'completed'].contains(currentStatus)) {
        return ApiResponse(code: 400, message: "Order cannot be cancelled in current status");
      }

      // Update order status
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
        'cancellation_reason': reason ?? 'Customer requested cancellation',
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Send notification
      await _notificationService.createNotification(
        title: "Order Cancelled",
        body: "Your order #${orderData['order_number']} has been cancelled.",
        type: 'order',
        data: {
          'is_order': true,
          'order_id': orderId,
          'order_number': orderData['order_number'],
          'status': 'cancelled',
        },
      );

      return ApiResponse(
        code: 200,
        message: "Order cancelled successfully",
        body: null,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to cancel order: $e",
        body: null,
        errors: ["Failed to cancel order: $e"],
      );
    }
  }

  /// Track order
  Future<ApiResponse> trackOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      
      if (!doc.exists) {
        return ApiResponse(code: 404, message: "Order not found");
      }

      final orderData = doc.data()!;
      
      // Get order tracking information
      final trackingData = {
        'order_id': orderId,
        'order_number': orderData['order_number'],
        'status': orderData['status'],
        'created_at': orderData['created_at'],
        'updated_at': orderData['updated_at'],
        'estimated_delivery': orderData['estimated_delivery'],
        'driver_location': orderData['driver_location'],
        'tracking_updates': orderData['tracking_updates'] ?? [],
      };

      return ApiResponse(
        code: 200,
        message: "Order tracking data fetched successfully",
        body: trackingData,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to track order: $e",
        body: null,
        errors: ["Failed to track order: $e"],
      );
    }
  }

  /// Add tracking update
  Future<ApiResponse> addTrackingUpdate(String orderId, Map<String, dynamic> updateData) async {
    try {
      final update = {
        'status': updateData['status'],
        'message': updateData['message'],
        'timestamp': DateTime.now().toIso8601String(),
        'location': updateData['location'],
        'driver_name': updateData['driver_name'],
        'driver_phone': updateData['driver_phone'],
      };

      await _firestore.collection('orders').doc(orderId).update({
        'tracking_updates': FieldValue.arrayUnion([update]),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return ApiResponse(
        code: 200,
        message: "Tracking update added successfully",
        body: update,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to add tracking update: $e",
        body: null,
        errors: ["Failed to add tracking update: $e"],
      );
    }
  }

  /// Rate order
  Future<ApiResponse> rateOrder(String orderId, {
    required double rating,
    String? review,
    Map<String, double>? categoryRatings,
  }) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Check if order exists and is delivered
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        return ApiResponse(code: 404, message: "Order not found");
      }

      final orderData = orderDoc.data()!;
      if (orderData['status'] != 'delivered') {
        return ApiResponse(code: 400, message: "Order must be delivered before rating");
      }

      // Create rating
      final ratingData = {
        'order_id': orderId,
        'customer_id': currentUser!.id.toString(),
        'rating': rating,
        'review': review,
        'category_ratings': categoryRatings,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('ratings').add(ratingData);

      // Update order with rating
      await _firestore.collection('orders').doc(orderId).update({
        'rating': rating,
        'review': review,
        'rated_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return ApiResponse(
        code: 200,
        message: "Order rated successfully",
        body: ratingData,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to rate order: $e",
        body: null,
        errors: ["Failed to rate order: $e"],
      );
    }
  }

  /// Get order statistics
  Future<ApiResponse> getOrderStatistics() async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final snapshot = await _firestore
          .collection('orders')
          .where('customer_id', isEqualTo: currentUser!.id.toString())
          .get();

      final orders = snapshot.docs.map((doc) => doc.data()).toList();
      
      final stats = {
        'total_orders': orders.length,
        'pending_orders': orders.where((o) => o['status'] == 'pending').length,
        'confirmed_orders': orders.where((o) => o['status'] == 'confirmed').length,
        'preparing_orders': orders.where((o) => o['status'] == 'preparing').length,
        'ready_orders': orders.where((o) => o['status'] == 'ready').length,
        'delivered_orders': orders.where((o) => o['status'] == 'delivered').length,
        'cancelled_orders': orders.where((o) => o['status'] == 'cancelled').length,
        'total_spent': orders
            .where((o) => ['delivered', 'completed'].contains(o['status']))
            .fold<double>(0, (sum, order) => sum + (order['total'] ?? 0.0)),
      };

      return ApiResponse(
        code: 200,
        message: "Order statistics fetched successfully",
        body: stats,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to fetch order statistics: $e",
        body: null,
        errors: ["Failed to fetch order statistics: $e"],
      );
    }
  }

  /// Listen to specific order updates
  Stream<Map<String, dynamic>> listenToOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  /// Start listening to specific order
  void startListeningToOrder(String orderId) {
    _orderSubscriptions[orderId]?.cancel();
    _orderSubscriptions[orderId] = listenToOrder(orderId).listen((orderData) {
      _orderUpdatesController.add(orderData);
    });
  }

  /// Stop listening to specific order
  void stopListeningToOrder(String orderId) {
    _orderSubscriptions[orderId]?.cancel();
    _orderSubscriptions.remove(orderId);
  }

  /// Dispose resources
  void dispose() {
    _ordersSubscription?.cancel();
    for (final subscription in _orderSubscriptions.values) {
      subscription.cancel();
    }
    _orderSubscriptions.clear();
    _ordersController.close();
    _orderUpdatesController.close();
  }
}
