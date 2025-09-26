import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/http.service.dart';

class PaymentApiService extends HttpService {
  // Get user's payment accounts
  Future<ApiResponse> getPaymentAccounts() async {
    try {
      final response = await get(Api.paymentAccounts);
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error getting payment accounts: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Add new payment account
  Future<ApiResponse> addPaymentAccount({
    required String name,
    required String number,
    String? instructions,
    bool isActive = true,
  }) async {
    try {
      final response = await post(Api.paymentAccounts, {
        'name': name,
        'number': number,
        'instructions': instructions,
        'is_active': isActive ? 1 : 0,
      });
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error adding payment account: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Update payment account
  Future<ApiResponse> updatePaymentAccount({
    required String accountId,
    required String name,
    required String number,
    String? instructions,
    bool isActive = true,
  }) async {
    try {
      final response = await put('${Api.paymentAccounts}/$accountId', {
        'name': name,
        'number': number,
        'instructions': instructions,
        'is_active': isActive ? 1 : 0,
      });
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error updating payment account: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Delete payment account
  Future<ApiResponse> deletePaymentAccount(String accountId) async {
    try {
      final response = await delete('${Api.paymentAccounts}/$accountId');
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error deleting payment account: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Get available payment methods
  Future<ApiResponse> getPaymentMethods({
    String? vendorId,
    bool forWallet = false,
    bool forPickup = false,
    bool useTaxi = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (vendorId != null) queryParams['vendor_id'] = vendorId;
      if (forWallet) queryParams['for_wallet'] = '1';
      if (forPickup) queryParams['is_pickup'] = '1';
      if (useTaxi) queryParams['use_taxi'] = '1';

      final response = await get(Api.paymentMethods, queryParameters: queryParams);
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error getting payment methods: $e');
      return ApiResponse.fromResponse(null);
    }
  }
}
