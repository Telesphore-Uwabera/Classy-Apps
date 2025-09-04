import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/models/api_response.dart';

class ProductRequest extends HttpService {
  //
  Future<ApiResponse> getProducts({
    int? page,
    String? keyword,
    int? vendorId,
    int? categoryId,
  }) async {
    final apiResult = await get(
      "/products",
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
  Future<ApiResponse> getProductDetails(int productId) async {
    final apiResult = await get("/products/$productId");
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> searchProducts(String keyword) async {
    final apiResult = await get(
      "/products/search",
      queryParameters: {"keyword": keyword},
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> productDetails(int productId) async {
    final apiResult = await get("/products/$productId");
    return ApiResponse.fromResponse(apiResult);
  }
}
