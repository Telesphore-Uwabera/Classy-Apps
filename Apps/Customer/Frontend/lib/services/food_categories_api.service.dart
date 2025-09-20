import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/constants/api.dart';

class FoodCategoriesApiService extends HttpService {
  static final FoodCategoriesApiService _instance = FoodCategoriesApiService._internal();
  factory FoodCategoriesApiService() => _instance;
  FoodCategoriesApiService._internal();

  // Get all food categories
  Future<ApiResponse> getCategories() async {
    try {
      final response = await get(Api.foodCategories);
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error getting food categories: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Get category items
  Future<ApiResponse> getCategoryItems({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      
      final response = await get('${Api.foodCategories}/$categoryId/items', queryParameters: queryParams);
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error getting category items: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Get top picks/favorites
  Future<ApiResponse> getTopPicks({
    String? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (filter != null && filter != 'All') {
        queryParams['filter'] = filter.toLowerCase();
      }
      
      final response = await get(Api.topPicks, queryParameters: queryParams);
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error getting top picks: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Search food items
  Future<ApiResponse> searchFood({
    required String query,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      
      final response = await get(Api.foodSearch, queryParameters: queryParams);
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error searching food: $e');
      return ApiResponse.fromResponse(null);
    }
  }
}
