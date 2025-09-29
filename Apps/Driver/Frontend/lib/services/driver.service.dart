import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/services/http.service.dart';

class DriverService {
  static final HttpService _httpService = HttpService();

  static Future<ApiResponse> updateDriverStatus({
    required bool isOnline,
    required bool isAvailable,
  }) async {
    try {
      final response = await _httpService.post(
        Api.updateDriverStatus,
        {
          'is_online': isOnline,
          'is_available': isAvailable,
        },
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return _createErrorResponse(e);
    }
  }

  static Future<ApiResponse> getAvailableDrivers({
    required String serviceType,
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final response = await _httpService.get(
        '${Api.getAvailableDrivers}?service_type=$serviceType&latitude=$latitude&longitude=$longitude&radius=$radius',
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return _createErrorResponse(e);
    }
  }

  static Future<ApiResponse> acceptRideRequest({
    required String requestId,
  }) async {
    try {
      final response = await _httpService.post(
        Api.acceptRideRequest,
        {
          'request_id': requestId,
        },
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return _createErrorResponse(e);
    }
  }

  static Future<ApiResponse> rejectRideRequest({
    required String requestId,
  }) async {
    try {
      final response = await _httpService.post(
        Api.rejectRideRequest,
        {
          'request_id': requestId,
        },
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return _createErrorResponse(e);
    }
  }

  static Future<ApiResponse> completeRide({
    required String requestId,
    required double finalAmount,
  }) async {
    try {
      final response = await _httpService.post(
        Api.completeRide,
        {
          'request_id': requestId,
          'final_amount': finalAmount,
        },
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return _createErrorResponse(e);
    }
  }

  static ApiResponse _createErrorResponse(dynamic error) {
    return ApiResponse(
      code: 500,
      message: error.toString(),
      body: null,
      errors: [error.toString()],
    );
  }
}
