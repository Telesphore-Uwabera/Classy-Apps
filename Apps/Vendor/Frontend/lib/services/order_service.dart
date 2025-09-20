import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/order.dart';
import 'firebase_service.dart';

class OrderService {
  static OrderService? _instance;
  static OrderService get instance => _instance ??= OrderService._();
  
  OrderService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Order CRUD operations - Optimized for speed
  Future<List<Order>> getOrders(String vendorId) async {
    try {
      // Use limit and order by for faster loading
      final querySnapshot = await _firebaseService.firestore
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('createdAt', descending: true)
          .limit(50) // Limit for faster loading
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  Future<Order?> getOrder(String orderId) async {
    try {
      final doc = await _firebaseService.getDocument('orders', orderId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Order.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firebaseService.updateDocument('orders', orderId, {
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  Future<bool> assignDriver(String orderId, String driverId) async {
    try {
      await _firebaseService.updateDocument('orders', orderId, {
        'driverId': driverId,
        'status': 'delivering',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error assigning driver: $e');
      return false;
    }
  }

  // Get orders by status
  Future<List<Order>> getOrdersByStatus(String vendorId, String status) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting orders by status: $e');
      return [];
    }
  }

  // Get today's orders
  Future<List<Order>> getTodaysOrders(String vendorId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final querySnapshot = await _firebaseService.firestore
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('createdAt', isLessThan: endOfDay.millisecondsSinceEpoch)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting today\'s orders: $e');
      return [];
    }
  }

  // Get orders by date range
  Future<List<Order>> getOrdersByDateRange(String vendorId, DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('createdAt', isLessThan: endDate.millisecondsSinceEpoch)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting orders by date range: $e');
      return [];
    }
  }

  // Stream orders for real-time updates
  Stream<List<Order>> streamOrders(String vendorId) {
    return _firebaseService.firestore
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
    });
  }

  // Get order statistics - Optimized for speed
  Future<Map<String, dynamic>> getOrderStats(String vendorId) async {
    try {
      // Use aggregation queries for faster stats calculation
      final ordersSnapshot = await _firebaseService.firestore
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .limit(100) // Limit for faster processing
          .get();
      
      final orders = ordersSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
      
      // Quick stats calculation
      int totalOrders = orders.length;
      int pendingOrders = 0;
      int completedOrders = 0;
      double totalRevenue = 0.0;
      
      for (final order in orders) {
        switch (order.status) {
          case 'pending':
            pendingOrders++;
            break;
          case 'completed':
            completedOrders++;
            totalRevenue += order.totalAmount;
            break;
        }
      }
      
      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print('Error getting order stats: $e');
      return {
        'totalOrders': 0,
        'pendingOrders': 0,
        'completedOrders': 0,
        'totalRevenue': 0.0,
      };
    }
  }
}
