import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:velocity_x/velocity_x.dart';

class AppColor {
  // Classy Brand Colors
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
  
  // Driver App Specific Colors
  static const Color driverActive = Color(0xFF4CAF50); // Green
  static const Color driverInactive = Color(0xFF9E9E9E); // Grey
  static const Color earningsPositive = Color(0xFF4CAF50); // Green
  static const Color earningsNegative = Color(0xFFF44336); // Red
  static const Color emergencySOS = Color(0xFFF44336); // Red
  
  // Legacy color support (keeping for compatibility)
  static Color get accentColor => classyPrimary;
  static Color get primaryColor => classyPrimary;
  static Color get primaryColorDark => classySecondary;
  static Color get cursorColor => classyPrimary;

  // Material color
  static MaterialColor get accentMaterialColor => MaterialColor(
        classyPrimary.value,
        <int, Color>{
          50: classyPrimary.withOpacity(0.1),
          100: classyPrimary.withOpacity(0.2),
          200: classyPrimary.withOpacity(0.3),
          300: classyPrimary.withOpacity(0.4),
          400: classyPrimary.withOpacity(0.5),
          500: classyPrimary.withOpacity(0.6),
          600: classyPrimary.withOpacity(0.7),
          700: classyPrimary.withOpacity(0.8),
          800: classyPrimary.withOpacity(0.9),
          900: classyPrimary,
        },
      );
  static MaterialColor get primaryMaterialColor => MaterialColor(
        classyPrimary.value,
        <int, Color>{
          50: classyPrimary.withOpacity(0.1),
          100: classyPrimary.withOpacity(0.2),
          200: classyPrimary.withOpacity(0.3),
          300: classyPrimary.withOpacity(0.4),
          400: classyPrimary.withOpacity(0.5),
          500: classyPrimary.withOpacity(0.6),
          600: classyPrimary.withOpacity(0.7),
          700: classyPrimary.withOpacity(0.8),
          800: classyPrimary.withOpacity(0.9),
          900: classyPrimary,
        },
      );
  static Color get primaryMaterialColorDark => classySecondary;
  static Color get cursorMaterialColor => classyPrimary;

  // Onboarding colors
  static Color get onboarding1Color => classyPrimary;
  static Color get onboarding2Color => classySecondary;
  static Color get onboarding3Color => classyAccent;

  static Color get onboardingIndicatorDotColor => Colors.grey.shade300;
  static Color get onboardingIndicatorActiveDotColor => classyPrimary;

  // Shimmer Colors
  static Color shimmerBaseColor = Colors.grey.shade300;
  static Color shimmerHighlightColor = Colors.grey.shade200;

  // Input colors
  static Color get inputFillColor => Colors.grey.shade100;
  static Color get iconHintColor => Colors.grey.shade500;

  // Status colors for orders
  static Color get openColor => classySuccess;
  static Color get closeColor => classyError;
  static Color get deliveryColor => classyInfo;
  static Color get pickupColor => classyWarning;
  static Color get ratingColor => classyWarning;
  static Color get deliveredColor => getStausColor("delivered");

  static Color getStausColor(String status) {
    switch (status) {
      case "pending":
        return classyWarning;
      case "preparing":
        return classyInfo;
      case "enroute":
        return classyPrimary;
      case "failed":
        return classyError;
      case "cancelled":
        return classyError;
      case "delivered":
        return classySuccess;
      case "successful":
        return classySuccess;
      default:
        return classyWarning;
    }
  }

  // Saving
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
    getColorsFromLocalStorage();
    final selectedColor =
        appColorsObject != null ? appColorsObject[colorRef] : "#E91E63";
    return selectedColor;
  }
}
