// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:Classy/constants/app_languages.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/custom_grid_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/extensions/context.dart';

class AppLanguageSelector extends StatefulWidget {
  const AppLanguageSelector({Key? key}) : super(key: key);

  @override
  State<AppLanguageSelector> createState() => _AppLanguageSelectorState();
}

class _AppLanguageSelectorState extends State<AppLanguageSelector> {
  String selectedLanguage = translator.activeLanguageCode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: VStack(
          [
            //
            HStack(
              [
                //close icon
                Icon(
                  Icons.close,
                  color: context.primaryColor,
                ).onInkTap(() {
                  context.pop();
                }),
                //
                "Select your preferred language"
                    .tr()
                    .text
                    .xl
                    .semiBold
                    .make()
                    .expand(),
              ],
              spacing: 20,
            ).py20().px12(),
            UiSpacer.divider(
              thickness: 0.2,
              height: 2,
            ),

            "You can change language later from the settings menu"
                .tr()
                .text
                .make()
                .px12()
                .py(10),

            //
            //
            CustomGridView(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(12),
              dataSet: AppLanguages.codes,
              itemBuilder: (ctx, index) {
                Widget widget = VStack(
                  [
                    //
                    Flag.fromString(
                      AppLanguages.flags[index],
                      height: 40,
                      width: 40,
                    ),
                    UiSpacer.verticalSpace(space: 5),
                    //
                    AppLanguages.names[index].tr().text.lg.make(),
                  ],
                  crossAlignment: CrossAxisAlignment.center,
                  alignment: MainAxisAlignment.center,
                ).card.roundedSM.color(context.canvasColor).make().onTap(() {
                  setState(() {
                    selectedLanguage = AppLanguages.codes[index];
                  });
                  //
                  _onLanguageTapped(
                    context,
                    AppLanguages.codes[index],
                  );
                });
                //add badge
                bool isSelected = selectedLanguage == AppLanguages.codes[index];
                if (isSelected) {
                  widget = Stack(
                    children: [
                      widget.wFull(context).hFull(context),
                      //check icon, top right
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 30,
                      ).positioned(
                        top: 0,
                        right: 0,
                      ),
                    ],
                  );
                }

                //
                return widget;
              },
            ).expand(),

            //add confirm button
            CustomButton(
              title: "Save".tr(),
              onPressed: () {
                _onSelected(context, selectedLanguage);
              },
            ).p12(),
          ],
        ),
      ),
    );
  }

  void _onLanguageTapped(
    BuildContext context,
    String code,
  ) async {
    print("🔧 Language tapped: $code");
    try {
      // Set the new language using the translator without restart
      print("🌐 Setting new language: $code");
      await translator.setNewLanguage(
        context,
        newLanguage: code,
        remember: true,
        restart: false, // Don't restart to allow immediate UI update
      );
      print("✅ Language set successfully");
      
      // Force a rebuild of the current widget
      if (mounted) {
        setState(() {
          selectedLanguage = code;
        });
      }
    } catch (error) {
      print("❌ Error in language selection: $error");
    }
  }

  void _onSelected(
    BuildContext context,
    String code, {
    bool complete = true,
  }) async {
    print("🔧 Language selection started with code: $code");
    try {
      print("📝 Setting locale...");
      await AuthServices.setLocale(code);
      print("✅ Locale set successfully");
      
      // Set the new language using the translator
      print("🌐 Setting new language: $code");
      await translator.setNewLanguage(
        context,
        newLanguage: code,
        remember: true,
        restart: false, // Don't restart to avoid navigation issues
      );
      print("✅ Language set successfully");
      
      print("📅 Setting Jiffy locale...");
      await Utils.setJiffyLocale();
      print("✅ Jiffy locale set successfully");
      
      // Force a rebuild of the current widget
      if (mounted) {
        setState(() {
          selectedLanguage = code;
        });
      }
      
      if (complete) {
        print("🚀 Navigating to login page...");
        // Navigate to login page after language selection
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.loginRoute,
          (Route<dynamic> route) => false,
        );
        print("✅ Navigation to login page completed");
      }
    } catch (error) {
      print("❌ Error in language selection: $error");
      print("❌ Error type: ${error.runtimeType}");
      print("❌ Error stack trace: ${StackTrace.current}");
      
      // Even if there's an error, try to navigate to login page
      try {
        print("🚀 Attempting navigation to login page despite error...");
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.loginRoute,
          (Route<dynamic> route) => false,
        );
        print("✅ Navigation to login page completed despite error");
      } catch (navError) {
        print("❌ Navigation error: $navError");
        // Last resort - just pop the current screen
        context.pop();
      }
    }
  }
}
