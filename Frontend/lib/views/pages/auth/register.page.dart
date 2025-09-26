import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/services/validator.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/register.view_model.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/arrow_indicator.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({this.email, this.name, this.phone, Key? key}) : super(key: key);

  final String? email;
  final String? name;
  final String? phone;
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (model) {
        model.nameTEC.text = widget.name ?? "";
        model.emailTEC.text = widget.email ?? "";
        model.phoneTEC.text = widget.phone ?? "";
        model.initialise();
      },
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
                    Image.asset(AppImages.appLogo).h(96).w(96).centered(),
                    12.heightBox,
                    "Create Account".tr().text.xl3.semiBold.makeCentered(),
                    6.heightBox,
                    "Create your customer account".tr().text.lg.light.makeCentered(),
                    16.heightBox,
                    VStack([
                      "Join Us".tr().text.xl2.semiBold.make(),
                      "Create an account now".tr().text.light.make(),

                      //form
                      Form(
                        key: model.formKey,
                        child: VStack([
                          //
                          CustomTextFormField(
                            labelText: "Name".tr(),
                            textEditingController: model.nameTEC,
                            validator: FormValidator.validateName,
                          ).py12(),
                          //
                          CustomTextFormField(
                            labelText: "Email (Optional)".tr(),
                            keyboardType: TextInputType.emailAddress,
                            textEditingController: model.emailTEC,
                            validator: FormValidator.validateEmail,
                            //remove space
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(' '),
                              ), // removes spaces
                            ],
                          ).py12(),
                          //
                          HStack([
                            CustomTextFormField(
                              prefixIcon: HStack([
                                //icon/flag
                                Flag.fromString(
                                  model.selectedCountry!.countryCode,
                                  width: 20,
                                  height: 20,
                                ),
                                UiSpacer.horizontalSpace(space: 5),
                                //text
                                ("+" + model.selectedCountry!.phoneCode).text
                                    .make(),
                              ]).px8().onInkTap(model.showCountryDialPicker),
                              labelText: "Phone".tr(),
                              hintText: "",
                              keyboardType: TextInputType.phone,
                              textEditingController: model.phoneTEC,
                              validator: FormValidator.validatePhone,
                              //remove space
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(' '),
                                ), // removes spaces
                              ],
                            ).expand(),
                          ]).py12(),
                          //
                          CustomTextFormField(
                            labelText: "Password".tr(),
                            obscureText: true,
                            textEditingController: model.passwordTEC,
                            validator: FormValidator.validatePassword,
                            //remove space
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(' '),
                              ), // removes spaces
                            ],
                          ).py12(),
                          //
                          AppStrings.enableReferSystem
                              ? CustomTextFormField(
                                labelText: "Referral Code(optional)".tr(),
                                textEditingController: model.referralCodeTEC,
                              ).py12()
                              : UiSpacer.emptySpace(),

                          //terms
                          HStack([
                            Checkbox(
                              value: model.agreed,
                              onChanged: (value) {
                                model.agreed = value ?? false;
                                model.notifyListeners();
                              },
                            ),
                            //
                            "I agree with".tr().text.make(),
                            UiSpacer.horizontalSpace(space: 2),
                            "Terms & Conditions"
                                .tr()
                                .text
                                .color(AppColor.primaryColor)
                                .bold
                                .underline
                                .make()
                                .onInkTap(() {
                                  Navigator.of(context).pushNamed(AppRoutes.termsConditionsRoute);
                                })
                                .expand(),
                          ]),
                          
                          // Privacy Policy Link
                          HStack([
                            "and ".tr().text.make(),
                            "Privacy Policy"
                                .tr()
                                .text
                                .color(AppColor.primaryColor)
                                .bold
                                .underline
                                .make()
                                .onInkTap(() {
                                  Navigator.of(context).pushNamed(AppRoutes.privacyPolicyRoute);
                                }),
                          ]).px32().py8(),

                          //
                          CustomButton(
                            title: "Create Account".tr(),
                            loading:
                                model.isBusy ||
                                model.busy(model.firebaseVerificationId),
                            onPressed: model.processRegister,
                          ).centered().py12(),

                          //register
                          "OR".tr().text.light.makeCentered(),
                          "Already have an Account"
                              .tr()
                              .text
                              .semiBold
                              .makeCentered()
                              .py12()
                              .onInkTap(model.openLogin),
                        ], crossAlignment: CrossAxisAlignment.end),
                      ).py20(),
                    ]).wFull(context).p20(),

                    //
                  ]).scrollVertical(),
            ),
          ),
          // No bottom nav here; HomePage owns the global bar
        );
      },
    );
  }
}
