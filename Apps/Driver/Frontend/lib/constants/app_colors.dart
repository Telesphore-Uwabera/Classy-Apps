import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/constants/app_strings.dart';

class AppColor {
  // Primary Colors
  static Color get primaryColor => Color(0xFFE91E63);
  static Color get primaryColorDark => Color(0xFFD81B60);
  static Color get accentColor => Color(0xFFE91E63);
  
  // Secondary Colors
  static Color get secondaryColor => Color(0xFFEC407A);
  static Color get secondaryColorDark => Color(0xFFAD1457);
  
  // Background Colors
  static Color get backgroundColor => Colors.grey[50]!;
  static Color get surfaceColor => Colors.white;
  
  // Text Colors
  static Color get textColor => Colors.black87;
  static Color get textColorSecondary => Colors.grey[600]!;
  
  // Status Colors
  static Color get successColor => Colors.green;
  static Color get warningColor => Colors.orange;
  static Color get errorColor => Colors.red;
  static Color get infoColor => Colors.blue;
  
  // Save colors to local storage
  static Future<void> saveColorsToLocalStorage(String colorsJson) async {
    await LocalStorageService.prefs!.setString("app_colors", colorsJson);
  }
  
  // Get colors from local storage
  static Map<String, dynamic> getColorsFromLocalStorage() {
    final colorsString = LocalStorageService.prefs!.getString("app_colors");
    if (colorsString != null && colorsString.isNotEmpty) {
      try {
        return json.decode(colorsString);
      } catch (e) {
        print("Error parsing colors: $e");
        return {};
      }
    }
    return {};
  }
  
  // Get color from stored colors or return default
  static Color getColor(String key, Color defaultColor) {
    final colors = getColorsFromLocalStorage();
    if (colors.containsKey(key)) {
      try {
        return Color(int.parse(colors[key].toString().replaceAll('#', '0xFF')));
      } catch (e) {
        print("Error parsing color $key: $e");
        return defaultColor;
      }
    }
    return defaultColor;
  }
}