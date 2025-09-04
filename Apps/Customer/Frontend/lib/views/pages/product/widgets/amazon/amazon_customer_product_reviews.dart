import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:Classy/models/product.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/view_models/product_review.vm.dart';
import 'package:Classy/views/pages/product/widgets/amazon/product_review_sumup.view.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/custom_list_view.dart';
import 'package:Classy/widgets/list_items/product_review.list_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class AmazonCustomerProductReview extends StatelessWidget {
  const AmazonCustomerProductReview({
    required this.product,
    Key? key,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductReviewViewModel>.reactive(
      viewModelBuilder: () => ProductReviewViewModel(context, product, true),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return VStack(
          [
            //review summary
            HStack(
              [
                ProductReviewSumupView(product).expand(),

                //arrow
                Icon(
                  Utils.isArabic
                      ? FlutterIcons.chevron_left_fea
                      : FlutterIcons.chevron_right_fea,
                  size: 32,
                ),
              ],
              crossAlignment: CrossAxisAlignment.center,
            ).onTap(
              () => vm.openAllReviews(),
            ),

            UiSpacer.divider().py12(),
            //recent reviews
            CustomListView(
              noScrollPhysics: true,
              isLoading: vm.busy(vm.productReviews),
              dataSet: vm.productReviews,
              itemBuilder: (ctx, index) {
                final productReview = vm.productReviews[index];
                return ProductReviewListItem(productReview);
              },
            ),

            CustomVisibilty(
              visible: vm.productReviews.isNotEmpty,
              child: CustomButton(
                child: HStack(
                  [
                    "Sell all reviews".text.xl.semiBold.make().expand(),
                    Icon(
                      Utils.isArabic
                          ? FlutterIcons.chevron_left_fea
                          : FlutterIcons.chevron_right_fea,
                    ),
                  ],
                ),
                onPressed: () => vm.openAllReviews(),
                height: 50,
              ).wFull(context).py12(),
            ),
          ],
        );
      },
    );
  }
}
