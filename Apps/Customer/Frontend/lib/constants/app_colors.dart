import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/services/local_storage.service.dart';
import 'package:velocity_x/velocity_x.dart';

class AppColor {
  // Classy Brand Colors - Consistent across all apps
  static const Color classyPrimary = Color(0xFFE91E63); // Vibrant pink
  static const Color classySecondary = Color(0xFF9C27B0); // Purple
  static const Color classyAccent = Color(0xFFFF5722); // Orange
  static const Color classySuccess = Color(0xFF4CAF50); // Green
  static const Color classyWarning = Color(0xFFFF9800); // Orange
  static const Color classyError = Color(0xFFF44336); // Red
  static const Color classyInfo = Color(0xFF2196F3); // Blue
  
  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // White
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Light grey
  static const Color backgroundCard = Color(0xFFFFFFFF); // White
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark grey/black
  static const Color textSecondary = Color(0xFF757575); // Medium grey
  static const Color textLight = Color(0xFFBDBDBD); // Light grey
  static const Color textWhite = Color(0xFFFFFFFF); // White
  
  // Status Colors
  static const Color statusOnline = Color(0xFF4CAF50); // Green
  static const Color statusOffline = Color(0xFF9E9E9E); // Grey
  static const Color statusPending = Color(0xFFFF9800); // Orange
  static const Color statusVerified = Color(0xFF4CAF50); // Green
  static const Color statusRejected = Color(0xFFF44336); // Red
  
  // Legacy color support (keeping for compatibility)
  static Color get accentColor => classyPrimary;
  static Color get primaryColor => classyPrimary;
  static Color get primaryColorDark => classySecondary;
  static Color get cursorColor => classyPrimary;

  //material color
  static MaterialColor get accentMaterialColor => MaterialColor(
        Vx.getColorFromHex(colorEnv('accentColor')),
        <int, Color>{
          50: Vx.hexToColor(colorEnv('accentColor')),
          100: Vx.hexToColor(colorEnv('accentColor')),
          200: Vx.hexToColor(colorEnv('accentColor')),
          300: Vx.hexToColor(colorEnv('accentColor')),
          400: Vx.hexToColor(colorEnv('accentColor')),
          500: Vx.hexToColor(colorEnv('accentColor')),
          600: Vx.hexToColor(colorEnv('accentColor')),
          700: Vx.hexToColor(colorEnv('accentColor')),
          800: Vx.hexToColor(colorEnv('accentColor')),
          900: Vx.hexToColor(colorEnv('accentColor')),
        },
      );
  static MaterialColor get primaryMaterialColor => MaterialColor(
        Vx.getColorFromHex(colorEnv('primaryColor')),
        <int, Color>{
          50: Vx.hexToColor(colorEnv('primaryColor')),
          100: Vx.hexToColor(colorEnv('primaryColor')),
          200: Vx.hexToColor(colorEnv('primaryColor')),
          300: Vx.hexToColor(colorEnv('primaryColor')),
          400: Vx.hexToColor(colorEnv('primaryColor')),
          500: Vx.hexToColor(colorEnv('primaryColor')),
          600: Vx.hexToColor(colorEnv('primaryColor')),
          700: Vx.hexToColor(colorEnv('primaryColor')),
          800: Vx.hexToColor(colorEnv('primaryColor')),
          900: Vx.hexToColor(colorEnv('primaryColor')),
        },
      );
  static Color get primaryMaterialColorDark =>
      Vx.hexToColor(colorEnv('primaryColorDark'));
  static Color get cursorMaterialColor => accentColor;

  //onboarding colors
  static Color get onboarding1Color =>
      Vx.hexToColor(colorEnv('onboarding1Color'));
  static Color get onboarding2Color =>
      Vx.hexToColor(colorEnv('onboarding2Color'));
  static Color get onboarding3Color =>
      Vx.hexToColor(colorEnv('onboarding3Color'));

  static Color get onboardingIndicatorDotColor =>
      Vx.hexToColor(colorEnv('onboardingIndicatorDotColor'));
  static Color get onboardingIndicatorActiveDotColor =>
      Vx.hexToColor(colorEnv('onboardingIndicatorActiveDotColor'));

  //Shimmer Colors
  static Color shimmerBaseColor = Colors.grey.shade300;
  static Color shimmerHighlightColor = Colors.grey.shade200;

  //inputs
  static Color get inputFillColor => Colors.grey[200]!;
  static Color get iconHintColor => Colors.grey[500]!;

  static Color get openColor => Vx.hexToColor(colorEnv('openColor'));
  static Color get closeColor => Vx.hexToColor(colorEnv('closeColor'));
  static Color get deliveryColor => Vx.hexToColor(colorEnv('deliveryColor'));
  static Color get pickupColor => Vx.hexToColor(colorEnv('pickupColor'));
  static Color get ratingColor => Vx.hexToColor(colorEnv('ratingColor'));

  //
  static Color get faintBgColor {
    try {
      final isLightMode =
          AppService().navigatorKey.currentContext?.brightness ==
              Brightness.light;
      return isLightMode ? Vx.hexToColor("#FDFAF6") : Vx.hexToColor("#212121");
    } catch (error) {
      return Colors.white;
    }
  }

  static Color getStausColor(String status) {
    //'pending','preparing','enroute','failed','cancelled','delivered'
    final statusColorName = "${status}Color";
    try {
      return Vx.hexToColor(colorEnv(statusColorName));
    } catch (error) {
      return Vx.hexToColor(colorEnv('pendingColor'));
    }
  }

  //saving
  static Future<bool> saveColorsToLocalStorage(String colorsMap) async {
    return await LocalStorageService.prefs!
        .setString(AppStrings.appColors, colorsMap);
  }

  static dynamic appColorsObject;
  static Future<void> getColorsFromLocalStorage() async {
    appColorsObject =
        LocalStorageService.prefs!.getString(AppStrings.appColors);
    if (appColorsObject != null) {
      appColorsObject = jsonDecode(appColorsObject);
    }
  }

  static String colorEnv(String colorRef) {
    //
    getColorsFromLocalStorage();
    //
    String? selectedColor =
        appColorsObject != null ? appColorsObject[colorRef] : "#000000";
    if (selectedColor == null) {
      selectedColor = "#000000";
    }
    return selectedColor;
  }
}
