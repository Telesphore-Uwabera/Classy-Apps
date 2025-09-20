import 'package:flutter/material.dart';
import 'constants/app_images.dart';
import 'constants/app_strings.dart';
import 'constants/sizes.dart';
import 'services/validator.service.dart';
import 'utils/ui_spacer.dart';
import 'view_models/login.view_model.dart';
import 'widgets/base.page.dart';
import 'widgets/buttons/custom_button.dart';
import 'widgets/buttons/custom_outline_button.dart';
import 'widgets/custom_text_form_field.dart';
import 'widgets/country_picker.dart';
import 'models/country.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'login/scan_login.view.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          isLoading: model.isBusy,
          showAppBar: false,
          elevation: 0,
          appBarItemColor: context.backgroundColor,
          appBarColor: context.backgroundColor,
          body: SafeArea(
            top: true,
            bottom: false,
            child: VStack([
                  UiSpacer.vSpace(8 * context.percentHeight),
                  
                  // Logo from assets
                  Container(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ).centered().py12(),
                  
                  // Welcome message
                  "Welcome Back".tr().text.xl2.semiBold.color(const Color(0xFFE91E63)).makeCentered().py8(),
                  "Login to your vendor app".tr().text.light.gray600.makeCentered().py8(),

                  //form
                  Form(
                    key: model.formKey,
                    child: VStack([
                      //
                      // Phone number field with country picker
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            CountryPicker(
                              selectedCountry: model.selectedCountry,
                              onCountryChanged: (country) {
                                model.updateSelectedCountry(country);
                              },
                              showFlag: true,
                              showName: false,
                              showPhoneCode: true,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: model.phoneTEC,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: "Phone Number",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: FormValidator.validatePhone,
                              ),
                            ),
                          ],
                        ),
                      ).py12(),
                      
                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.lock,
                                color: Color(0xFFE91E63),
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: model.passwordTEC,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: "Password",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: FormValidator.validatePassword,
                              ),
                            ),
                          ],
                        ),
                      ).py12(),

                      //
                      "Forgot Password ?".tr().text.underline.color(const Color(0xFFE91E63)).make().onInkTap(
                        model.openForgotPassword,
                      ).py8(),
                      //
                      CustomButton(
                        title: "Login".tr(),
                        loading: model.isBusy,
                        onPressed: model.processLogin,
                        color: const Color(0xFFE91E63),
                      ).centered().py12(),

                      20.heightBox,
                      ScanLoginView(model),

                      // Terms and Privacy Policy
                      HStack([
                        "By continuing, you agree to our".tr().text.sm.gray600.make(),
                      ]).centered().py8(),
                      
                      HStack([
                        "Terms & Conditions".tr().text.sm.underline.color(const Color(0xFFE91E63)).make().onInkTap(() {
                          // Navigate to terms page
                          Navigator.of(context).pushNamed('/terms');
                        }),
                        " and ".tr().text.sm.gray600.make(),
                        "Privacy Policy".tr().text.sm.underline.color(const Color(0xFFE91E63)).make().onInkTap(() {
                          // Navigate to privacy page
                          Navigator.of(context).pushNamed('/privacy');
                        }),
                      ]).centered().py4(),

                      //registration link
                      Visibility(
                        visible: AppStrings.partnersCanRegister,
                        child:
                            CustomOutlineButton(
                              title: "Don't have an account? Register".tr(),
                              onPressed: model.openRegistrationlink,
                              color: const Color(0xFFE91E63),
                            ).wFull(context).centered(),
                      ),
                    ], crossAlignment: CrossAxisAlignment.end),
                  ).py20(),
                ])
                .wFull(context)
                .p20()
                .scrollVertical()
                .pOnly(bottom: context.mq.viewInsets.bottom),
          ),
        );
      },
    );
  }
}
