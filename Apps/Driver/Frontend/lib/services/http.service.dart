import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/constants/app_strings.dart';

class HttpService {
  static Dio? _dio;
  
  static Dio get dio {
    if (_dio == null) {
      _dio = Dio();
      _dio!.options.baseUrl = Api.baseUrl;
      _dio!.options.connectTimeout = Duration(seconds: 30);
      _dio!.options.receiveTimeout = Duration(seconds: 30);
      _dio!.options.sendTimeout = Duration(seconds: 30);
      
      // Add interceptors
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = LocalStorageService.getString(AppStrings.userToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ));
    }
    return _dio!;
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }
  
  static Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }
  
  static Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.put(path, data: data, queryParameters: queryParameters);
  }
  
  static Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.delete(path, queryParameters: queryParameters);
  }
}