import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/constants/home_screen.config.dart';
import 'package:Classy/constants/sizes.dart';
import 'package:Classy/models/search.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/welcome.vm.dart';
import 'package:Classy/views/pages/vendor/widgets/banners.view.dart';
import 'package:Classy/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/cards/welcome_intro.view.dart';
import 'package:Classy/widgets/custom_list_view.dart';
import 'package:Classy/widgets/finance/wallet_management.view.dart';
import 'package:Classy/widgets/list_items/vendor_type.list_item.dart';
import 'package:Classy/widgets/list_items/vendor_type.vertical_list_item.dart';
import 'package:Classy/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:velocity_x/velocity_x.dart';

class EmptyWelcome extends StatelessWidget {
  const EmptyWelcome({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack([
      // Keep header only; remove extra wallet/banner/sections for a clean welcome
      SafeArea(child: WelcomeIntroView(vm)),

      //
      // Leave rest of page empty for a clean hero-only welcome
    ])
        .box
        .color(AppColor.primaryColor)
        .make()
        .scrollVertical();
  }
}
