import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/constants/api.dart';

class FirebasePaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get user's payment accounts from Firestore
  static Future<ApiResponse> getPaymentAccounts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final snapshot = await _firestore
          .collection(Api.paymentMethodsCollection)
          .where('user_id', isEqualTo: user.uid)
          .get();

      final accounts = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      return ApiResponse(
        code: 200,
        message: "Payment accounts retrieved successfully",
        body: {
          'data': {
            'data': accounts,
          },
        },
      );
    } catch (e) {
      print("❌ Error getting payment accounts: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get payment accounts: ${e.toString()}",
      );
    }
  }

  /// Add new payment account to Firestore
  static Future<ApiResponse> addPaymentAccount({
    required String name,
    required String number,
    String? instructions,
    bool isActive = true,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final accountData = {
        'user_id': user.uid,
        'name': name,
        'number': number,
        'instructions': instructions ?? '',
        'is_active': isActive ? 1 : 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection(Api.paymentMethodsCollection)
          .add(accountData);

      return ApiResponse(
        code: 201,
        message: "Payment account added successfully",
        body: {
          'id': docRef.id,
          ...accountData,
        },
      );
    } catch (e) {
      print("❌ Error adding payment account: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to add payment account: ${e.toString()}",
      );
    }
  }

  /// Update payment account in Firestore
  static Future<ApiResponse> updatePaymentAccount({
    required String accountId,
    required String name,
    required String number,
    String? instructions,
    bool isActive = true,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Verify the account belongs to the current user
      final doc = await _firestore
          .collection(Api.paymentMethodsCollection)
          .doc(accountId)
          .get();

      if (!doc.exists) {
        return ApiResponse(code: 404, message: "Payment account not found");
      }

      final data = doc.data()!;
      if (data['user_id'] != user.uid) {
        return ApiResponse(code: 403, message: "Access denied");
      }

      final updateData = {
        'name': name,
        'number': number,
        'instructions': instructions ?? '',
        'is_active': isActive ? 1 : 0,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(Api.paymentMethodsCollection)
          .doc(accountId)
          .update(updateData);

      return ApiResponse(
        code: 200,
        message: "Payment account updated successfully",
        body: {
          'id': accountId,
          ...data,
          ...updateData,
        },
      );
    } catch (e) {
      print("❌ Error updating payment account: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to update payment account: ${e.toString()}",
      );
    }
  }

  /// Delete payment account from Firestore
  static Future<ApiResponse> deletePaymentAccount(String accountId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Verify the account belongs to the current user
      final doc = await _firestore
          .collection(Api.paymentMethodsCollection)
          .doc(accountId)
          .get();

      if (!doc.exists) {
        return ApiResponse(code: 404, message: "Payment account not found");
      }

      final data = doc.data()!;
      if (data['user_id'] != user.uid) {
        return ApiResponse(code: 403, message: "Access denied");
      }

      await _firestore
          .collection(Api.paymentMethodsCollection)
          .doc(accountId)
          .delete();

      return ApiResponse(
        code: 200,
        message: "Payment account deleted successfully",
      );
    } catch (e) {
      print("❌ Error deleting payment account: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to delete payment account: ${e.toString()}",
      );
    }
  }

  /// Get available payment methods (Eversend, MoMo, Card)
  static Future<ApiResponse> getPaymentMethods({
    String? vendorId,
    bool forWallet = false,
    bool forPickup = false,
    bool useTaxi = false,
  }) async {
    try {
      // Return the three supported payment methods
      final paymentMethods = [
        {
          'id': 'eversend',
          'name': 'Eversend',
          'type': 'eversend',
          'enabled': true,
          'icon': 'assets/images/eversend.png',
          'description': 'Send money globally with Eversend',
        },
        {
          'id': 'momo',
          'name': 'Mobile Money',
          'type': 'momo',
          'enabled': true,
          'icon': 'assets/images/momo.png',
          'description': 'Pay with Mobile Money (MTN, Airtel, etc.)',
        },
        {
          'id': 'card',
          'name': 'Card Payment',
          'type': 'card',
          'enabled': true,
          'icon': 'assets/images/card.png',
          'description': 'Pay with your debit or credit card',
        },
      ];

      return ApiResponse(
        code: 200,
        message: "Payment methods retrieved successfully",
        body: paymentMethods,
      );
    } catch (e) {
      print("❌ Error getting payment methods: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get payment methods: ${e.toString()}",
      );
    }
  }

  /// Process Eversend payment
  static Future<ApiResponse> processEversendPayment({
    required String amount,
    required String currency,
    required String phoneNumber,
    required String orderId,
  }) async {
    try {
      // For now, simulate a successful payment
      // In a real app, you would integrate with Eversend API
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      return ApiResponse(
        code: 200,
        message: "Eversend payment processed successfully",
        body: {
          'transaction_id': 'eversend_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'success',
          'amount': amount,
          'currency': currency,
        },
      );
    } catch (e) {
      print("❌ Error processing Eversend payment: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process Eversend payment: ${e.toString()}",
      );
    }
  }

  /// Process Mobile Money payment
  static Future<ApiResponse> processMomoPayment({
    required String amount,
    required String currency,
    required String phoneNumber,
    required String orderId,
  }) async {
    try {
      // For now, simulate a successful payment
      // In a real app, you would integrate with Mobile Money API
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      return ApiResponse(
        code: 200,
        message: "Mobile Money payment processed successfully",
        body: {
          'transaction_id': 'momo_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'success',
          'amount': amount,
          'currency': currency,
        },
      );
    } catch (e) {
      print("❌ Error processing Mobile Money payment: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process Mobile Money payment: ${e.toString()}",
      );
    }
  }

  /// Process Card payment
  static Future<ApiResponse> processCardPayment({
    required String amount,
    required String currency,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
    required String orderId,
  }) async {
    try {
      // For now, simulate a successful payment
      // In a real app, you would integrate with a payment processor like Stripe
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      return ApiResponse(
        code: 200,
        message: "Card payment processed successfully",
        body: {
          'transaction_id': 'card_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'success',
          'amount': amount,
          'currency': currency,
        },
      );
    } catch (e) {
      print("❌ Error processing card payment: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process card payment: ${e.toString()}",
      );
    }
  }

  /// Check payment status
  static Future<ApiResponse> checkPaymentStatus(String transactionId) async {
    try {
      // For now, simulate checking payment status
      // In a real app, you would check with the payment provider
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      return ApiResponse(
        code: 200,
        message: "Payment status retrieved successfully",
        body: {
          'transaction_id': transactionId,
          'status': 'success',
          'amount': '0.00',
          'currency': 'USD',
        },
      );
    } catch (e) {
      print("❌ Error checking payment status: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to check payment status: ${e.toString()}",
      );
    }
  }

  /// Process refund
  static Future<ApiResponse> processRefund({
    required String transactionId,
    required String amount,
    required String reason,
  }) async {
    try {
      // For now, simulate a successful refund
      // In a real app, you would process the refund with the payment provider
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      return ApiResponse(
        code: 200,
        message: "Refund processed successfully",
        body: {
          'refund_id': 'refund_${DateTime.now().millisecondsSinceEpoch}',
          'transaction_id': transactionId,
          'amount': amount,
          'status': 'success',
        },
      );
    } catch (e) {
      print("❌ Error processing refund: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process refund: ${e.toString()}",
      );
    }
  }
}
