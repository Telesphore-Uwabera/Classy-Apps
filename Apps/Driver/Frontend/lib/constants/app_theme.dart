import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme
  ThemeData lightTheme() {
    return ThemeData(
      fontFamily: GoogleFonts.nunito().fontFamily,
      primaryColor: AppColor.classyPrimary,
      primaryColorDark: AppColor.classySecondary,
      scaffoldBackgroundColor: AppColor.backgroundSecondary,
      
      // Text Selection
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColor.classyPrimary.withOpacity(0.3),
        cursorColor: AppColor.classyPrimary,
      ),
      
      // Card Theme
      cardColor: AppColor.backgroundCard,
                 cardTheme: CardThemeData(
             color: AppColor.backgroundCard,
             elevation: 2,
             shadowColor: Colors.black.withOpacity(0.1),
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(12),
             ),
           ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: AppColor.textSecondary,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: AppColor.textSecondary,
          fontWeight: FontWeight.normal,
        ),
        labelSmall: TextStyle(
          color: AppColor.textLight,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColor.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColor.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          color: AppColor.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: AppColor.textSecondary,
          fontSize: 14,
        ),
      ),
      
      // Button Theme
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        buttonColor: AppColor.classyPrimary,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.classyPrimary,
          foregroundColor: AppColor.textWhite,
          elevation: 2,
          shadowColor: AppColor.classyPrimary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.classyPrimary,
          side: BorderSide(color: AppColor.classyPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.classyPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.classyPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.classyError, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: AppColor.textLight,
          fontSize: 14,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.backgroundCard,
        foregroundColor: AppColor.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColor.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColor.backgroundCard,
        selectedItemColor: AppColor.classyPrimary,
        unselectedItemColor: AppColor.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColor.classyPrimary,
        foregroundColor: AppColor.textWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColor.classyPrimary,
        secondary: AppColor.classySecondary,
        surface: AppColor.backgroundCard,
        background: AppColor.backgroundSecondary,
        error: AppColor.classyError,
        onPrimary: AppColor.textWhite,
        onSecondary: AppColor.textWhite,
        onSurface: AppColor.textPrimary,
        onBackground: AppColor.textPrimary,
        onError: AppColor.textWhite,
        brightness: Brightness.light,
      ),
      
      useMaterial3: true,
    );
  }

  // Dark Theme
  ThemeData darkTheme() {
    return ThemeData(
      fontFamily: GoogleFonts.nunito().fontFamily,
      primaryColor: AppColor.classyPrimary,
      primaryColorDark: AppColor.classySecondary,
      scaffoldBackgroundColor: Color(0xFF121212),
      
      // Text Selection
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColor.classyPrimary.withOpacity(0.3),
        cursorColor: AppColor.classyPrimary,
      ),
      
      // Card Theme
      cardColor: Color(0xFF1E1E1E),
      cardTheme: CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: AppColor.textLight,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: AppColor.textWhite,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: AppColor.textLight,
          fontWeight: FontWeight.normal,
        ),
        labelSmall: TextStyle(
          color: AppColor.textLight,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          color: AppColor.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: AppColor.textLight,
          fontSize: 14,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.classyPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.classyError, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: AppColor.textLight,
          fontSize: 14,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: AppColor.textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColor.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: AppColor.classyPrimary,
        unselectedItemColor: AppColor.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColor.classyPrimary,
        secondary: AppColor.classySecondary,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        error: AppColor.classyError,
        onPrimary: AppColor.textWhite,
        onSecondary: AppColor.textWhite,
        onSurface: AppColor.textWhite,
        onBackground: AppColor.textWhite,
        onError: AppColor.textWhite,
        brightness: Brightness.dark,
      ),
      
      useMaterial3: true,
    );
  }
}
