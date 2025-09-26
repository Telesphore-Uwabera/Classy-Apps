import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/home_screen.config.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/location.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/view_models/welcome.vm.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/custom_image.view.dart';
// Wallet functionality removed - using Eversend, MoMo, and card payments only
import 'package:Classy/widgets/inputs/search_bar.input.dart';
import 'package:Classy/views/shared/payment_method_selection.page.dart';
import 'package:Classy/models/payment_method.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PlainWelcomeHeaderSection extends StatelessWidget {
  const PlainWelcomeHeaderSection(this.vm, {Key? key}) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack([
          //location section
          HStack([
            HStack([
              Icon(
                FlutterIcons.location_pin_ent,
                size: 24,
                color: Utils.textColorByTheme(),
              ),
              UiSpacer.hSpace(5),
              VStack([
                "Deliver To"
                    .tr()
                    .text
                    .thin
                    .light
                    .color(Utils.textColorByPrimaryColor())
                    .sm
                    .make(),
                StreamBuilder<DeliveryAddress?>(
                  stream: LocationService.currenctDeliveryAddressSubject,
                  initialData: vm.deliveryaddress,
                  builder: (conxt, snapshot) {
                    return "${snapshot.data?.address ?? ""}".text
                        .maxLines(1)
                        .ellipsis
                        .base
                        .color(Utils.textColorByPrimaryColor())
                        .make();
                  },
                ).flexible(),
              ]).flexible(),
              UiSpacer.hSpace(5),
              Icon(
                FlutterIcons.chevron_down_ent,
                size: 20,
                color: Utils.textColorByTheme(),
              ),
            ]).expand(),

            UiSpacer.hSpace(),
            //profile is login
            StreamBuilder<dynamic>(
              stream: AuthServices.listenToAuthState(),
              initialData: false,
              builder: (ctx, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data is bool &&
                    snapshot.data) {
                  return CustomImage(
                        imageUrl: AuthServices.currentUser?.photo ?? "",
                      )
                      .wh(35, 35)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make()
                      .onInkTap(() {
                        AppService().homePageIndex.add(3);
                      });
                } else {
                  return UiSpacer.emptySpace();
                }
              },
            ),
          ]).onTap(() async {
            await onLocationSelectorPressed();
          }),

          //search button
          UiSpacer.vSpace(),
          SearchBarInput(
            onTap: () {
              AppService().homePageIndex.add(2);
            },
          ),
          UiSpacer.vSpace(5),

          //wallet UI for login user
          //finance section
          StreamBuilder<dynamic>(
            stream: AuthServices.listenToAuthState(),
            initialData: false,
            builder: (ctx, snapshot) {
              if (snapshot.hasData && snapshot.data is bool && snapshot.data) {
                return CustomVisibilty(
                  visible: HomeScreenConfig.showWalletOnHomeScreen,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payment,
                          color: AppColor.primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Payment Methods",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Eversend, MoMo, Card",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ).py(15).onTap(() {
                    _openPaymentMethodSelection(context);
                  }).onInkTap(() {
                    _openPaymentMethodSelection(context);
                  }),
                );
              } else {
                return UiSpacer.emptySpace();
              }
            },
          ),

          //
          UiSpacer.vSpace(40),
        ])
        .wFull(context)
        .safeArea()
        .p12()
        .box
        .bottomRounded(value: 25)
        .color(AppColor.primaryColor)
        .make();
  }

  Future<void> onLocationSelectorPressed() async {
    try {
      vm.pickDeliveryAddress(
        onselected: () {
          vm.pageKey = GlobalKey<State>();
          vm.notifyListeners();
        },
      );
    } catch (error) {
      AlertService.stopLoading();
    }
  }

  void _openPaymentMethodSelection(BuildContext context) async {
    // Create a list of available payment methods
    final List<PaymentMethod> paymentMethods = [
      PaymentMethod.eversend(),
      PaymentMethod.momo(),
      PaymentMethod.card(),
    ];

    // Navigate to the shared payment method selection page
    final selectedPaymentMethod = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentMethodSelectionPage(
          list: paymentMethods,
        ),
      ),
    );

    // Handle the selected payment method if needed
    if (selectedPaymentMethod != null) {
      print("Selected payment method: ${selectedPaymentMethod.name}");
    }
  }
}
