import 'package:dio/dio.dart';
import 'constants/api.dart';
import 'models/api_response.dart';
import 'services/http.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class SettingsRequest extends HttpService {
  //
  Future<ApiResponse> appSettings() async {
    try {
      // Add timeout to prevent hanging
      final apiResult = await get(Api.appSettings).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioError(
            requestOptions: RequestOptions(path: Api.appSettings),
            type: DioErrorType.connectTimeout,
            error: "Connection timeout",
          );
        },
      );
      return ApiResponse.fromResponse(apiResult);
    } on DioError catch (error) {
      if (error.type == DioErrorType.connectTimeout || 
          error.type == DioErrorType.receiveTimeout ||
          error.type == DioErrorType.other) {
        // Return a response with null body to indicate backend is not available
        return ApiResponse(
          code: 0,
          message: "Backend not available",
          body: null,
          errors: ["Backend not available"],
        );
      }
      throw error;
    } catch (error) {
      // Return a response with null body for any other error
      return ApiResponse(
        code: 0,
        message: "Backend not available",
        body: null,
        errors: ["Backend not available"],
      );
    }
  }

  Future<ApiResponse> appOnboardings() async {
    try {
      final apiResult = await get(Api.appOnboardings);
      return ApiResponse.fromResponse(apiResult);
    } on DioError catch (error) {
      if (error.type == DioErrorType.other) {
        throw "Connection failed. Please check that your have internet connection on this device."
                .tr() +
            "\n" +
            "Try again later".tr();
      }
      throw error;
    } catch (error) {
      throw error;
    }
  }
}
