import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/firebase_payment.service.dart';

class PaymentRequest {
  
  // ===== PAYMENT METHODS =====
  
  /// Get available payment methods (Eversend, MoMo, Card)
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final apiResponse = await FirebasePaymentService.getPaymentMethods();
      
      if (apiResponse.allGood && apiResponse.body != null) {
        return List<Map<String, dynamic>>.from(apiResponse.body);
      }
      
      throw apiResponse.message ?? "Failed to get payment methods";
    } catch (e) {
      // Fallback payment methods when Firebase is not available
      print('Firebase not available, using fallback payment methods');
      return [
        {
          'id': 'eversend',
          'name': 'Eversend',
          'type': 'eversend',
          'enabled': true,
          'icon': 'assets/images/eversend.png',
        },
        {
          'id': 'momo',
          'name': 'Mobile Money',
          'type': 'momo',
          'enabled': true,
          'icon': 'assets/images/momo.png',
        },
        {
          'id': 'card',
          'name': 'Card Payment',
          'type': 'card',
          'enabled': true,
          'icon': 'assets/images/card.png',
        },
      ];
    }
  }

  /// Process Eversend payment
  Future<ApiResponse> processEversendPayment({
    required String amount,
    required String currency,
    required String phoneNumber,
    required String orderId,
  }) async {
    try {
      return await FirebasePaymentService.processEversendPayment(
        amount: amount,
        currency: currency,
        phoneNumber: phoneNumber,
        orderId: orderId,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Eversend payment failed: ${e.toString()}",
        body: null,
      );
    }
  }

  /// Process Mobile Money payment
  Future<ApiResponse> processMomoPayment({
    required String amount,
    required String currency,
    required String phoneNumber,
    required String orderId,
    required String momoProvider, // MTN, Airtel, etc.
  }) async {
    try {
      return await FirebasePaymentService.processMomoPayment(
        amount: amount,
        currency: currency,
        phoneNumber: phoneNumber,
        orderId: orderId,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Mobile Money payment failed: ${e.toString()}",
        body: null,
      );
    }
  }

  /// Process Card payment
  Future<ApiResponse> processCardPayment({
    required String amount,
    required String currency,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
    required String orderId,
  }) async {
    try {
      return await FirebasePaymentService.processCardPayment(
        amount: amount,
        currency: currency,
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        cardholderName: cardholderName,
        orderId: orderId,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Card payment failed: ${e.toString()}",
        body: null,
      );
    }
  }

  /// Check payment status
  Future<ApiResponse> checkPaymentStatus(String transactionId) async {
    try {
      return await FirebasePaymentService.checkPaymentStatus(transactionId);
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Failed to check payment status: ${e.toString()}",
        body: null,
      );
    }
  }

  /// Process refund
  Future<ApiResponse> processRefund({
    required String transactionId,
    required String amount,
    required String reason,
  }) async {
    try {
      return await FirebasePaymentService.processRefund(
        transactionId: transactionId,
        amount: amount,
        reason: reason,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Refund failed: ${e.toString()}",
        body: null,
      );
    }
  }
}
