import 'package:flutter/material.dart';

class AppColor {
  // Primary Colors
  static const Color primaryColor = Color(0xFFE91E63);
  static const Color primaryColorDark = Color(0xFFC2185B);
  static const Color accentColor = Color(0xFFE91E63);
  static const Color cursorColor = primaryColor;

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Material Colors
  static MaterialColor get primaryMaterialColor => MaterialColor(
        primaryColor.value,
        <int, Color>{
          50: primaryColor.withOpacity(0.1),
          100: primaryColor.withOpacity(0.2),
          200: primaryColor.withOpacity(0.3),
          300: primaryColor.withOpacity(0.4),
          400: primaryColor.withOpacity(0.5),
          500: primaryColor,
          600: primaryColorDark,
          700: primaryColorDark,
          800: primaryColorDark,
          900: primaryColorDark,
        },
      );

  static MaterialColor get accentMaterialColor => MaterialColor(
        accentColor.value,
        <int, Color>{
          50: accentColor.withOpacity(0.1),
          100: accentColor.withOpacity(0.2),
          200: accentColor.withOpacity(0.3),
          300: accentColor.withOpacity(0.4),
          400: accentColor.withOpacity(0.5),
          500: accentColor,
          600: accentColor,
          700: accentColor,
          800: accentColor,
          900: accentColor,
        },
      );

  // Onboarding Colors
  static const Color onboarding1Color = Color(0xFFE91E63);
  static const Color onboarding2Color = Color(0xFF9C27B0);
  static const Color onboarding3Color = Color(0xFF3F51B5);

  // Additional Colors
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
}
