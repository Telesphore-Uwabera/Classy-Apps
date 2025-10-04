import 'package:flutter/material.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/constants/api.dart';

class FoodCategoriesApiService extends HttpService {
  static final FoodCategoriesApiService _instance = FoodCategoriesApiService._internal();
  factory FoodCategoriesApiService() => _instance;
  FoodCategoriesApiService._internal();

  // Get all food categories with smart logic
  Future<ApiResponse> getCategories() async {
    try {
      // Try to get categories from backend API first
      final response = await get(Api.foodCategories);
      
      if (response.statusCode == 200 && response.data != null) {
        // Transform backend data to frontend format
        final categories = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
        final transformedCategories = categories.map((category) => {
          'id': category['id'],
          'name': category['name'] ?? 'Unknown Category',
          'icon': _getCategoryIcon(category['name']),
          'color': _getCategoryColor(category['name']),
          'image': category['image'] ?? 'assets/images/product.png',
          'description': category['description'] ?? '',
          'isActive': category['is_active'] == 1,
          'itemCount': category['item_count'] ?? 0,
        }).toList();
        
        return ApiResponse(
          code: 200,
          message: "Categories retrieved successfully",
          body: {'data': transformedCategories},
        );
      } else {
        // Fallback to default categories if API fails
        return ApiResponse(
          code: 200,
          message: "Using default categories",
          body: {'data': _getDefaultCategories()},
        );
      }
    } catch (e) {
      print('Error getting food categories: $e');
      // Return default categories as fallback
      return ApiResponse(
        code: 200,
        message: "Using default categories",
        body: {'data': _getDefaultCategories()},
      );
    }
  }
  
  // Get category icon based on name
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('burger')) return Icons.lunch_dining;
    if (name.contains('pizza')) return Icons.local_pizza;
    if (name.contains('salad')) return Icons.eco;
    if (name.contains('sushi')) return Icons.set_meal;
    if (name.contains('chicken')) return Icons.restaurant;
    if (name.contains('seafood')) return Icons.set_meal;
    if (name.contains('dessert')) return Icons.cake;
    if (name.contains('beverage') || name.contains('drink')) return Icons.local_drink;
    if (name.contains('fast')) return Icons.fastfood;
    if (name.contains('healthy')) return Icons.favorite;
    if (name.contains('asian')) return Icons.ramen_dining;
    if (name.contains('italian')) return Icons.restaurant;
    if (name.contains('mexican')) return Icons.local_fire_department;
    if (name.contains('indian')) return Icons.spa;
    if (name.contains('african')) return Icons.public;
    if (name.contains('breakfast')) return Icons.free_breakfast;
    if (name.contains('lunch')) return Icons.lunch_dining;
    if (name.contains('dinner')) return Icons.dinner_dining;
    return Icons.restaurant; // Default icon
  }
  
  // Get category color based on name
  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('burger')) return Colors.orange;
    if (name.contains('pizza')) return Colors.red;
    if (name.contains('salad')) return Colors.green;
    if (name.contains('sushi')) return Colors.blue;
    if (name.contains('chicken')) return Colors.brown;
    if (name.contains('seafood')) return Colors.cyan;
    if (name.contains('dessert')) return Colors.pink;
    if (name.contains('beverage') || name.contains('drink')) return Colors.purple;
    if (name.contains('fast')) return Colors.amber;
    if (name.contains('healthy')) return Colors.lightGreen;
    if (name.contains('asian')) return Colors.deepOrange;
    if (name.contains('italian')) return Colors.green;
    if (name.contains('mexican')) return Colors.red;
    if (name.contains('indian')) return Colors.orange;
    if (name.contains('african')) return Colors.brown;
    if (name.contains('breakfast')) return Colors.yellow;
    if (name.contains('lunch')) return Colors.blue;
    if (name.contains('dinner')) return Colors.indigo;
    return Colors.grey; // Default color
  }
  
  // Default categories fallback
  List<Map<String, dynamic>> _getDefaultCategories() {
    return [
      {
        'id': '1',
        'name': 'Burger',
        'icon': Icons.lunch_dining,
        'color': Colors.orange,
        'image': 'assets/images/product.png',
        'description': 'Juicy burgers and sandwiches',
        'isActive': true,
        'itemCount': 0,
      },
      {
        'id': '2',
        'name': 'Pizza',
        'icon': Icons.local_pizza,
        'color': Colors.red,
        'image': 'assets/images/product.png',
        'description': 'Fresh pizzas and Italian dishes',
        'isActive': true,
        'itemCount': 0,
      },
      {
        'id': '3',
        'name': 'Salad',
        'icon': Icons.eco,
        'color': Colors.green,
        'image': 'assets/images/product.png',
        'description': 'Fresh and healthy salads',
        'isActive': true,
        'itemCount': 0,
      },
      {
        'id': '4',
        'name': 'Sushi',
        'icon': Icons.set_meal,
        'color': Colors.blue,
        'image': 'assets/images/product.png',
        'description': 'Fresh sushi and Japanese cuisine',
        'isActive': true,
        'itemCount': 0,
      },
      {
        'id': '5',
        'name': 'Chicken',
        'icon': Icons.restaurant,
        'color': Colors.brown,
        'image': 'assets/images/product.png',
        'description': 'Grilled and fried chicken dishes',
        'isActive': true,
        'itemCount': 0,
      },
      {
        'id': '6',
        'name': 'Seafood',
        'icon': Icons.set_meal,
        'color': Colors.cyan,
        'image': 'assets/images/product.png',
        'description': 'Fresh seafood and fish dishes',
        'isActive': true,
        'itemCount': 0,
      },
      {
        'id': '7',
        'name': 'Desserts',
        'icon': Icons.cake,
        'color': Colors.pink,
        'image': 'assets/images/product.png',
        'description': 'Sweet treats and desserts',
        'isActive': true,
        'itemCount': 0,
      },
      {
        'id': '8',
        'name': 'Beverages',
        'icon': Icons.local_drink,
        'color': Colors.purple,
        'image': 'assets/images/product.png',
        'description': 'Drinks and beverages',
        'isActive': true,
        'itemCount': 0,
      },
    ];
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
