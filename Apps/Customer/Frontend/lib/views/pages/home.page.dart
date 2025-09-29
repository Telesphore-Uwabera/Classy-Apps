import 'package:Classy/utils/platform_utils.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_ui_settings.dart';
import 'package:Classy/constants/app_upgrade_settings.dart';
import 'package:Classy/services/location.service.dart';
import 'package:Classy/views/pages/profile/profile.page.dart';
import 'package:Classy/view_models/home.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';

import 'booking/booking.page.dart';
import 'search/main_search.page.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;
  late HomeViewModel vm;
  @override
  void initState() {
    super.initState();
    //
    vm = HomeViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LocationService.currenctAddress == null) {
        LocationService.prepareLocationListener(true);
      }
      vm.initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => vm,
        builder: (context, model, child) {
          return BasePage(
            // extendBodyBehindAppBar: false,
            backgroundColor: AppColor.faintBgColor,
            body: SafeArea(
              child: UpgradeAlert(
                showIgnore: !AppUpgradeSettings.forceUpgrade(),
                shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
                dialogStyle:
                    PlatformUtils.isIOS
                        ? UpgradeDialogStyle.cupertino
                        : UpgradeDialogStyle.material,
                upgrader: Upgrader(),
                child: model.homeView,
              ),
            ),

          );
        },
      ),
    );
  }
}
