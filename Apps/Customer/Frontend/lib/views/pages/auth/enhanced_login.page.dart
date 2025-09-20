import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/login.view_model.dart';
import 'package:Classy/views/pages/auth/login/phone_password_login.view.dart';
import 'package:Classy/widgets/custom_text_form_field.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/arrow_indicator.dart';
import 'package:Classy/widgets/dynamic_status_bar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class EnhancedLoginPage extends StatefulWidget {
  EnhancedLoginPage({this.required = false, Key? key}) : super(key: key);

  final bool required;
  @override
  _EnhancedLoginPageState createState() => _EnhancedLoginPageState();
}

class _EnhancedLoginPageState extends State<EnhancedLoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Only phone/password login
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicStatusBar(
      baseColor: Colors.white,
      child: ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return PopScope(
            canPop: !widget.required,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              if (widget.required) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "You are required to login/register to continue process".tr(),
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.welcomeRoute,
                  (route) => false,
                );
              }
            },
            child: BasePage(
              showLeadingAction: !widget.required,
              showAppBar: !widget.required,
              appBarColor: AppColor.faintBgColor,
              leading: IconButton(
                icon: ArrowIndicator(leading: true),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.welcomeRoute,
                      (route) => false,
                    );
                  }
                },
              ),
              elevation: 0,
              isLoading: model.isBusy,
              body: SafeArea(
                top: true,
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: context.mq.viewInsets.bottom,
                  ),
                  child: VStack([
                    // Header Section
                    VStack([
                      // Logo and Title
                      VStack([
                        Image.asset(AppImages.appLogo).h(96).w(96).centered(),
                        16.heightBox,
                        "Welcome Back".tr().text.xl3.semiBold.color(AppColor.primaryColor).makeCentered(),
                        6.heightBox,
                        "Login to your customer account"
                            .tr()
                            .text
                            .lg
                            .light
                            .makeCentered(),
                      ]),

                    ]).wFull(context).px20().pOnly(top: Vx.dp20),

                    // Login Form
                    Expanded(
                      child: _buildPhonePasswordTab(model),
                    ),

                    // Footer
                    _buildFooter(model),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhonePasswordTab(LoginViewModel model) {
    return VStack([
      // Phone + Password Login Form
      PhonePasswordLoginView(model),
    ]).scrollVertical();
  }

  // Social login removed - only phone/password login available

  Widget _buildFooter(LoginViewModel model) {
    return VStack([
      // Terms and Privacy Policy
      "By continuing, you agree to our".tr().text.sm.makeCentered().py8(),
      
      HStack([
        "Terms & Conditions".tr().text.sm.underline.color(AppColor.primaryColor).make().onInkTap(() {
          Navigator.of(context).pushNamed(AppRoutes.termsConditionsRoute);
        }),
        " and ".tr().text.sm.make(),
        "Privacy Policy".tr().text.sm.underline.color(AppColor.primaryColor).make().onInkTap(() {
          Navigator.of(context).pushNamed(AppRoutes.privacyPolicyRoute);
        }),
      ]).centered().py4(),

      // Register Link
      "New user?".richText
          .withTextSpanChildren([
            " ".textSpan.make(),
            "Create An Account"
                .tr()
                .textSpan
                .semiBold
                .color(AppColor.primaryColor)
                .make(),
          ])
          .makeCentered()
          .py12()
          .onInkTap(model.openRegister),
    ]).px20().py16();
  }
}
