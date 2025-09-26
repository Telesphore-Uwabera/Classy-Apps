import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/http.service.dart';

class PaymentRequest extends HttpService {
  
  // ===== PAYMENT METHODS =====
  
  /// Get available payment methods (Eversend, MoMo, Card)
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final apiResult = await get(Api.paymentMethods);
      final apiResponse = ApiResponse.fromResponse(apiResult);
      
      if (apiResponse.allGood) {
        return List<Map<String, dynamic>>.from(apiResponse.body);
      }
      
      throw apiResponse.message ?? "Failed to get payment methods";
    } catch (e) {
      // Fallback payment methods when API is not available
      print('API not available, using fallback payment methods');
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
      final params = {
        'amount': amount,
        'currency': currency,
        'phone_number': phoneNumber,
        'order_id': orderId,
        'payment_method': 'eversend',
      };

      final apiResult = await post(Api.eversendPayment, params);
      return ApiResponse.fromResponse(apiResult);
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
      final params = {
        'amount': amount,
        'currency': currency,
        'phone_number': phoneNumber,
        'order_id': orderId,
        'payment_method': 'momo',
        'momo_provider': momoProvider,
      };

      final apiResult = await post(Api.momoPayment, params);
      return ApiResponse.fromResponse(apiResult);
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
      final params = {
        'amount': amount,
        'currency': currency,
        'card_number': cardNumber,
        'expiry_date': expiryDate,
        'cvv': cvv,
        'cardholder_name': cardholderName,
        'order_id': orderId,
        'payment_method': 'card',
      };

      final apiResult = await post(Api.cardPayment, params);
      return ApiResponse.fromResponse(apiResult);
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
      final apiResult = await get('${Api.paymentStatus}/$transactionId');
      return ApiResponse.fromResponse(apiResult);
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
      final params = {
        'transaction_id': transactionId,
        'amount': amount,
        'reason': reason,
      };

      final apiResult = await post(Api.refundPayment, params);
      return ApiResponse.fromResponse(apiResult);
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: "Refund failed: ${e.toString()}",
        body: null,
      );
    }
  }
}
