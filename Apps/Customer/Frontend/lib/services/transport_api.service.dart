import 'package:Classy/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Classy/services/auth.service.dart';

class TransportApiService {
  static final TransportApiService _instance = TransportApiService._internal();
  factory TransportApiService() => _instance;
  TransportApiService._internal();

  // Base URL pointing to customer-backend inter-app endpoints
  static const String _baseUrl = 'http://localhost:8000/api/inter-app';

  // Check transport availability (taxi/boda) in customer location with proximity search
  Future<ApiResponse> checkTransportAvailability({
    required double latitude,
    required double longitude,
    int? vehicleTypeId,
    double radius = 5.0, // Default 5km radius
  }) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      };
      
      if (vehicleTypeId != null) {
        queryParams['vehicle_type_id'] = vehicleTypeId.toString();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/transport/availability').replace(queryParameters: queryParams),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Transport availability checked',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to check transport availability',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to check transport availability: $e',
        body: null,
        errors: ['Failed to check transport availability: $e'],
      );
    }
  }

  // Get nearby drivers for pickup/delivery
  Future<ApiResponse> getNearbyDrivers({
    required double latitude,
    required double longitude,
    double radius = 3.0, // Default 3km for pickup/delivery
    int? vehicleTypeId,
    int limit = 10,
  }) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
      };
      
      if (vehicleTypeId != null) {
        queryParams['vehicle_type_id'] = vehicleTypeId.toString();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/drivers/nearby').replace(queryParameters: queryParams),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Nearby drivers fetched successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to fetch nearby drivers',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch nearby drivers: $e',
        body: null,
        errors: ['Failed to fetch nearby drivers: $e'],
      );
    }
  }

  // Calculate delivery fee based on distance and vendor
  Future<ApiResponse> calculateDeliveryFee({
    required int vendorId,
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
    int vehicleTypeId = 1, // Default to car
  }) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final body = {
        'vendor_id': vendorId,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'delivery_latitude': deliveryLatitude,
        'delivery_longitude': deliveryLongitude,
        'vehicle_type_id': vehicleTypeId,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/delivery/fee/calculate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Delivery fee calculated successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to calculate delivery fee',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to calculate delivery fee: $e',
        body: null,
        errors: ['Failed to calculate delivery fee: $e'],
      );
    }
  }

  // Find nearest driver with proximity search (100m, 500m, 1km, 2km, 3km, 5km)
  Future<ApiResponse> findNearestDriver({
    required double latitude,
    required double longitude,
    int? vehicleTypeId,
  }) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      // Define search radii in kilometers
      final searchRadii = [0.1, 0.5, 1.0, 2.0, 3.0, 5.0];
      
      for (double radius in searchRadii) {
        final queryParams = <String, String>{
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radius': radius.toString(),
        };
        
        if (vehicleTypeId != null) {
          queryParams['vehicle_type_id'] = vehicleTypeId.toString();
        }
        
        final response = await http.get(
          Uri.parse('$_baseUrl/transport/availability').replace(queryParameters: queryParams),
          headers: {'Authorization': 'Bearer $token'},
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final drivers = data['data']?['drivers'] ?? [];
          
          if (drivers.isNotEmpty) {
            // Found drivers within this radius
            return ApiResponse(
              code: 200,
              message: 'Found ${drivers.length} driver(s) within ${radius}km',
              body: {
                ...data,
                'search_radius': radius,
                'drivers_found': drivers.length,
              },
              errors: null,
            );
          }
        }
      }
      
      // No drivers found in any radius
      return ApiResponse(
        code: 404,
        message: 'No drivers available within 5km radius',
        body: {
          'drivers': [],
          'search_radius': 5.0,
          'drivers_found': 0,
        },
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to find nearest driver: $e',
        body: null,
        errors: ['Failed to find nearest driver: $e'],
      );
    }
  }

  // Book a taxi ride
  Future<ApiResponse> bookTaxi({
    required double pickupLatitude,
    required double pickupLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String pickupAddress,
    required String destinationAddress,
    int? vehicleTypeId,
    String? notes,
    String? paymentMethod,
  }) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final body = {
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'pickup_address': pickupAddress,
        'destination_address': destinationAddress,
        'vehicle_type_id': vehicleTypeId ?? 1,
        'notes': notes,
        'payment_method': paymentMethod ?? 'cash',
      };
      
      // Use the existing taxi booking endpoint
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/taxi/book/order'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: response.statusCode,
          message: data['message'] ?? 'Taxi booked successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to book taxi',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to book taxi: $e',
        body: null,
        errors: ['Failed to book taxi: $e'],
      );
    }
  }

  // Get current taxi order
  Future<ApiResponse> getCurrentTaxiOrder() async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/taxi/current/order'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Current taxi order fetched',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to get current taxi order',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to get current taxi order: $e',
        body: null,
        errors: ['Failed to get current taxi order: $e'],
      );
    }
  }

  // Cancel taxi order
  Future<ApiResponse> cancelTaxiOrder(int orderId) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/taxi/order/cancel/$orderId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Taxi order cancelled successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to cancel taxi order',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to cancel taxi order: $e',
        body: null,
        errors: ['Failed to cancel taxi order: $e'],
      );
    }
  }

  // Get vehicle types and pricing
  Future<ApiResponse> getVehicleTypes() async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/vehicle/types'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Vehicle types fetched successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to get vehicle types',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to get vehicle types: $e',
        body: null,
        errors: ['Failed to get vehicle types: $e'],
      );
    }
  }
}
