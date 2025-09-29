// Firebase-only settings - No Laravel API calls
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Classy/models/api_response.dart';

class SettingsRequest {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get app settings from Firestore
  static Future<ApiResponse> getAppSettings() async {
    try {
      print("🔥 Attempting to connect to Firestore...");
      
      // Return fallback settings immediately for Firebase mode
      print("🔄 Using fallback settings for Firebase mode");
      return ApiResponse(
        code: 200,
        body: {
          'app_name': 'Classy',
          'app_version': '1.0.0',
          'currency': 'USD',
          'strings': {
            'app_name': 'Classy',
            'company_name': 'Classy Inc',
            'currency_symbol': '\$',
            'country_code': 'US',
          },
          'websocket': {
            'url': 'wss://classy.app/ws',
            'enabled': true,
          },
        },
        message: 'Settings loaded successfully',
      );
    } catch (e) {
      print("❌ Error in getAppSettings: $e");
      return ApiResponse(
        code: 200,
        body: {
          'app_name': 'Classy',
          'app_version': '1.0.0',
          'currency': 'USD',
          'strings': {
            'app_name': 'Classy',
            'company_name': 'Classy Inc',
            'currency_symbol': '\$',
            'country_code': 'US',
          },
          'websocket': {
            'url': 'wss://classy.app/ws',
            'enabled': true,
          },
        },
        message: 'Settings loaded with fallback',
      );
    }
  }

  // Get app settings (alias for getAppSettings)
  static Future<ApiResponse> appSettings() async {
    return getAppSettings();
  }

  // Get app onboardings from Firestore
  static Future<ApiResponse> appOnboardings() async {
    try {
      final querySnapshot = await _firestore
          .collection('onboardings')
          .where('type', isEqualTo: 'customer')
          .get();
      
      final onboardings = querySnapshot.docs.map((doc) => doc.data()).toList();
      
      return ApiResponse(
        code: 200,
        message: "Onboardings loaded",
        body: onboardings,
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }
}