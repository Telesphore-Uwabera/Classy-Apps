import 'package:fuodz/models/api_response.dart';

class SettingsRequest {
  static Future<ApiResponse> appSettings() async {
    // Mock settings response
    return ApiResponse(
      code: 200,
      message: "Settings loaded successfully",
      body: {
        'app_name': 'Classy Driver',
        'app_version': '1.0.0',
        'currency': 'USD',
        'strings': {
          'app_name': 'Classy Driver',
          'company_name': 'Classy Inc',
          'currency_symbol': '\$',
          'country_code': 'US',
        },
        'colors': {
          'primaryColor': '#E91E63',
          'primaryColorDark': '#D81B60',
          'accentColor': '#E91E63',
        },
        'websocket': {
          'url': 'wss://classy.app/ws',
          'enabled': true,
        },
      },
    );
  }
}