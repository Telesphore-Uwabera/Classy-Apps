import 'package:flutter/material.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';

class DeliveryHistoryService extends HttpService {
  static final DeliveryHistoryService _instance = DeliveryHistoryService._internal();
  factory DeliveryHistoryService() => _instance;
  DeliveryHistoryService._internal();

  // List to store delivery history (will be populated from API)
  List<Map<String, dynamic>> _deliveryHistory = [];

  // Get all delivery history
  List<Map<String, dynamic>> getDeliveryHistory() {
    return List.from(_deliveryHistory);
  }

  // Load delivery history from API
  Future<ApiResponse> loadDeliveryHistory() async {
    try {
      final response = await get(Api.deliveryHistory);
      final apiResponse = ApiResponse.fromResponse(response);
      if (apiResponse.allGood && apiResponse.body != null && apiResponse.body!['data'] != null) {
        _deliveryHistory = List<Map<String, dynamic>>.from(apiResponse.body!['data']);
      }
      return apiResponse;
    } catch (e) {
      print('Error loading delivery history: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Load ride history from API
  Future<ApiResponse> getRideHistory() async {
    try {
      final response = await get(Api.rideHistory);
      return ApiResponse.fromResponse(response);
    } catch (e) {
      print('Error loading ride history: $e');
      return ApiResponse.fromResponse(null);
    }
  }

  // Add new food delivery to history
  void addFoodDelivery({
    required String restaurantName,
    required String from,
    required String to,
    required String items,
    required String cost,
    String status = 'Pending',
  }) {
    final now = DateTime.now();
    final date = _formatDate(now);
    final time = _formatTime(now);
    
    final newDelivery = {
      'id': _deliveryHistory.length + 1,
      'type': 'Food Delivery',
      'icon': Icons.restaurant,
      'iconColor': Colors.pink,
      'date': date,
      'time': time,
      'status': status,
      'restaurant': restaurantName,
      'restaurantIcon': Icons.restaurant_menu,
      'from': from,
      'to': to,
      'items': items,
      'cost': cost,
    };

    _deliveryHistory.insert(0, newDelivery); // Add to beginning of list
  }

  // Add new package delivery to history
  void addPackageDelivery({
    required String from,
    required String to,
    required String items,
    required String cost,
    String status = 'Pending',
  }) {
    final now = DateTime.now();
    final date = _formatDate(now);
    final time = _formatTime(now);
    
    final newDelivery = {
      'id': _deliveryHistory.length + 1,
      'type': 'Package Delivery',
      'icon': Icons.local_shipping,
      'iconColor': Colors.pink,
      'date': date,
      'time': time,
      'status': status,
      'from': from,
      'to': to,
      'items': items,
      'cost': cost,
    };

    _deliveryHistory.insert(0, newDelivery); // Add to beginning of list
  }

  // Update delivery status
  void updateDeliveryStatus(int deliveryId, String newStatus) {
    final index = _deliveryHistory.indexWhere((delivery) => delivery['id'] == deliveryId);
    if (index != -1) {
      _deliveryHistory[index]['status'] = newStatus;
    }
  }

  // Get deliveries by type
  List<Map<String, dynamic>> getDeliveriesByType(String type) {
    return _deliveryHistory.where((delivery) => delivery['type'] == type).toList();
  }

  // Get food deliveries only
  List<Map<String, dynamic>> getFoodDeliveries() {
    return getDeliveriesByType('Food Delivery');
  }

  // Get package deliveries only
  List<Map<String, dynamic>> getPackageDeliveries() {
    return getDeliveriesByType('Package Delivery');
  }

  // Clear delivery history (for testing purposes)
  void clearHistory() {
    _deliveryHistory.clear();
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Format time for display
  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }
}
