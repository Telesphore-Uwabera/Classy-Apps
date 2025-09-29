import 'package:flutter/material.dart';
import 'package:Classy/models/order_product.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/product_details.vm.dart';
import 'package:Classy/views/pages/review/post_product_review.page.dart';
import 'package:Classy/widgets/buttons/arrow_indicator.dart';
import 'package:Classy/widgets/buttons/share.btn.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/extensions/context.dart';

class OrderProductActionBottomSheet extends StatelessWidget {
  const OrderProductActionBottomSheet(this.orderProduct, {Key? key})
    : super(key: key);

  //
  final OrderProduct orderProduct;

  //
  @override
  Widget build(BuildContext context) {
    return VStack([
          //
          UiSpacer.swipeIndicator(),
          UiSpacer.vSpace(15),
          HStack([
            //
            CustomImage(
              imageUrl: orderProduct.product!.photo,
              width: context.percentWidth * 30,
              height: context.percentWidth * 30,
            ),
            UiSpacer.hSpace(6),

            VStack([
              //
              orderProduct.product!.name.text
                  .maxLines(3)
                  .ellipsis
                  .semiBold
                  .make(),

              UiSpacer.vSpace(6),
              ShareButton(
                model: ProductDetailsViewModel(context, orderProduct.product!),
              ),
            ]).px12().expand(),
            //
          ]),
          UiSpacer.divider().py8(),
          HStack([
            "Buy it again".tr().text.medium.make().expand(),
            ArrowIndicator(size: 26),
          ]).py4().onInkTap(() {
            context.push(
              (context) => NavigationService().productDetailsPageWidget(
                orderProduct.product!,
              ),
            );
          }),
          UiSpacer.divider(),
          CustomVisibilty(
            visible: !orderProduct.reviewed,
            child: VStack([
              "How's your item?".tr().text.bold.make().py12(),
              UiSpacer.divider(),
              HStack([
                "Write a product review"
                    .tr()
                    .text
                    .medium
                    .make()
                    .px12()
                    .expand(),
                ArrowIndicator(size: 26),
              ]).py8().onInkTap(() {
                context.nextPage(PostProductReviewPage(orderProduct));
              }),
              UiSpacer.divider(),
            ]),
          ),
        ])
        .p20()
        .scrollVertical()
        .hThreeForth(context)
        .box
        .color(context.theme.colorScheme.surface)
        .topRounded()
        .make();
  }
}
