import 'package:Classy/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Classy/services/auth.service.dart';

class FoodApiService {
  static final FoodApiService _instance = FoodApiService._internal();
  factory FoodApiService() => _instance;
  FoodApiService._internal();

  // Base URL pointing to Node.js API
  static const String _baseUrl = 'http://localhost:8000/api';

  // Get list of food vendors
  Future<ApiResponse> getVendors({
    int page = 1,
    int limit = 20,
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      
      // Use inter-app endpoint to get vendors from Vendor App
      final response = await http.get(
        Uri.parse('$_baseUrl/inter-app/vendors/available').replace(queryParameters: queryParams),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Vendors fetched successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to fetch vendors',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch vendors: $e',
        body: null,
        errors: ['Failed to fetch vendors: $e'],
      );
    }
  }

  // Get vendor details and menu
  Future<ApiResponse> getVendorMenu(int vendorId) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      // Use inter-app endpoint to get vendor menu from Vendor App
      final response = await http.get(
        Uri.parse('$_baseUrl/inter-app/vendors/$vendorId/menu'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Menu fetched successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to fetch menu',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch menu: $e',
        body: null,
        errors: ['Failed to fetch menu: $e'],
      );
    }
  }

  // Search food items across all vendors
  Future<ApiResponse> searchFood(String query, {
    int? vendorId,
    String? category,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      // Build query parameters
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (vendorId != null) queryParams['vendor_id'] = vendorId.toString();
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      
      // Use inter-app endpoint to search across Vendor App data
      final response = await http.get(
        Uri.parse('$_baseUrl/inter-app/search/vendor-items').replace(queryParameters: queryParams),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Search completed successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Search failed',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Search failed: $e',
        body: null,
        errors: ['Search failed: $e'],
      );
    }
  }

  // Place food order
  Future<ApiResponse> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: response.statusCode,
          message: data['message'] ?? 'Order placed successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to place order',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to place order: $e',
        body: null,
        errors: ['Failed to place order: $e'],
      );
    }
  }

  // Get order status
  Future<ApiResponse> getOrderStatus(String orderId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/orders/$orderId/status'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // For now, return mock data structure
      await Future.delayed(Duration(milliseconds: 300)); // Simulate API delay
      
      return ApiResponse(
        message: 'Order status fetched successfully',
        body: {
          'data': {
            'order_id': orderId,
            'status': 'preparing',
            'estimated_delivery': DateTime.now().add(Duration(minutes: 25)).toIso8601String(),
            'current_step': 'restaurant_preparing',
            'step_description': 'Restaurant is preparing your order',
          }
        },
      );
    } catch (e) {
      return ApiResponse(
        message: 'Failed to fetch order status: $e',
        body: null,
        errors: ['Failed to fetch order status: $e'],
      );
    }
  }
}
