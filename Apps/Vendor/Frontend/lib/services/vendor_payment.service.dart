import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Classy/models/api_response.dart';

/// Vendor Payment Service for CLASSY UG Payment Integration
/// Handles vendor-specific payment operations and commission tracking
class VendorPaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get vendor's earnings and commission summary
  static Future<ApiResponse> getVendorEarnings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Vendor not authenticated");
      }

      // Get vendor's completed orders
      final ordersQuery = await _firestore
          .collection('orders')
          .where('vendor_id', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .get();

      double totalEarnings = 0;
      double totalCommission = 0;
      int completedOrders = 0;

      for (var order in ordersQuery.docs) {
        final data = order.data();
        final amount = (data['total'] ?? 0.0).toDouble();
        final commission = (data['commission'] ?? 0.0).toDouble();
        
        totalEarnings += amount;
        totalCommission += commission;
        completedOrders++;
      }

      // Get pending settlements
      final settlementsQuery = await _firestore
          .collection('settlements')
          .where('provider_id', isEqualTo: user.uid)
          .where('provider_type', isEqualTo: 'vendor')
          .get();

      double pendingSettlements = 0;
      for (var settlement in settlementsQuery.docs) {
        final data = settlement.data();
        if (data['status'] == 'pending' || data['status'] == 'processing') {
          pendingSettlements += (data['amount'] ?? 0.0).toDouble();
        }
      }

      return ApiResponse(
        code: 200,
        message: "Vendor earnings retrieved successfully",
        body: {
          'total_earnings': totalEarnings,
          'total_commission': totalCommission,
          'completed_orders': completedOrders,
          'pending_settlements': pendingSettlements,
          'net_earnings': totalEarnings - totalCommission,
        },
      );
    } catch (e) {
      print("❌ Error getting vendor earnings: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get vendor earnings: ${e.toString()}",
      );
    }
  }

  /// Get vendor's commission history
  static Future<ApiResponse> getVendorCommissionHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Vendor not authenticated");
      }

      final commissionsQuery = await _firestore
          .collection('provider_commissions')
          .where('provider_id', isEqualTo: user.uid)
          .where('provider_type', isEqualTo: 'vendor')
          .orderBy('created_at', descending: true)
          .get();

      final commissions = commissionsQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'] ?? 0.0,
          'status': data['status'] ?? 'pending',
          'created_at': data['created_at']?.toDate() ?? DateTime.now(),
          'settlement_id': data['settlement_id'],
        };
      }).toList();

      return ApiResponse(
        code: 200,
        message: "Commission history retrieved successfully",
        body: {
          'commissions': commissions,
        },
      );
    } catch (e) {
      print("❌ Error getting vendor commission history: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get vendor commission history: ${e.toString()}",
      );
    }
  }

  /// Request settlement for vendor earnings
  static Future<ApiResponse> requestSettlement({
    required double amount,
    required String settlementMethod, // 'mobile_money', 'bank_transfer'
    required String accountDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Vendor not authenticated");
      }

      // Check if vendor has pending commissions
      final pendingCommissionsQuery = await _firestore
          .collection('provider_commissions')
          .where('provider_id', isEqualTo: user.uid)
          .where('provider_type', isEqualTo: 'vendor')
          .where('status', isEqualTo: 'pending')
          .get();

      if (pendingCommissionsQuery.docs.isEmpty) {
        return ApiResponse(
          code: 400,
          message: "No pending commissions to settle",
        );
      }

      // Calculate total pending amount
      double totalPending = 0;
      for (var doc in pendingCommissionsQuery.docs) {
        totalPending += (doc.data()['amount'] ?? 0.0).toDouble();
      }

      if (amount > totalPending) {
        return ApiResponse(
          code: 400,
          message: "Settlement amount exceeds pending commissions",
        );
      }

      // Create settlement request
      final settlementData = {
        'provider_id': user.uid,
        'provider_type': 'vendor',
        'amount': amount,
        'settlement_method': settlementMethod,
        'account_details': accountDetails,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      final settlementRef = await _firestore
          .collection('settlements')
          .add(settlementData);

      return ApiResponse(
        code: 200,
        message: "Settlement request submitted successfully",
        body: {
          'settlement_id': settlementRef.id,
          'amount': amount,
          'status': 'pending',
        },
      );
    } catch (e) {
      print("❌ Error requesting settlement: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to request settlement: ${e.toString()}",
      );
    }
  }

  /// Get vendor's settlement history
  static Future<ApiResponse> getVendorSettlementHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Vendor not authenticated");
      }

      final settlementsQuery = await _firestore
          .collection('settlements')
          .where('provider_id', isEqualTo: user.uid)
          .where('provider_type', isEqualTo: 'vendor')
          .orderBy('created_at', descending: true)
          .get();

      final settlements = settlementsQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'] ?? 0.0,
          'settlement_method': data['settlement_method'] ?? 'mobile_money',
          'account_details': data['account_details'] ?? '',
          'status': data['status'] ?? 'pending',
          'created_at': data['created_at']?.toDate() ?? DateTime.now(),
          'updated_at': data['updated_at']?.toDate() ?? DateTime.now(),
        };
      }).toList();

      return ApiResponse(
        code: 200,
        message: "Settlement history retrieved successfully",
        body: {
          'settlements': settlements,
        },
      );
    } catch (e) {
      print("❌ Error getting vendor settlement history: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get vendor settlement history: ${e.toString()}",
      );
    }
  }

  /// Get vendor's order payments
  static Future<ApiResponse> getVendorOrderPayments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Vendor not authenticated");
      }

      final ordersQuery = await _firestore
          .collection('orders')
          .where('vendor_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      final orders = ordersQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'order_id': data['id'] ?? '',
          'customer_name': data['customer_name'] ?? 'Unknown',
          'amount': data['total'] ?? 0.0,
          'commission': data['commission'] ?? 0.0,
          'payment_method': data['payment_method'] ?? 'cash',
          'status': data['status'] ?? 'pending',
          'created_at': data['created_at']?.toDate() ?? DateTime.now(),
        };
      }).toList();

      return ApiResponse(
        code: 200,
        message: "Order payments retrieved successfully",
        body: {
          'orders': orders,
        },
      );
    } catch (e) {
      print("❌ Error getting vendor order payments: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get vendor order payments: ${e.toString()}",
      );
    }
  }

  /// Update vendor's payment account details
  static Future<ApiResponse> updatePaymentAccount({
    required String settlementMethod,
    required String accountDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Vendor not authenticated");
      }

      // Update vendor's payment account in Firestore
      await _firestore.collection('vendors').doc(user.uid).update({
        'settlement_method': settlementMethod,
        'account_details': accountDetails,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return ApiResponse(
        code: 200,
        message: "Payment account updated successfully",
      );
    } catch (e) {
      print("❌ Error updating payment account: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to update payment account: ${e.toString()}",
      );
    }
  }

  /// Get vendor's payment account details
  static Future<ApiResponse> getPaymentAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Vendor not authenticated");
      }

      final vendorDoc = await _firestore.collection('vendors').doc(user.uid).get();
      
      if (!vendorDoc.exists) {
        return ApiResponse(
          code: 404,
          message: "Vendor profile not found",
        );
      }

      final data = vendorDoc.data()!;
      return ApiResponse(
        code: 200,
        message: "Payment account retrieved successfully",
        body: {
          'settlement_method': data['settlement_method'] ?? 'mobile_money',
          'account_details': data['account_details'] ?? '',
        },
      );
    } catch (e) {
      print("❌ Error getting payment account: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get payment account: ${e.toString()}",
      );
    }
  }

  /// Get vendor's daily sales report
  static Future<ApiResponse> getDailySalesReport(DateTime date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Vendor not authenticated");
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final ordersQuery = await _firestore
          .collection('orders')
          .where('vendor_id', isEqualTo: user.uid)
          .where('created_at', isGreaterThanOrEqualTo: startOfDay)
          .where('created_at', isLessThan: endOfDay)
          .get();

      double totalSales = 0;
      double totalCommission = 0;
      int totalOrders = 0;
      Map<String, double> salesByPaymentMethod = {};

      for (var order in ordersQuery.docs) {
        final data = order.data();
        final amount = (data['total'] ?? 0.0).toDouble();
        final commission = (data['commission'] ?? 0.0).toDouble();
        final paymentMethod = data['payment_method'] ?? 'cash';
        
        totalSales += amount;
        totalCommission += commission;
        totalOrders++;
        
        salesByPaymentMethod[paymentMethod] = (salesByPaymentMethod[paymentMethod] ?? 0) + amount;
      }

      return ApiResponse(
        code: 200,
        message: "Daily sales report retrieved successfully",
        body: {
          'date': date.toIso8601String().split('T')[0],
          'total_sales': totalSales,
          'total_commission': totalCommission,
          'total_orders': totalOrders,
          'net_earnings': totalSales - totalCommission,
          'sales_by_payment_method': salesByPaymentMethod,
        },
      );
    } catch (e) {
      print("❌ Error getting daily sales report: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get daily sales report: ${e.toString()}",
      );
    }
  }
}
