import 'package:jiffy/jiffy.dart';

class Utils {
  static Future<void> setJiffyLocale() async {
    try {
      await Jiffy.setLocale("en");
    } catch (e) {
      print("Error setting Jiffy locale: $e");
    }
  }
}