import 'dart:async';
import 'package:Classy/models/order.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/firebase_order.service.dart';

class OrderService {
  static final FirebaseOrderService _firebaseService = FirebaseOrderService();

  /// Initialize order service
  static void initialize() {
    _firebaseService.initialize();
  }

  /// Create order
  static Future<ApiResponse> createOrder(Map<String, dynamic> orderData) async {
    return await _firebaseService.createOrder(orderData);
  }

  /// Get user orders
  static Future<ApiResponse> getUserOrders({
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    return await _firebaseService.getUserOrders(
      limit: limit,
      offset: offset,
      status: status,
    );
  }

  /// Get order by ID
  static Future<ApiResponse> getOrderById(String orderId) async {
    return await _firebaseService.getOrderById(orderId);
  }

  /// Update order status
  static Future<ApiResponse> updateOrderStatus(String orderId, String status, {Map<String, dynamic>? additionalData}) async {
    return await _firebaseService.updateOrderStatus(orderId, status, additionalData: additionalData);
  }

  /// Cancel order
  static Future<ApiResponse> cancelOrder(String orderId, {String? reason}) async {
    return await _firebaseService.cancelOrder(orderId, reason: reason);
  }

  /// Track order
  static Future<ApiResponse> trackOrder(String orderId) async {
    return await _firebaseService.trackOrder(orderId);
  }

  /// Add tracking update
  static Future<ApiResponse> addTrackingUpdate(String orderId, Map<String, dynamic> updateData) async {
    return await _firebaseService.addTrackingUpdate(orderId, updateData);
  }

  /// Rate order
  static Future<ApiResponse> rateOrder(String orderId, {
    required double rating,
    String? review,
    Map<String, double>? categoryRatings,
  }) async {
    return await _firebaseService.rateOrder(orderId, rating: rating, review: review, categoryRatings: categoryRatings);
  }

  /// Get order statistics
  static Future<ApiResponse> getOrderStatistics() async {
    return await _firebaseService.getOrderStatistics();
  }

  /// Listen to user orders
  static Stream<List<Map<String, dynamic>>> getUserOrdersStream() {
    return _firebaseService.ordersStream;
  }

  /// Listen to specific order updates
  static Stream<Map<String, dynamic>> listenToOrder(String orderId) {
    return _firebaseService.listenToOrder(orderId);
  }

  /// Start listening to specific order
  static void startListeningToOrder(String orderId) {
    _firebaseService.startListeningToOrder(orderId);
  }

  /// Stop listening to specific order
  static void stopListeningToOrder(String orderId) {
    _firebaseService.stopListeningToOrder(orderId);
  }

  /// Handle background message
  static Future<dynamic> openOrderPayment(Order order, dynamic vm) async {
    //
    if ((order.paymentMethod?.slug ?? "offline") != "offline") {
      return vm.openWebpageLink(order.paymentLink);
    } else {
      return vm.openExternalWebpageLink(order.paymentLink);
    }
  }

  /// Dispose resources
  static void dispose() {
    _firebaseService.dispose();
  }
}
