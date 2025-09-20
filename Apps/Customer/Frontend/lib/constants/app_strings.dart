import 'dart:convert';

import 'package:Classy/services/local_storage.service.dart';
import 'package:supercharged/supercharged.dart';

class AppStrings {
  //
  static String get appName => env('app_name');
  static String get companyName => env('company_name');
  // 🔐 SECURITY: Google Maps API key should be stored securely
  // For production, use --dart-define or environment variables
  static String get googleMapApiKey => const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: 'your-google-maps-api-key-here');
  static String get fcmApiKey => env('fcm_key');
  static String get currencySymbol => env('currency');
  static String get countryCode => env('country_code');
  static bool get enableOtp => env('enble_otp') == "1";
  static bool get enableOTPLogin => env('enableOTPLogin') == "1";

  //
  static bool get enableEmailLogin => env('enableEmailLogin');
  static bool get enableProfileUpdate => env('enableProfileUpdate');

  static bool get enableGoogleDistance => env('enableGoogleDistance') == "1";
  static bool get enableSingleVendor => env('enableSingleVendor') == "1";
  static bool get enableMultipleVendorOrder =>
      env('enableMultipleVendorOrder') ?? false;
  static bool get enableReferSystem => false; // Simplified - no referral system
  static String get referAmount => "0"; // Removed referral complexity
  static bool get enableChat => false; // Simplified - basic notifications only
  static bool get enableOrderTracking => env('enableOrderTracking') == "1";
  static bool get enableFatchByLocation => env('enableFatchByLocation') ?? true;
  static bool get showVendorTypeImageOnly =>
      env('showVendorTypeImageOnly') == "1";
  static bool get enableUploadPrescription =>
      env('enableUploadPrescription') == "1";
  static bool get enableParcelVendorByLocation =>
      env('enableParcelVendorByLocation') == "1";
  static bool get enableParcelMultipleStops =>
      env('enableParcelMultipleStops') == "1";
  static int get maxParcelStops =>
      env('maxParcelStops').toString().toInt() ?? 1;
  static String get what3wordsApiKey => env('what3wordsApiKey') ?? "";
  static bool get isWhat3wordsApiKey => what3wordsApiKey.isNotEmpty;
  //App download links
  static String get androidDownloadLink => env('androidDownloadLink') ?? "";
  static String get iOSDownloadLink => env('iosDownloadLink') ?? "";
  //
  static bool get isSingleVendorMode => env('isSingleVendorMode') == "1";
  static bool get canScheduleTaxiOrder =>
      env('taxi')['canScheduleTaxiOrder'] != null
          ? (env('taxi')['canScheduleTaxiOrder'] == "1")
          : false;
  static int get taxiMaxScheduleDays =>
      (env('taxi')['taxiMaxScheduleDays'].toString().toInt()) ?? 2;

  static Map<String, dynamic> get enabledVendorType =>
      env('enabledVendorType') ?? {};
  static double get bannerHeight =>
      double.parse("${env('bannerHeight') ?? 150.00}");

  //
  static String get otpGateway => env('otpGateway') ?? "none";
  static bool get isFirebaseOtp => otpGateway.toLowerCase() == "firebase";
  static bool get isCustomOtp =>
      !["none", "firebase"].contains(otpGateway.toLowerCase());

  static String get emergencyContact => env('emergencyContact') ?? "911";

  //Simplified authentication - only phone/password
  static bool get qrcodeLogin => false; // Removed QR login complexity

  //UI Configures
  static dynamic get uiConfig {
    return env('ui') ?? null;
  }

  static double get categoryImageWidth {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 40.00;
    }
    return double.parse((env('ui')['categorySize']["w"] ?? 40.00).toString());
  }

  static double get categoryImageHeight {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 40.00;
    }
    return double.parse((env('ui')['categorySize']["h"] ?? 40.00).toString());
  }

  static double get categoryTextSize {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 12.00;
    }
    return double.parse(
      (env('ui')['categorySize']["text"]['size'] ?? 12.00).toString(),
    );
  }

  static int get categoryPerRow {
    try {
      if (env('ui') == null || env('ui')["categorySize"] == null) {
        return 4;
      }
      return int.parse((env('ui')['categorySize']["row"] ?? 4).toString());
    } catch (e) {
      return 3;
    }
  }

  static bool get categoryStyleGrid {
    try {
      if (env('ui') == null || env('ui')["categoryStyle"] == null) {
        return true;
      }
      String style = env('ui')['categoryStyle'].toString().toLowerCase();
      return style == "grid";
    } catch (e) {
      return true;
    }
  }

  static bool get searchGoogleMapByCountry {
    if (env('ui') == null || env('ui')["google"] == null) {
      return false;
    }
    return env('ui')['google']["searchByCountry"] ?? false;
  }

  static String get searchGoogleMapByCountries {
    if (env('ui') == null || env('ui')["google"] == null) {
      return "";
    }
    return env('ui')['google']["searchByCountries"] ?? "";
  }

  static bool get useWebsocketAssignment {
    return (env('useWebsocketAssignment') ?? false);
  }

  //DONT'T TOUCH
  static const String notificationChannel = "high_importance_channel";

  //START DON'T TOUNCH
  //for app usage
  static String firstTimeOnApp = "first_time";
  static String authenticated = "authenticated";
  static String userAuthToken = "auth_token";
  static String userKey = "user";
  static String appLocale = "locale";
  static String notificationsKey = "notifications";
  static String appCurrency = "currency";
  static String appColors = "colors";
  static String appRemoteSettings = "appRemoteSettings";
  //END DON'T TOUNCH

  //
  //Change to your app store id
  static String appStoreId = "";

  //
  //saving
  static Future<bool> saveAppSettingsToLocalStorage(String stringMap) async {
    return await LocalStorageService.prefs!.setString(
      AppStrings.appRemoteSettings,
      stringMap,
    );
  }

  static dynamic appSettingsObject;
  static Future<void> getAppSettingsFromLocalStorage() async {
    try {
      appSettingsObject = LocalStorageService.prefs?.getString(
        AppStrings.appRemoteSettings,
      );
      if (appSettingsObject != null && appSettingsObject.isNotEmpty) {
        appSettingsObject = jsonDecode(appSettingsObject);
      } else {
        appSettingsObject = null;
      }
    } catch (error) {
      print("❌ Error getting app settings from localStorage: $error");
      appSettingsObject = null;
    }
  }

  static dynamic env(String ref) {
    try {
      // Ensure preferences are initialized (synchronous check)
      if (LocalStorageService.prefs == null) {
        // If prefs not initialized, return default values
        return _getDefaultValue(ref);
      }
      
      //
      getAppSettingsFromLocalStorage();
      //
      if (appSettingsObject != null && appSettingsObject[ref] != null) {
        return appSettingsObject[ref];
      }
      return _getDefaultValue(ref); // Return default value instead of empty string
    } catch (error) {
      print("❌ Error in env($ref): $error");
      return _getDefaultValue(ref); // Return default value on error
    }
  }
  
  // Helper method to get default values for common settings
  static dynamic _getDefaultValue(String ref) {
    switch (ref) {
      case 'country_code':
        return 'US';
      case 'app_name':
        return 'Classy';
      case 'company_name':
        return 'Classy Inc';
      case 'currency':
        return '\$';
      case 'enble_otp':
        return '1';
      case 'enableOTPLogin':
        return '1';
      case 'enableEmailLogin':
        return true;
      case 'enableProfileUpdate':
        return true;
      case 'enableGoogleDistance':
        return '1';
      case 'enableSingleVendor':
        return '0';
      case 'enableMultipleVendorOrder':
        return true;
      case 'enableReferSystem':
        return '0'; // Disabled for simplicity
      case 'referAmount':
        return '0'; // No referral system
      case 'enableChat':
        return '0'; // Disabled for simplicity
      case 'enableOrderTracking':
        return '1';
      case 'enableFatchByLocation':
        return true;
      case 'showVendorTypeImageOnly':
        return '0';
      case 'enableUploadPrescription':
        return '1';
      case 'enableParcelVendorByLocation':
        return '1';
      case 'enableParcelMultipleStops':
        return '1';
      case 'maxParcelStops':
        return '5';
      case 'bannerHeight':
        return 150.0;
      case 'otpGateway':
        return 'firebase';
      case 'emergencyContact':
        return '911';
      case 'auth':
        return {
          'qrcodeLogin': false,   // QR login removed for simplicity
          'socialLogin': false    // Social media login removed
        };
      case 'ui':
        return {
          'categorySize': {
            'w': 40.0,
            'h': 40.0,
            'text': {'size': 12.0},
            'row': 4
          },
          'categoryStyle': 'grid',
          'google': {
            'searchByCountry': false,
            'searchByCountries': ''
          },
          'showVendorAddress': true,
          'showVendorPhone': true,
          'chat': {
            'canVendorChat': 1,
            'canCustomerChat': 1,
            'canCustomerChatSupportMedia': 1,
            'canDriverChat': 1
          },
          'call': {
            'canCustomerVendorCall': 1,
            'canCustomerDriverCall': 1
          }
        };
      case 'enabledVendorType':
        return {
          'food': '1',
          'taxi': '1',
          'boda': '1',
          'parcel': '1'
        };
      case 'taxi':
        return {
          'canScheduleTaxiOrder': '1',
          'taxiMaxScheduleDays': '7',
          'requestBookingCode': 1,
          'drivingSpeed': 50.0
        };
      case 'finance':
        return {
          'allowWalletTransfer': 1,
          'allowWallet': 1,
          'delivery': {
            'collectDeliveryCash': 1
          },
          'enableLoyalty': 0,  // Simplified - no loyalty points
          'point_to_amount': 0,
          'amount_to_point': 0
        };
      case 'map':
        return {
          'useGoogleOnApp': 1
        };
      case 'file_limit':
        return {
          'prescription': {
            'file_limit': 5,
            'file_size_limit': 5
          }
        };
      case 'dynamic_link':
        return {
          'prefix': 'https://classy.page.link',
          'android': 'https://classy.page.link/android',
          'ios': 'https://classy.page.link/ios'
        };
      case 'driverSearchRadius':
        return 10;
      case 'show_cart':
        return true;
      case 'upgrade':
        return {
          'customer': {
            'android': 1, // Changed from '1' to 1 (int)
            'ios': 1,     // Changed from '1' to 1 (int)
            'force': 0    // Changed from '0' to 0 (int)
          }
        };
      case 'chat':
        return {
          'canCustomerChat': 1,           // Changed from '1' to 1 (int)
          'canCustomerChatSupportMedia': 1 // Changed from '1' to 1 (int)
        };
      case 'call':
        return {
          'canCustomerVendorCall': 1,     // Changed from '1' to 1 (int)
          'canCustomerDriverCall': 1      // Changed from '1' to 1 (int)
        };
      default:
        return '';
    }
  }

  //
  static List<String> get orderCancellationReasons {
    return ["Long pickup time", "Vendor is too slow", "custom"];
  }

  //
  static List<String> get orderStatuses {
    return [
      'pending',
      'preparing',
      'ready',
      'enroute',
      'failed',
      'cancelled',
      'delivered',
    ];
  }
}
