import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/models/api_response.dart';

class ServiceRequest extends HttpService {
  //
  Future<ApiResponse> getServices({
    int? page,
    String? keyword,
    int? vendorId,
    int? categoryId,
  }) async {
    final apiResult = await get(
      "/services",
      queryParameters: {
        "page": page,
        "keyword": keyword,
        "vendor_id": vendorId,
        "category_id": categoryId,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> getServiceDetails(int serviceId) async {
    final apiResult = await get("/services/$serviceId");
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> searchServices(String keyword) async {
    final apiResult = await get(
      "/services/search",
      queryParameters: {"keyword": keyword},
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> serviceDetails(int serviceId) async {
    final apiResult = await get("/services/$serviceId");
    return ApiResponse.fromResponse(apiResult);
  }
}
