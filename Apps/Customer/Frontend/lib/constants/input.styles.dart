import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class InputStyles {
  //get the border for the textform field
  static InputBorder inputEnabledBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
      borderRadius: BorderRadius.circular(24),
    );
  }

  //get the border for the textform field
  static InputBorder inputFocusBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColor.primaryColor,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(24),
    );
  }


  //
  //get the border for the textform field
  static InputBorder inputUnderlineEnabledBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: AppColor.primaryColor,
      ),
      borderRadius: BorderRadius.circular(24),
    );
  }

  //get the border for the textform field
  static InputBorder inputUnderlineFocusBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: AppColor.primaryColor,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(24),
    );
  }
}
