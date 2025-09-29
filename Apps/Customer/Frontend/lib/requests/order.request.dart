import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/models/order.dart';
import 'package:Classy/services/http.service.dart';

class OrderRequest extends HttpService {
  //
  Future<List<Order>> getOrders({
    int page = 1,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = <String, String>{
      "page": page.toString(),
    };
    
    if (params != null) {
      params.forEach((key, value) {
        if (value != null) queryParams[key] = value.toString();
      });
    }
    
    final apiResult = await get(
      Api.orders,
      queryParameters: queryParams,
    );
    
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      final List<dynamic> ordersData = apiResponse.body["data"] ?? [];
      return ordersData.map((e) => Order.fromJson(e)).toList();
    } else {
      throw apiResponse.message ?? "Failed to get orders";
    }
  }

  //
  Future<Order> getOrderDetails({required int id}) async {
    final apiResult = await get(Api.orders + "/$id");
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }

  //
  Future<String> updateOrder({int? id, String? status, String? reason}) async {
    final apiResult = await patch(Api.orders + "/$id", {
      "status": status,
      "reason": reason,
    });
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.message!;
    } else {
      throw apiResponse.message!;
    }
  }

  //
  Future<Order> trackOrder(String code, {int? vendorTypeId}) async {
    //
    final apiResult = await post(Api.trackOrder, {
      "code": code,
      "vendor_type_id": vendorTypeId,
    });
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }

  Future<ApiResponse> updateOrderPaymentMethod({
    int? id,
    int? paymentMethodId,
    String? status,
  }) async {
    //
    final apiResult = await patch(Api.orders + "/$id", {
      "payment_method_id": paymentMethodId,
      "payment_status": status,
    });
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<String>> orderCancellationReasons({Order? order}) async {
    //
    final apiResult = await get(
      Api.cancellationReasons,
      queryParameters: {"type": (order?.isTaxi ?? false) ? "taxi" : "order"},
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List).map((e) {
        return e['reason'].toString();
      }).toList();
    } else {
      throw apiResponse.message!;
    }
  }

  //
  Future<ApiResponse> syncDriverLocation(int orderId) async {
    //
    String url = Api.syncDriverLocation;
    url = url.replaceAll("{order}", "$orderId");
    final apiResult = await post(url, {});
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message!;
    }
  }
}
