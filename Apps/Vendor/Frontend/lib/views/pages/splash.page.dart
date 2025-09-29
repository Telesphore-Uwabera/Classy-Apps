import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/view_models/splash.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: ViewModelBuilder<SplashViewModel>.reactive(
        viewModelBuilder: () => SplashViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, model, child) {
          return Container(
            color: const Color(0xFFE91E63), // Pink background like in screenshot
            child: VStack(
              [
                //
                // Logo from assets
                Container(
                  width: context.percentWidth * 45,
                  height: context.percentWidth * 45,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ).centered().py12(),
                
                // Loading text
                "Loading...".tr().text.white.xl2.semiBold.makeCentered().py12(),
                
                // Progress bar
                Container(
                  width: context.percentWidth * 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    value: 0.2, // Show some progress
                  ),
                ).py12(),
              ],
            ).centered(),
          );
        },
      ),
    );
  }
}
