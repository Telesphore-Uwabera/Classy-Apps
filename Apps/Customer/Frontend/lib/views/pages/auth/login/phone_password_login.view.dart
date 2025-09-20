import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/services/validator.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/login.view_model.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PhonePasswordLoginView extends StatelessWidget {
  const PhonePasswordLoginView(this.model, {Key? key}) : super(key: key);

  final LoginViewModel model;
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: model.formKey,
      child: VStack([
        // Phone input with flag
        HStack([
          CustomTextFormField(
            prefixIcon: HStack([
              Flag.fromString(
                model.selectedCountry?.countryCode ?? "rw",
                width: 20,
                height: 20,
              ),
              UiSpacer.horizontalSpace(space: 5),
              ("+" + (model.selectedCountry?.phoneCode ?? "250")).text.make(),
            ]).px8().onInkTap(model.showCountryDialPicker),
            labelText: "Phone Number".tr(),
            keyboardType: TextInputType.phone,
            textEditingController: model.phoneTEC,
            validator: FormValidator.validatePhone,
          ).expand(),
        ]).py12(),
        
        // Password
        CustomTextFormField(
          labelText: "Password".tr(),
          obscureText: true,
          textEditingController: model.passwordTEC,
          validator: FormValidator.validatePassword,
        ).py12(),
        
        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: "Forgot Password?".tr()
              .text
              .sm
              .color(AppColor.primaryColor)
              .underline
              .make()
              .onInkTap(model.openForgotPassword),
        ).py8(),
        
        // Login Button
        CustomButton(
          title: "Login".tr(),
          onPressed: model.processLogin,
          loading: model.isBusy,
        ).py12(),
      ]).px20(),
    );
  }
}
