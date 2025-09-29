import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/constants/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enhanced Payment Service implementing CLASSY UG payment integration
/// Supports: Cash, Mobile Money (MTN/Airtel), Visa/Mastercard, Eversend
class EnhancedPaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Eversend API credentials
  static const String _eversendClientId = 'hWt1SZJ7YaZfrV0dpcM-g3OIvhFYaUgh';
  static const String _eversendClientSecret = 'u55kdhkbqRqDZ6qZoj5_p2Cok8MeiS3XN8_fRNo7uBaA8bNKmW00IPKO0en1zdn0';
  static const String _eversendBaseUrl = 'https://api.eversend.co/v1';
  
  // Payment gateway credentials (to be configured)
  static const String _gatewayApiKey = 'YOUR_GATEWAY_API_KEY';
  static const String _gatewayBaseUrl = 'https://api.gateway.com/v1';

  // Commission rates (configurable)
  static const double _commissionRate = 0.15; // 15% commission
  static const double _processingFee = 0.0; // No processing fee for now

  /// ===== CASH PAYMENT FLOW =====
  
  /// Process cash payment
  static Future<ApiResponse> processCashPayment({
    required String orderId,
    required double amount,
    required String currency,
    required String customerId,
    required String providerId,
    required String providerType, // 'driver', 'vendor', 'restaurant'
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Calculate commission
      final commission = amount * _commissionRate;
      final netAmount = amount - commission;

      // Create payment record
      final paymentData = {
        'id': _generateTransactionId(),
        'order_id': orderId,
        'customer_id': customerId,
        'provider_id': providerId,
        'provider_type': providerType,
        'amount': amount,
        'currency': currency,
        'payment_method': 'cash',
        'status': 'completed',
        'commission': commission,
        'processing_fee': _processingFee,
        'net_amount': netAmount,
        'settlement_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Save payment to Firestore
      await _firestore.collection('payments').add(paymentData);

      // Update provider's outstanding commission
      await _updateProviderCommission(providerId, providerType, commission);

      // Update order status
      await _updateOrderStatus(orderId, 'paid', 'cash');

      return ApiResponse(
        code: 200,
        message: "Cash payment processed successfully",
        body: {
          'transaction_id': paymentData['id'],
          'amount': amount,
          'commission': commission,
          'net_amount': netAmount,
        },
      );
    } catch (e) {
      print("❌ Error processing cash payment: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process cash payment: ${e.toString()}",
      );
    }
  }

  /// ===== MOBILE MONEY PAYMENT FLOW =====
  
  /// Process Mobile Money payment with USSD push
  static Future<ApiResponse> processMobileMoneyPayment({
    required String orderId,
    required double amount,
    required String currency,
    required String phoneNumber,
    required String provider, // 'mtn', 'airtel'
    required String customerId,
    required String providerId,
    required String providerType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Calculate commission
      final commission = amount * _commissionRate;
      final netAmount = amount - commission;

      // Create payment record
      final paymentData = {
        'id': _generateTransactionId(),
        'order_id': orderId,
        'customer_id': customerId,
        'provider_id': providerId,
        'provider_type': providerType,
        'amount': amount,
        'currency': currency,
        'payment_method': 'mobile_money',
        'provider': provider,
        'phone_number': phoneNumber,
        'status': 'pending',
        'commission': commission,
        'processing_fee': _processingFee,
        'net_amount': netAmount,
        'settlement_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Save payment to Firestore
      final docRef = await _firestore.collection('payments').add(paymentData);

      // Send USSD push to customer's phone
      final ussdResult = await _sendUSSDPush(phoneNumber, amount, currency, provider);
      
      if (ussdResult['success']) {
        // Update payment status to processing
        await _firestore.collection('payments').doc(docRef.id).update({
          'status': 'processing',
          'external_reference': ussdResult['reference'],
          'updated_at': FieldValue.serverTimestamp(),
        });

        // Update order status
        await _updateOrderStatus(orderId, 'processing', 'mobile_money');

        return ApiResponse(
          code: 200,
          message: "USSD push sent to your phone. Please complete the payment.",
          body: {
            'transaction_id': paymentData['id'],
            'external_reference': ussdResult['reference'],
            'amount': amount,
            'phone_number': phoneNumber,
          },
        );
      } else {
        throw Exception(ussdResult['error'] ?? 'Failed to send USSD push');
      }
    } catch (e) {
      print("❌ Error processing Mobile Money payment: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process Mobile Money payment: ${e.toString()}",
      );
    }
  }

  /// ===== CARD PAYMENT FLOW =====
  
  /// Process Visa/Mastercard payment
  static Future<ApiResponse> processCardPayment({
    required String orderId,
    required double amount,
    required String currency,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
    required String customerId,
    required String providerId,
    required String providerType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Calculate commission
      final commission = amount * _commissionRate;
      final netAmount = amount - commission;

      // Create payment record
      final paymentData = {
        'id': _generateTransactionId(),
        'order_id': orderId,
        'customer_id': customerId,
        'provider_id': providerId,
        'provider_type': providerType,
        'amount': amount,
        'currency': currency,
        'payment_method': 'card',
        'card_number': _maskCardNumber(cardNumber),
        'cardholder_name': cardholderName,
        'status': 'pending',
        'commission': commission,
        'processing_fee': _processingFee,
        'net_amount': netAmount,
        'settlement_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Save payment to Firestore
      final docRef = await _firestore.collection('payments').add(paymentData);

      // Process card payment through gateway
      final cardResult = await _processCardThroughGateway({
        'card_number': cardNumber,
        'expiry_date': expiryDate,
        'cvv': cvv,
        'cardholder_name': cardholderName,
        'amount': amount,
        'currency': currency,
        'order_id': orderId,
      });

      if (cardResult['success']) {
        // Update payment status to completed
        await _firestore.collection('payments').doc(docRef.id).update({
          'status': 'completed',
          'external_reference': cardResult['reference'],
          'processed_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        // Update provider's commission
        await _updateProviderCommission(providerId, providerType, commission);

        // Update order status
        await _updateOrderStatus(orderId, 'paid', 'card');

        return ApiResponse(
          code: 200,
          message: "Card payment processed successfully",
          body: {
            'transaction_id': paymentData['id'],
            'external_reference': cardResult['reference'],
            'amount': amount,
            'commission': commission,
            'net_amount': netAmount,
          },
        );
      } else {
        // Update payment status to failed
        await _firestore.collection('payments').doc(docRef.id).update({
          'status': 'failed',
          'failure_reason': cardResult['error'],
          'failed_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        throw Exception(cardResult['error'] ?? 'Card payment failed');
      }
    } catch (e) {
      print("❌ Error processing card payment: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process card payment: ${e.toString()}",
      );
    }
  }

  /// ===== EVERSEND PAYMENT FLOW =====
  
  /// Process Eversend payment
  static Future<ApiResponse> processEversendPayment({
    required String orderId,
    required double amount,
    required String currency,
    required String phoneNumber,
    required String customerId,
    required String providerId,
    required String providerType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      // Calculate commission
      final commission = amount * _commissionRate;
      final netAmount = amount - commission;

      // Create payment record
      final paymentData = {
        'id': _generateTransactionId(),
        'order_id': orderId,
        'customer_id': customerId,
        'provider_id': providerId,
        'provider_type': providerType,
        'amount': amount,
        'currency': currency,
        'payment_method': 'eversend',
        'phone_number': phoneNumber,
        'status': 'pending',
        'commission': commission,
        'processing_fee': _processingFee,
        'net_amount': netAmount,
        'settlement_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Save payment to Firestore
      final docRef = await _firestore.collection('payments').add(paymentData);

      // Process Eversend payment
      final eversendResult = await _processEversendPayment({
        'amount': amount,
        'currency': currency,
        'phone_number': phoneNumber,
        'order_id': orderId,
      });

      if (eversendResult['success']) {
        // Update payment status to completed
        await _firestore.collection('payments').doc(docRef.id).update({
          'status': 'completed',
          'external_reference': eversendResult['reference'],
          'processed_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        // Update provider's commission
        await _updateProviderCommission(providerId, providerType, commission);

        // Update order status
        await _updateOrderStatus(orderId, 'paid', 'eversend');

        return ApiResponse(
          code: 200,
          message: "Eversend payment processed successfully",
          body: {
            'transaction_id': paymentData['id'],
            'external_reference': eversendResult['reference'],
            'amount': amount,
            'commission': commission,
            'net_amount': netAmount,
          },
        );
      } else {
        // Update payment status to failed
        await _firestore.collection('payments').doc(docRef.id).update({
          'status': 'failed',
          'failure_reason': eversendResult['error'],
          'failed_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        throw Exception(eversendResult['error'] ?? 'Eversend payment failed');
      }
    } catch (e) {
      print("❌ Error processing Eversend payment: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process Eversend payment: ${e.toString()}",
      );
    }
  }

  /// ===== PAYMENT STATUS AND CALLBACKS =====
  
  /// Check payment status
  static Future<ApiResponse> checkPaymentStatus(String transactionId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('id', isEqualTo: transactionId)
          .get();

      if (snapshot.docs.isEmpty) {
        return ApiResponse(code: 404, message: "Payment not found");
      }

      final payment = snapshot.docs.first.data();
      return ApiResponse(
        code: 200,
        message: "Payment status retrieved successfully",
        body: payment,
      );
    } catch (e) {
      print("❌ Error checking payment status: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to check payment status: ${e.toString()}",
      );
    }
  }

  /// Process payment callback (for gateway notifications)
  static Future<ApiResponse> processPaymentCallback({
    required String transactionId,
    required String status,
    required String externalReference,
    String? failureReason,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('id', isEqualTo: transactionId)
          .get();

      if (snapshot.docs.isEmpty) {
        return ApiResponse(code: 404, message: "Payment not found");
      }

      final docRef = snapshot.docs.first.reference;
      final payment = snapshot.docs.first.data();

      // Update payment status
      await docRef.update({
        'status': status,
        'external_reference': externalReference,
        'updated_at': FieldValue.serverTimestamp(),
        if (status == 'completed') 'processed_at': FieldValue.serverTimestamp(),
        if (status == 'failed') 'failed_at': FieldValue.serverTimestamp(),
        if (failureReason != null) 'failure_reason': failureReason,
      });

      // If payment completed, update provider commission and order status
      if (status == 'completed') {
        await _updateProviderCommission(
          payment['provider_id'],
          payment['provider_type'],
          payment['commission'],
        );
        await _updateOrderStatus(
          payment['order_id'],
          'paid',
          payment['payment_method'],
        );
      }

      return ApiResponse(
        code: 200,
        message: "Payment callback processed successfully",
      );
    } catch (e) {
      print("❌ Error processing payment callback: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process payment callback: ${e.toString()}",
      );
    }
  }

  /// ===== SETTLEMENT AND COMMISSION MANAGEMENT =====
  
  /// Get provider's outstanding commission
  static Future<ApiResponse> getProviderCommission(String providerId, String providerType) async {
    try {
      final snapshot = await _firestore
          .collection('provider_commissions')
          .where('provider_id', isEqualTo: providerId)
          .where('provider_type', isEqualTo: providerType)
          .where('status', isEqualTo: 'pending')
          .get();

      double totalCommission = 0;
      for (var doc in snapshot.docs) {
        totalCommission += doc.data()['amount'] ?? 0.0;
      }

      return ApiResponse(
        code: 200,
        message: "Commission retrieved successfully",
        body: {
          'provider_id': providerId,
          'provider_type': providerType,
          'outstanding_commission': totalCommission,
          'pending_payments': snapshot.docs.length,
        },
      );
    } catch (e) {
      print("❌ Error getting provider commission: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to get provider commission: ${e.toString()}",
      );
    }
  }

  /// Process settlement to provider
  static Future<ApiResponse> processSettlement({
    required String providerId,
    required String providerType,
    required String settlementMethod, // 'mobile_money', 'bank_transfer'
    required String accountDetails,
    required double amount,
  }) async {
    try {
      // Create settlement record
      final settlementData = {
        'id': _generateTransactionId(),
        'provider_id': providerId,
        'provider_type': providerType,
        'amount': amount,
        'settlement_method': settlementMethod,
        'account_details': accountDetails,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('settlements').add(settlementData);

      // Mark commission as settled
      await _firestore
          .collection('provider_commissions')
          .where('provider_id', isEqualTo: providerId)
          .where('provider_type', isEqualTo: providerType)
          .where('status', isEqualTo: 'pending')
          .get()
          .then((snapshot) async {
        for (var doc in snapshot.docs) {
          await doc.reference.update({
            'status': 'settled',
            'settlement_id': settlementData['id'],
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      });

      return ApiResponse(
        code: 200,
        message: "Settlement processed successfully",
        body: {
          'settlement_id': settlementData['id'],
          'amount': amount,
          'status': 'pending',
        },
      );
    } catch (e) {
      print("❌ Error processing settlement: $e");
      return ApiResponse(
        code: 500,
        message: "Failed to process settlement: ${e.toString()}",
      );
    }
  }

  /// ===== PRIVATE HELPER METHODS =====
  
  static String _generateTransactionId() {
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  static String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(DateTime.now().millisecondsSinceEpoch % chars.length)),
    );
  }

  static String _maskCardNumber(String cardNumber) {
    if (cardNumber.length < 8) return cardNumber;
    return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  static Future<void> _updateProviderCommission(String providerId, String providerType, double commission) async {
    await _firestore.collection('provider_commissions').add({
      'provider_id': providerId,
      'provider_type': providerType,
      'amount': commission,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> _updateOrderStatus(String orderId, String status, String paymentMethod) async {
    await _firestore.collection('orders').doc(orderId).update({
      'payment_status': status,
      'payment_method': paymentMethod,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>> _sendUSSDPush(String phoneNumber, double amount, String currency, String provider) async {
    // Simulate USSD push - in real implementation, integrate with gateway API
    await Future.delayed(Duration(seconds: 1));
    return {
      'success': true,
      'reference': 'ussd_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  static Future<Map<String, dynamic>> _processCardThroughGateway(Map<String, dynamic> cardData) async {
    // Simulate card processing - in real implementation, integrate with gateway API
    await Future.delayed(Duration(seconds: 2));
    return {
      'success': true,
      'reference': 'card_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  static Future<Map<String, dynamic>> _processEversendPayment(Map<String, dynamic> paymentData) async {
    try {
      // Get Eversend access token
      final tokenResponse = await http.post(
        Uri.parse('$_eversendBaseUrl/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client_id': _eversendClientId,
          'client_secret': _eversendClientSecret,
          'grant_type': 'client_credentials',
        }),
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception('Failed to get Eversend access token');
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      // Process payment
      final paymentResponse = await http.post(
        Uri.parse('$_eversendBaseUrl/payments/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'amount': paymentData['amount'],
          'currency': paymentData['currency'],
          'phone_number': paymentData['phone_number'],
          'description': 'Payment for order ${paymentData['order_id']}',
        }),
      );

      if (paymentResponse.statusCode == 200) {
        final responseData = jsonDecode(paymentResponse.body);
        return {
          'success': true,
          'reference': responseData['transaction_id'],
        };
      } else {
        final errorData = jsonDecode(paymentResponse.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Eversend payment failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
