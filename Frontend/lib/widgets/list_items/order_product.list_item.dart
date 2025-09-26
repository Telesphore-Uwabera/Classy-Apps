import 'package:flutter/material.dart';
import 'package:Classy/extensions/dynamic.dart';
import 'package:Classy/extensions/string.dart';
import 'package:Classy/models/order.dart';
import 'package:Classy/models/order_product.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/views/pages/order/widgets/order_digitial_product_download.dart';
import 'package:Classy/widgets/bottomsheets/order_product_action.bottomsheet.dart';
import 'package:Classy/widgets/buttons/arrow_indicator.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/cards/rounded_container.dart';
import 'package:Classy/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderProductListItem extends StatelessWidget {
  const OrderProductListItem({
    required this.orderProduct,
    required this.order,
    Key? key,
  }) : super(key: key);

  final OrderProduct orderProduct;
  final Order order;
  @override
  Widget build(BuildContext context) {
    return VStack([
      //other status
      CustomVisibilty(
        visible: !order.isCommerce,
        child: HStack([
          RoundedContainer(
            child: CustomImage(
              imageUrl: orderProduct.product!.photo,
              width: 50,
              height: 50,
            ),
          ),

          VStack([
            //
            "${orderProduct.product!.name}".text.make(),
            Visibility(
              visible: orderProduct.options != null,
              child: "${orderProduct.options}".text.sm.gray500.medium.make(),
            ),
            //
            5.heightBox,
            //qty
            "x ${orderProduct.quantity}".text.bold.make(),
          ]).px12().expand(),
          "${AppStrings.currencySymbol}${orderProduct.price}"
              .currencyFormat()
              .text
              .semiBold
              .make(),
          //
        ]),
      ),

      //completed order
      CustomVisibilty(
        visible: order.isCommerce,
        child: VStack([
          HStack([
            //
            RoundedContainer(
              child: CustomImage(
                imageUrl: orderProduct.product!.photo,
                width: 60,
                height: 60,
              ),
            ),

            VStack([
              //
              orderProduct.product!.name.text.maxLines(2).ellipsis.light.make(),
              orderProduct.options.isNotEmptyAndNotNull
                  ? orderProduct.options!.text.sm.gray500.medium.make()
                  : UiSpacer.emptySpace(),

              HStack([
                //qty
                "Qty: %s"
                    .tr()
                    .fill([orderProduct.quantity])
                    .text
                    .semiBold
                    .make(),
                //
                UiSpacer.hSpace(15),
                //price
                "Price: %s"
                    .tr()
                    .fill([
                      "${AppStrings.currencySymbol}${orderProduct.price}"
                          .currencyFormat(),
                    ])
                    .text
                    .semiBold
                    .make(),
              ]),
            ]).px12().expand(),
            //
            UiSpacer.hSpace(6),
            ArrowIndicator(size: 26),
            //
          ]),
          UiSpacer.divider().py8(),
        ]).onInkTap(() => showOrderProductActions(context)),
      ),

      //download digital product
      DigitialProductOrderDownload(order, orderProduct),
    ], spacing: 15);
  }

  //
  showOrderProductActions(BuildContext context) {
    //show bottomsheet
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return OrderProductActionBottomSheet(orderProduct);
      },
    );
  }
}
