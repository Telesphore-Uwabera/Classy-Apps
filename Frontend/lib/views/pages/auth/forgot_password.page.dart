import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/services/validator.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/forgot_password.view_model.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/arrow_indicator.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForgotPasswordViewModel>.reactive(
      viewModelBuilder: () => ForgotPasswordViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          appBarColor: AppColor.faintBgColor,
          leading: IconButton(
            icon: ArrowIndicator(leading: true),
            onPressed: () => Navigator.pop(context),
          ),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
              child: VStack([
                // Header
                VStack([
                  Image.asset(AppImages.appLogo).h(96).w(96).centered(),
                  16.heightBox,
                  "Forgot Password".tr().text.xl3.semiBold.color(AppColor.primaryColor).makeCentered(),
                  8.heightBox,
                  "Enter your phone number to reset your password"
                      .tr()
                      .text
                      .lg
                      .light
                      .makeCentered()
                      .px20(),
                ]).py20(),

                // Form
                VStack([
                  Form(
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

                      // Reset Password Button
                      CustomButton(
                        title: "Send Reset Code".tr(),
                        loading: model.isBusy,
                        onPressed: model.sendResetCode,
                      ).centered().py12(),

                      // Back to Login
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Back to Login".tr(),
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ).py8(),

                      // Terms and Privacy Links
                      VStack([
                        HStack([
                          "By using this service, you agree to our ".tr().text.sm.gray600.make(),
                          "Terms & Conditions"
                              .tr()
                              .text
                              .sm
                              .color(AppColor.primaryColor)
                              .bold
                              .underline
                              .make()
                              .onInkTap(() {
                                Navigator.of(context).pushNamed(AppRoutes.termsConditionsRoute);
                              }),
                        ]).centered(),
                        HStack([
                          "and ".tr().text.sm.gray600.make(),
                          "Privacy Policy"
                              .tr()
                              .text
                              .sm
                              .color(AppColor.primaryColor)
                              .bold
                              .underline
                              .make()
                              .onInkTap(() {
                                Navigator.of(context).pushNamed(AppRoutes.privacyPolicyRoute);
                              }),
                        ]).centered(),
                      ]).py8(),
                    ]),
                  ),
                ]).px20(),
              ]).scrollVertical(),
            ),
          ),
        );
      },
    );
  }
}
