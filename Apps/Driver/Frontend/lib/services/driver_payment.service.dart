import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Classy/models/api_response.dart';

/// Driver Payment Service for CLASSY UG Payment Integration
/// Handles driver-specific payment operations and commission tracking
class DriverPaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get driver's earnings and commission summary
  static Future<ApiResponse> getDriverEarnings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Driver not authenticated");
      }

      // Get driver's completed trips
      final tripsQuery = await _firestore
          .collection('orders')
          .where('driver_id', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .get();

      double totalEarnings = 0;
      double totalCommission = 0;
      int completedTrips = 0;

      for (var trip in tripsQuery.docs) {
        final data = trip.data();
        final amount = (data['total'] ?? 0.0).toDouble();
        final commission = (data['commission'] ?? 0.0).toDouble();
        
        totalEarnings += amount;
        totalCommission += commission;
        completedTrips++;
      }

      // Get pending settlements
      final settlementsQuery = await _firestore
          .collection('settlements')
          .where('provider_id', isEqualTo: user.uid)
          .where('provider_type', isEqualTo: 'driver')
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
        message: "Driver earnings retrieved successfully",
        body: {
          'total_earnings': totalEarnings,
          'total_commission': totalCommission,
          'completed_trips': completedTrips,
          'pending_settlements': pendingSettlements,
          'net_earnings': totalEarnings - totalCommission,
        },
      );
    } catch (e) {
      print("❌ Error getting driver earnings: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get driver earnings: ${e.toString()}",
      );
    }
  }

  /// Get driver's commission history
  static Future<ApiResponse> getDriverCommissionHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Driver not authenticated");
      }

      final commissionsQuery = await _firestore
          .collection('provider_commissions')
          .where('provider_id', isEqualTo: user.uid)
          .where('provider_type', isEqualTo: 'driver')
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
      print("❌ Error getting driver commission history: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get driver commission history: ${e.toString()}",
      );
    }
  }

  /// Request settlement for driver earnings
  static Future<ApiResponse> requestSettlement({
    required double amount,
    required String settlementMethod, // 'mobile_money', 'bank_transfer'
    required String accountDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Driver not authenticated");
      }

      // Check if driver has pending commissions
      final pendingCommissionsQuery = await _firestore
          .collection('provider_commissions')
          .where('provider_id', isEqualTo: user.uid)
          .where('provider_type', isEqualTo: 'driver')
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
        'provider_type': 'driver',
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

  /// Get driver's settlement history
  static Future<ApiResponse> getDriverSettlementHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Driver not authenticated");
      }

      final settlementsQuery = await _firestore
          .collection('settlements')
          .where('provider_id', isEqualTo: user.uid)
          .where('provider_type', isEqualTo: 'driver')
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
      print("❌ Error getting driver settlement history: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get driver settlement history: ${e.toString()}",
      );
    }
  }

  /// Get driver's trip payments
  static Future<ApiResponse> getDriverTripPayments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Driver not authenticated");
      }

      final tripsQuery = await _firestore
          .collection('orders')
          .where('driver_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      final trips = tripsQuery.docs.map((doc) {
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
        message: "Trip payments retrieved successfully",
        body: {
          'trips': trips,
        },
      );
    } catch (e) {
      print("❌ Error getting driver trip payments: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get driver trip payments: ${e.toString()}",
      );
    }
  }

  /// Update driver's payment account details
  static Future<ApiResponse> updatePaymentAccount({
    required String settlementMethod,
    required String accountDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Driver not authenticated");
      }

      // Update driver's payment account in Firestore
      await _firestore.collection('drivers').doc(user.uid).update({
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

  /// Get driver's payment account details
  static Future<ApiResponse> getPaymentAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "Driver not authenticated");
      }

      final driverDoc = await _firestore.collection('drivers').doc(user.uid).get();
      
      if (!driverDoc.exists) {
        return ApiResponse(
          code: 404,
          message: "Driver profile not found",
        );
      }

      final data = driverDoc.data()!;
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
}
