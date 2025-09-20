import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Additional color properties for compatibility
  static Color get primaryColor => AppColor.primaryColor;
  static Color get primaryColorDark => AppColor.primaryColorDark;
  static Color get successColor => AppColor.successColor;
  static Color get errorColor => AppColor.errorColor;
  static Color get warningColor => AppColor.warningColor;
  static Color get infoColor => AppColor.infoColor;
  static Color get secondaryColor => AppColor.accentColor;

  //
  static ThemeData get lightTheme {
    return ThemeData(
      // fontFamily: GoogleFonts.iBMPlexSerif().fontFamily,
      // fontFamily: GoogleFonts.krub().fontFamily,
      // fontFamily: GoogleFonts.nunito().fontFamily,
      fontFamily: GoogleFonts.roboto().fontFamily,
      primaryColor: AppColor.primaryColor,
      primaryColorDark: AppColor.primaryColorDark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
        cursorColor: AppColor.cursorColor,
      ),
      cardColor: Colors.grey[50],
      textTheme: _blackTextTheme,
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
      // brightness: Brightness.light,
      // CUSTOMIZE showDatePicker Colors
      dialogTheme: DialogThemeData(backgroundColor: Colors.white),
      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      highlightColor: Colors.grey[400],
      colorScheme: ColorScheme.light(
        primary: AppColor.primaryColor,
        secondary: AppColor.accentColor,
        brightness: Brightness.light,
      ).copyWith(primary: AppColor.primaryMaterialColor, surface: Colors.white),
      useMaterial3: false,
    );
  }

  //
  static ThemeData get darkTheme {
    return ThemeData(
      // fontFamily: GoogleFonts.iBMPlexSerif().fontFamily,
      // fontFamily: GoogleFonts.krub().fontFamily,
      // fontFamily: GoogleFonts.nunito().fontFamily,
      fontFamily: GoogleFonts.roboto().fontFamily,
      primaryColor: AppColor.primaryColor,
      primaryColorDark: AppColor.primaryColorDark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
        cursorColor: AppColor.cursorColor,
      ),
      cardColor: Colors.grey[700],
      textTheme: _whiteTextTheme,
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: AppColor.accentColor,
        brightness: Brightness.dark,
        // primary: AppColor.primaryColor,
        primary: AppColor.primaryMaterialColor,
        surface: Colors.grey[850],
      ),
      useMaterial3: false,
    );
  }

  //MISC
  static final TextTheme _blackTextTheme = TextTheme(
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    displaySmall: TextStyle(color: Colors.black),
    headlineLarge: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    headlineSmall: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.black),
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
    labelLarge: TextStyle(color: Colors.black),
    labelMedium: TextStyle(color: Colors.black),
    labelSmall: TextStyle(color: Colors.black),
  );

  static final TextTheme _whiteTextTheme = TextTheme(
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.white),
    labelSmall: TextStyle(color: Colors.white),
  );
}
