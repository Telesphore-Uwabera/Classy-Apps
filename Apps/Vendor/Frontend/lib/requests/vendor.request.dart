import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/http.service.dart';

class VendorRequest extends HttpService {
  //
  Future<Vendor> getVendorDetails() async {
    final apiResult = await get(Api.vendor);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Vendor.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<Map<String, dynamic>> getVendorStats() async {
    final apiResult = await get(Api.vendor + "/stats");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.body;
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    final apiResult = await get(Api.vendor + "/activities");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return List<Map<String, dynamic>>.from(apiResponse.data);
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<ApiResponse> updateVendorProfile(Map<String, dynamic> data) async {
    final apiResult = await post(Api.vendor, data);
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<List<Vendor>> myVendors() async {
    final apiResult = await get(Api.myVendors);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return Vendor.fromJson(jsonObject);
      }).toList();
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<ApiResponse> switchVendor(Vendor vendor) async {
    final apiResult = await post(Api.switchVendor, {"vendor_id": vendor.id});
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<Map<String, dynamic>> getSalesReport(Map<String, dynamic> params) async {
    final apiResult = await get(Api.salesReport, queryParameters: params);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.body;
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<Map<String, dynamic>> getEarningsReport(Map<String, dynamic> params) async {
    final apiResult = await get(Api.earningsReport, queryParameters: params);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.body;
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<ApiResponse> toggleVendorAvailablity(Vendor vendor) async {
    final apiResult = await post(Api.vendorAvailability.replaceAll("id", vendor.id.toString()), {});
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> submitDocumentsRequest(Map<String, dynamic> data) async {
    final apiResult = await post(Api.documentSubmission, data);
    return ApiResponse.fromResponse(apiResult);
  }
}