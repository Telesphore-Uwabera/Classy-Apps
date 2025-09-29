import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //
  ThemeData lightTheme() {
    return ThemeData(
      // fontFamily: GoogleFonts.ibmPlexSerif().fontFamily,
      // fontFamily: GoogleFonts.krub().fontFamily,
      // fontFamily: GoogleFonts.montserrat().fontFamily,
      // fontFamily: GoogleFonts.poppins().fontFamily,
      fontFamily: GoogleFonts.roboto().fontFamily,
      // fontFamily: GoogleFonts.nunito().fontFamily,
      // fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
      // backgroundColor: Colors.white,
      primaryColor: AppColor.primaryColor,
      primaryColorDark: AppColor.primaryColorDark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
        cursorColor: AppColor.cursorColor,
      ),
      cardColor: Colors.grey[50],
      textTheme: blackTextTheme,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
      ),
      // brightness: Brightness.light,
      // CUSTOMIZE showDatePicker Colors
      dialogBackgroundColor: Colors.white,
      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      highlightColor: Colors.grey[400],
      colorScheme: ColorScheme.light(
        primary: AppColor.primaryColor,
        secondary: AppColor.accentColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColor.primaryMaterialColor,
        surface: Colors.white,
      ),
      // Global component theming aligned with provided UI
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[200],
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColor.primaryColor, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primaryColor,
          side: BorderSide(color: AppColor.primaryColor, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColor.primaryColor,
        unselectedItemColor: Colors.grey[500],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.resolveWith((states) {
          final active = states.contains(MaterialState.selected);
          return active ? AppColor.primaryColor.withOpacity(.5) : Colors.grey[300];
        }),
        thumbColor: MaterialStateProperty.resolveWith((states) {
          final active = states.contains(MaterialState.selected);
          return active ? AppColor.primaryColor : Colors.white;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColor.primaryColor.withOpacity(.1),
        selectedColor: AppColor.primaryColor.withOpacity(.15),
        disabledColor: Colors.grey[200],
        labelStyle: const TextStyle(color: Colors.black),
        secondaryLabelStyle: const TextStyle(color: Colors.black),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      //
      tabBarTheme: tabBarTheme,
      useMaterial3: true,
    );
  }

  //
  ThemeData darkTheme() {
    return ThemeData(
      // fontFamily: GoogleFonts.iBMPlexSerif().fontFamily,
      // fontFamily: GoogleFonts.krub().fontFamily,
      fontFamily: GoogleFonts.roboto().fontFamily,
      // fontFamily: GoogleFonts.nunito().fontFamily,
      // fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
      // fontFamily: GoogleFonts.montserrat().fontFamily,
      primaryColor: AppColor.primaryColor,
      primaryColorDark: AppColor.primaryColorDark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
        cursorColor: AppColor.cursorColor,
      ),
      // backgroundColor: Colors.grey[850],
      cardColor: Colors.grey[700],
      textTheme: whiteTextTheme,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.black,
      ),
      dialogBackgroundColor: Colors.grey.shade600,
      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      highlightColor: Colors.grey[700],
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(
            primary: AppColor.primaryColor,
            secondary: AppColor.accentColor,
            brightness: Brightness.dark,
          )
          .copyWith(
            primary: AppColor.primaryMaterialColor,
            surface: Colors.grey[850],
          ),

      // Mirror shapes/colors for dark variant
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.grey[800],
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColor.primaryColor, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primaryColor,
          side: BorderSide(color: AppColor.primaryColor, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[900],
        selectedItemColor: AppColor.primaryColor,
        unselectedItemColor: Colors.grey[500],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.resolveWith((states) {
          final active = states.contains(MaterialState.selected);
          return active ? AppColor.primaryColor.withOpacity(.5) : Colors.grey[700];
        }),
        thumbColor: MaterialStateProperty.resolveWith((states) {
          final active = states.contains(MaterialState.selected);
          return active ? AppColor.primaryColor : Colors.white;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColor.primaryColor.withOpacity(.1),
        selectedColor: AppColor.primaryColor.withOpacity(.2),
        disabledColor: Colors.grey[800],
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.dark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      //
      tabBarTheme: tabBarTheme,
      useMaterial3: true,
    );
  }

  //MISC
  final TextTheme blackTextTheme = TextTheme(
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

  final TextTheme whiteTextTheme = TextTheme(
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

  //
  TabBarThemeData get tabBarTheme {
    return TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Utils.textColorByTheme(),
      unselectedLabelColor: Utils.textColorByTheme(),
      // labelColor: Utils.textColorByTheme(),
      indicator: BoxDecoration(
        // color: AppColor.primaryColor,
        border: Border(
          bottom: BorderSide(
            color: Utils.textColorByTheme(),
            width: 3,
          ),
        ),
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.normal,
      ),
      tabAlignment: TabAlignment.start,
    );
  }
}
