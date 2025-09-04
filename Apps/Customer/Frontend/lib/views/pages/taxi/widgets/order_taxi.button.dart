import 'package:flutter/material.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/extensions/string.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/view_models/taxi.vm.dart';
import 'package:Classy/views/pages/cart/widgets/amount_tile.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/currency_hstack.dart';
import 'package:Classy/widgets/directional_chevron.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderTaxiButton extends StatelessWidget {
  const OrderTaxiButton(this.vm, {Key? key}) : super(key: key);

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = (vm.selectedVehicleType?.currency != null
        ? vm.selectedVehicleType?.currency?.symbol
        : AppStrings.currencySymbol);
    final textColor = Utils.textColorByTheme();
    //
    return Visibility(
      visible: vm.selectedVehicleType != null,
      child: VStack(
        [
          5.heightBox,
          //possible driver eta
          if (vm.possibleDriverETA != null)
            AmountTile(
              "Avg. Driver ETA".tr(),
              "~ ${vm.possibleDriverETA}" + "min(s)".tr() + "",
              amountStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ).px(12),

          //surge rate
          if (vm.selectedVehicleType != null &&
              vm.selectedVehicleType!.hasSurge)
            //show surge rate
            AmountTile(
              "Surge".tr(),
              "x${vm.selectedVehicleType!.surgeRate}",
              amountStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red,
              ),
            ).px(12),

          //
          5.heightBox,
          CustomButton(
            loading: vm.isBusy,
            shapeRadius: 16,
            isFixedHeight: false,
            height: context.percentHeight * 7,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: HStack(
                [
                  "Select Vehicle Type".tr().text.semiBold.color(textColor).xl.make().expand(),
                  UiSpacer.hSpace(10),
                  CurrencyHStack(
                    [
                      "${currencySymbol} "
                          .text
                          .bold
                          .color(textColor)
                          .xl2
                          .make(),
                      Visibility(
                        visible: (vm.subTotal > vm.total),
                        child: HStack(
                          [
                            "${vm.subTotal.currencyValueFormat()}"
                                .text
                                .color(textColor)
                                .medium
                                .lg
                                .lineThrough
                                .make(),
                            "${vm.total.currencyValueFormat()}"
                                .text
                                .color(textColor)
                                .semiBold
                                .xl2
                                .make(),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !(vm.subTotal > vm.total),
                        child: "${vm.total.currencyValueFormat()}"
                            .text
                            .color(textColor)
                            .bold
                            .xl2
                            .make(),
                      ),
                    ],
                  ),
                  //
                  DirectionalChevron()
                      .centered()
                      .box
                      .roundedFull
                      .color(textColor)
                      .make(),
                ],
                spacing: 10,
                crossAlignment: CrossAxisAlignment.center,
              ),
            ),
            onPressed:
                vm.selectedVehicleType != null ? vm.processNewOrder : null,
          ).wFull(context),
        ],
        spacing: 5,
      ),
    );
  }
}
