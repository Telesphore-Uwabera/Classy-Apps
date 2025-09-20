import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/models/wallet.dart';
import 'package:Classy/models/wallet_transaction.dart';
import 'package:Classy/services/http.service.dart';

class WalletRequest extends HttpService {
  //
  Future<Wallet> walletBalance() async {
    // For Firebase-only mode, return mock wallet data
    // TODO: Implement Firebase-based wallet functionality
    return Wallet(
      balance: 0.0,
      updatedAt: DateTime.now(),
    );
  }

  Future<dynamic> walletTopup(String amount, {int? paymentMethodId}) async {
    Map<String, dynamic> params = {
      "amount": amount,
    };

    if (paymentMethodId != null) {
      params.addAll({
        "payment_method_id": paymentMethodId,
      });
    }

    final apiResult = await post(
      Api.walletTopUp,
      params,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      //
      if (paymentMethodId != null) {
        return apiResponse;
      }
      //
      return apiResponse.body["link"];
    }

    throw apiResponse.message!;
  }

  Future<List<WalletTransaction>> walletTransactions({int page = 1}) async {
    final apiResult = await get(
      Api.walletTransactions,
      queryParameters: {"page": page.toString()},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    
    if (apiResponse.allGood) {
      final List<dynamic> transactionsData = apiResponse.body["data"] ?? [];
      return transactionsData.map((e) => WalletTransaction.fromJson(e)).toList();
    }
    
    throw apiResponse.message ?? "Failed to get wallet transactions";
  }

  Future<ApiResponse> myWalletAddress() async {
    final apiResult = await get(Api.myWalletAddress);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> getWalletAddress(String keyword) async {
    final apiResult = await get(
      Api.walletAddressesSearch,
      queryParameters: {
        "keyword": keyword,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> transferWallet(
    String amount,
    String walletAddress,
    String password,
  ) async {
    final apiResult = await post(
      Api.walletTransfer,
      {
        "wallet_address": walletAddress,
        "amount": amount,
        "password": password,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }
}
