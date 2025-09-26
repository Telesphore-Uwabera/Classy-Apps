import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/services/http.service.dart';

class AuthRequest extends HttpService {
  //
  Future<ApiResponse> loginRequest({
    required String phone,
    required String password,
  }) async {
    final apiResult = await HttpService.post(Api.login, data: {
      "phone": phone,
      "password": password,
      "role": "driver",
    });

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> registerRequest({
    required Map<String, dynamic> vals,
    List<File>? docs,
  }) async {
    try {
      print("AuthRequest.registerRequest called with vals: $vals");
      final postBody = {...vals};

      FormData formData = FormData.fromMap(postBody);
      if ((docs ?? []).isNotEmpty) {
        for (File file in docs!) {
          formData.files.addAll([
            MapEntry("documents[]", await MultipartFile.fromFile(file.path)),
          ]);
        }
      }

      print("Making request to: ${Api.driverRegister}");
      final apiResult = await HttpService.post(
        Api.driverRegister,
        data: formData,
      );
      
      print("Raw API result: ${apiResult.data}");
      print("API result status code: ${apiResult.statusCode}");
      
      final response = ApiResponse.fromResponse(apiResult);
      print("Parsed ApiResponse: $response");
      
      return response;
    } catch (e) {
      print("Registration error: $e");
      print("Registration error stack trace: ${e.toString()}");
      return ApiResponse(
        code: 500,
        message: e.toString(),
        body: null,
        errors: [e.toString()],
      );
    }
  }

  Future<ApiResponse> verifyFirebaseToken(
    String phoneNumber,
    String firebaseVerificationId,
  ) async {
    //
    final apiResult = await HttpService.post(Api.verifyFirebaseOtp, data: {
      "phone": phoneNumber,
      "firebase_id_token": firebaseVerificationId,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  //
  Future<ApiResponse> qrLoginRequest({required String code}) async {
    final apiResult = await HttpService.post(Api.qrlogin, data: {"code": code, "role": "driver"});

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> resetPasswordRequest({
    required String phone,
    required String password,
    String? firebaseToken,
    String? customToken,
  }) async {
    final apiResult = await HttpService.post(Api.forgotPassword, data: {
      "phone": phone,
      "password": password,
      "firebase_id_token": firebaseToken,
      "verification_token": customToken,
    });

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> logoutRequest() async {
    final apiResult = await HttpService.get(Api.logout);
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> updateOnlineStatus({required bool isOnline}) async {
    final apiResult = await HttpService.post(Api.updateProfile, data: {
      "_method": "PUT",
      "is_online": isOnline ? 1 : 0,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateProfile({
    File? photo,
    String? name,
    String? email,
    String? phone,
  }) async {
    final apiResult = await HttpService.post(Api.updateProfile, data: {
      "_method": "PUT",
      "name": name,
      "email": email,
      "phone": phone,

      "photo": photo != null ? await MultipartFile.fromFile(photo.path) : null,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updatePassword({
    required String password,
    required String new_password,
    required String new_password_confirmation,
  }) async {
    final apiResult = await HttpService.post(Api.updatePassword, data: {
      "_method": "PUT",
      "password": password,
      "new_password": new_password,
      "new_password_confirmation": new_password_confirmation,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> verifyPhoneAccount(String phone) async {
    final apiResult = await HttpService.get(
      Api.verifyPhoneAccount,
      queryParameters: {"phone": phone},
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> sendOTP(
    String phoneNumber, {
    bool isLogin = false,
  }) async {
    final apiResult = await HttpService.post(Api.sendOtp, data: {
      "phone": phoneNumber,
      "is_login": isLogin,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> verifyOTP(
    String phoneNumber,
    String code, {
    bool isLogin = false,
  }) async {
    final apiResult = await HttpService.post(Api.verifyOtp, data: {
      "phone": phoneNumber,
      "code": code,
      "is_login": isLogin,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<User> getMyDetails() async {
    //
    final apiResult = await HttpService.get(Api.myProfile);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return User.fromJson(apiResponse.body);
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> deleteProfile({
    required String password,
    String? reason,
  }) async {
    final apiResult = await HttpService.post(Api.accountDelete, data: {
      "_method": "DELETE",
      "password": password,
      "reason": reason,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> submitDocumentsRequest({required List<File> docs}) async {
    FormData formData = FormData.fromMap({});
    for (File file in docs) {
      formData.files.addAll([
        MapEntry("documents[]", await MultipartFile.fromFile(file.path)),
      ]);
    }

    final apiResult = await HttpService.post(
      Api.documentSubmission,
      data: formData,
    );
    return ApiResponse.fromResponse(apiResult);
  }

  // CSRF token handling removed - using Firebase authentication
}
