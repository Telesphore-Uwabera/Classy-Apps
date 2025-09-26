import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/view_models/welcome.vm.dart';
import 'package:Classy/views/pages/welcome/widgets/welcome_simple_header.section.dart';
import 'package:Classy/widgets/custom_image.view.dart';
import 'package:Classy/widgets/dynamic_status_bar.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WelcomeIntroView extends StatelessWidget {
  const WelcomeIntroView(this.vm, {Key? key}) : super(key: key);
  final WelcomeViewModel vm;
  
  Widget _buildLogo() {
    const double size = 120;
    return FutureBuilder<String>(
      future: rootBundle
          .loadString('assets/images/logo.enc')
          .catchError((_) => ''),
      builder: (context, snapshot) {
        try {
          if (snapshot.hasData && (snapshot.data ?? '').trim().isNotEmpty) {
            final bytes = base64Decode(snapshot.data!.trim());
            return Image.memory(bytes, width: size, height: size)
                .box
                .roundedFull
                .color(Colors.white.withOpacity(0.1))
                .p16
                .makeCentered();
          }
        } catch (_) {}
        return Image.asset(
          AppImages.appLogo,
          width: size,
          height: size,
        )
            .box
            .roundedFull
            .color(Colors.white.withOpacity(0.1))
            .p16
            .makeCentered();
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return DynamicStatusBar(
      baseColor: context.backgroundColor,
      child: VStack([
        //
        new WelcomeSimpleHeaderSection(vm),
        VStack([
          //welcome intro and loggedin account name
          StreamBuilder(
            stream: AuthServices.listenToAuthState(),
            builder: (ctx, snapshot) {
              //
              String introText = "Welcome back".tr();
              String fullIntroText = introText;
              //
              if (snapshot.hasData) {
                return FutureBuilder<User>(
                  future: AuthServices.getCurrentUser(),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasData) {
                      fullIntroText = "$introText, ${snapshot.data?.name}";

                      final user = snapshot.data;
                      return HStack([
                        CustomImage(
                          imageUrl: user!.photo,
                        ).box.roundedFull.shadowSm.make().wh(50, 50),
                        UiSpacer.hSpace(15),
                        //
                        VStack([
                          //name
                          fullIntroText.text
                              .color(Utils.textColorByTheme())
                              .xl
                              .semiBold
                              .make(),
                          //email
                          "${user.email}"
                              .hidePartial(
                                begin: 3,
                                end: "${user.email}".length - 8,
                              )!
                              .text
                              .color(Utils.textColorByTheme())
                              .sm
                              .thin
                              .make(),
                        ]),
                      ]).pOnly(bottom: 10);
                    } else {
                      //auth but not data received
                      return fullIntroText.text.white.xl3.semiBold.make();
                    }
                  },
                );
              }
              return VStack([
                _buildLogo(),
                16.heightBox,
                "Welcome to Classy"
                    .tr()
                    .text
                    .color(Utils.textColorByTheme())
                    .xl4
                    .bold
                    .make(),
                8.heightBox,
                "Your premium ride-sharing & delivery app"
                    .tr()
                    .text
                    .color(Utils.textColorByTheme())
                    .xl
                    .light
                    .make(),
                24.heightBox,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.loginRoute),
                    child: Text("Log In".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
                12.heightBox,
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.registerRoute),
                    child: Text(
                      "Create Account".tr(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ]).pOnly(bottom: 10);
            },
          ),
          //
          "How can I help you today?".tr().text.color(Utils.textColorByTheme()).xl2.semiBold.make(),
          30.heightBox,
        ])
            .px20()
            .box
            // Natural height to avoid flex/overflow issues
            .make(),
      ], spacing: 10),
    );
  }
}
