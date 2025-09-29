import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/models/api_response.dart';

class FirebaseTokenService extends HttpService {
  //
  Future<String?> getFirebaseToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      print("Error getting Firebase token: $e");
      return null;
    }
  }

  //
  Future<ApiResponse> updateFirebaseToken(String token) async {
    final apiResult = await post(
      "/driver/firebase/token",
      {
        "token": token,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<void> refreshFirebaseToken() async {
    try {
      final token = await getFirebaseToken();
      if (token != null) {
        await updateFirebaseToken(token);
      }
    } catch (e) {
      print("Error refreshing Firebase token: $e");
    }
  }

  //
  Future<void> handleDeviceTokenSync() async {
    await refreshFirebaseToken();
  }
}
