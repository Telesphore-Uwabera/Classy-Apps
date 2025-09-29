import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/services/location.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/welcome.vm.dart';
import 'package:Classy/views/pages/notifications/notifications_page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WelcomeHeaderSection extends StatelessWidget {
  const WelcomeHeaderSection(
    this.vm, {
    Key? key,
  }) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        // Icon(
        //   FlutterIcons.location_pin_ent,
        //   size: 24,
        // ),
        // UiSpacer.hSpace(5),
        Container(
          //add a max constraint of 50% of the screen width
          constraints: BoxConstraints(maxWidth: context.screenWidth * 0.65),
          child: VStack(
            [
              "Deliver To".tr().text.lg.semiBold.make(),
              HStack(
                [
                  StreamBuilder<DeliveryAddress?>(
                    stream: LocationService.currenctDeliveryAddressSubject,
                    initialData: vm.deliveryaddress,
                    builder: (conxt, snapshot) {
                      return "${snapshot.data?.address ?? ""}"
                          .text
                          .maxLines(1)
                          .ellipsis
                          .base
                          // .color(Utils.greayColorByBrightness(context))
                          .make();
                    },
                  ).flexible(),
                  Icon(
                    FlutterIcons.chevron_thin_down_ent,
                    size: 14,
                  ),
                ],
                spacing: 4,
              ).flexible(),
              UiSpacer.hSpace(5),
            ],
          ).onTap(
            () async {
              await onLocationSelectorPressed();
            },
          ),
        ),
        Spacer(),
        Icon(
          SimpleLineIcons.bell,
          size: 20,
          color: context.primaryColor,
        ).onInkTap(
          () {
            context.nextPage(NotificationsPage());
          },
        ),
      ],
      spacing: 10,
    )
        .px12()
        .py16()
        .safeArea()
        .box
        // Force brand color band (pink) instead of any default blue
        .color(AppColor.primaryColor)
        .make()
        .wFull(context);
  }

  Future<void> onLocationSelectorPressed() async {
    try {
      vm.pickDeliveryAddress(onselected: () {
        vm.pageKey = GlobalKey<State>();
        vm.notifyListeners();
      });
    } catch (error) {
      AlertService.stopLoading();
    }
  }
}
