import 'dart:convert';
import 'dart:developer';

import 'package:Classy/constants/api.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/models/service.dart';
import 'package:Classy/services/http.service.dart';
import 'package:Classy/services/location.service.dart';

class ServiceRequest extends HttpService {
  //
  Future<List<Service>> getServices({
    Map<String, dynamic>? queryParams,
    int? page = 1,
    bool byLocation = false,
    bool excludeUnusfulldata = true,
  }) async {
    Map<String, dynamic>? qParams = {
      ...(queryParams != null ? queryParams : {}),
      "page": "$page",
    };

    if (excludeUnusfulldata) {
      qParams["exclude"] = "category,photos,option_groups";
      qParams["exclude_attributes"] = "token";
      qParams["exclude_columns"] = "description";
    }

    //
    if (byLocation &&
        LocationService.currenctAddress?.coordinates?.latitude != null) {
      qParams["latitude"] =
          LocationService.currenctAddress?.coordinates?.latitude;
      qParams["longitude"] =
          LocationService.currenctAddress?.coordinates?.longitude;
    }

    final apiResult = await get(Api.services, queryParameters: qParams);

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Service> services = [];
      List<dynamic> serviceJsonList;
      if (page == null || page == 0) {
        serviceJsonList = (apiResponse.body as List);
      } else {
        serviceJsonList = apiResponse.data;
      }

      serviceJsonList.forEach((jsonObject) {
        try {
          services.add(Service.fromJson(jsonObject));
        } catch (error) {
          print("ServiceRequest getServices Error ==> $error");
          print("Service ID ==> ${jsonObject['id']}");
          log("service ==> ${jsonEncode(jsonObject)}");
        }
      });

      return services;
    }

    throw apiResponse.message!;
  }

  //
  Future<Service> serviceDetails(int id) async {
    //
    final apiResult = await get("${Api.services}/$id");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Service.fromJson(apiResponse.body, rawDescription: false);
    }

    throw apiResponse.message!;
  }
}
