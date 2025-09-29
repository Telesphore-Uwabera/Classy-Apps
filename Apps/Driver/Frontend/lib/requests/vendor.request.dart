import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/models/api_response.dart';

class VendorRequest extends HttpService {
  //
  Future<ApiResponse> getVendors({
    int? page,
    String? keyword,
    int? categoryId,
    double? latitude,
    double? longitude,
  }) async {
    final apiResult = await get(
      "/vendors",
      queryParameters: {
        "page": page,
        "keyword": keyword,
        "category_id": categoryId,
        "latitude": latitude,
        "longitude": longitude,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> getVendorDetails(int vendorId) async {
    final apiResult = await get("/vendors/$vendorId");
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> searchVendors(String keyword) async {
    final apiResult = await get(
      "/vendors/search",
      queryParameters: {"keyword": keyword},
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> vendorDetails(int vendorId) async {
    final apiResult = await get("/vendors/$vendorId");
    return ApiResponse.fromResponse(apiResult);
  }
}
