import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';

class AppTextStyle {
  static TextStyle h3TitleTextStyle({Color? color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.black87,
    );
  }
  
  static TextStyle h2TitleTextStyle({Color? color}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: color ?? Colors.black87,
    );
  }
  
  static TextStyle h1TitleTextStyle({Color? color}) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: color ?? Colors.black87,
    );
  }
  
  static TextStyle bodyTextStyle({Color? color}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? Colors.black54,
    );
  }
  
  static TextStyle captionTextStyle({Color? color}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? Colors.black45,
    );
  }
}
