import 'package:Classy/models/api_response.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/constants/api.dart';

class CartApiService extends HttpService {
  static final CartApiService _instance = CartApiService._internal();
  factory CartApiService() => _instance;
  CartApiService._internal();

  // Get cart items
  Future<ApiResponse> getCartItems() async {
    try {
      final response = await get(Api.cart);
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error getting cart items: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Add item to cart
  Future<ApiResponse> addToCart({
    required String foodId,
    required int quantity,
    String? variation,
    String? specialInstructions,
  }) async {
    try {
      final response = await post(Api.cart, {
        'food_id': foodId,
        'quantity': quantity,
        'variation': variation,
        'special_instructions': specialInstructions,
      });
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error adding to cart: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Update cart item quantity
  Future<ApiResponse> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await post('${Api.cart}/$cartItemId/update', {
        'quantity': quantity,
      });
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error updating cart item: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Remove item from cart
  Future<ApiResponse> removeFromCart(String cartItemId) async {
    try {
      final response = await post('${Api.cart}/$cartItemId/remove', {});
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error removing from cart: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Clear entire cart
  Future<ApiResponse> clearCart() async {
    try {
      final response = await post('${Api.cart}/clear', {});
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error clearing cart: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Get cart summary (total, item count, etc.)
  Future<ApiResponse> getCartSummary() async {
    try {
      final response = await get('${Api.cart}/summary');
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error getting cart summary: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Place order
  Future<ApiResponse> placeOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required String deliveryTime,
    required String paymentMethod,
    required double subtotal,
    required double deliveryFee,
    required double serviceFee,
    required double discount,
    required double total,
  }) async {
    try {
      final response = await post(Api.placeOrder, {
        'items': items,
        'delivery_address': deliveryAddress,
        'delivery_time': deliveryTime,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'service_fee': serviceFee,
        'discount': discount,
        'total': total,
        'order_date': DateTime.now().toIso8601String(),
      });
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error placing order: $e');
      return ApiResponse.fromResponse(null);
    }
  }
}
