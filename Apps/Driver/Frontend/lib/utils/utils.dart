import 'package:jiffy/jiffy.dart';

class Utils {
  static Future<void> setJiffyLocale() async {
    try {
      await Jiffy.setLocale("en");
    } catch (e) {
      print("Error setting Jiffy locale: $e");
    }
  }

  static bool get isArabic => false; // For now, always return false since we're using English
}