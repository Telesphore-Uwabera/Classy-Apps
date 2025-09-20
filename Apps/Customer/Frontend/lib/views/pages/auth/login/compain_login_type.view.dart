import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/sizes.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/login.view_model.dart';
import 'package:Classy/views/pages/auth/login/email_login.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CombinedLoginTypeView extends StatefulWidget {
  const CombinedLoginTypeView(this.model, {this.radius, Key? key})
    : super(key: key);

  final LoginViewModel model;
  final double? radius;

  @override
  State<CombinedLoginTypeView> createState() => _CombinedLoginTypeViewState();
}

class _CombinedLoginTypeViewState extends State<CombinedLoginTypeView> {
  @override
  Widget build(BuildContext context) {
    return VStack([
      UiSpacer.vSpace(),
      // Simple header for email login
      Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(
            (widget.radius ?? Sizes.radiusDefault),
          ),
          border: Border.fromBorderSide(
            BorderSide(color: AppColor.primaryColor, width: 1.5),
          ),
        ),
        child: Text(
          "Email Address".tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.primaryColor,
          ),
        ).centered(),
      ),
      //
      EmailLoginView(widget.model),
    ]);
  }
}
