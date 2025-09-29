import 'dart:io';

import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/enums/product_fetch_data_type.enum.dart';
import 'package:Classy/models/category.dart';
import 'package:Classy/models/search.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/products.vm.dart';
import 'package:Classy/views/pages/search/search.page.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/custom_list_view.dart';
import 'package:Classy/widgets/custom_masonry_grid_view.dart';
import 'package:Classy/widgets/list_items/commerce_product.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/extensions/context.dart';

class ProductsSectionView extends StatelessWidget {
  const ProductsSectionView(
    this.title, {
    this.vendorType,
    this.category,
    this.type = ProductFetchDataType.RANDOM,
    this.showGrid = true,
    this.crossAxisCount,
    this.scrollDirection,
    this.itemBottomPadding,
    this.itemHeight,
    this.titleCapitalize = true,
    this.onSeeAllPressed,
    this.maxHeight,
    Key? key,
  }) : super(key: key);

  final String title;
  final VendorType? vendorType;
  final ProductFetchDataType type;
  final Category? category;
  final bool showGrid;
  final int? crossAxisCount;
  final Axis? scrollDirection;
  final double? itemBottomPadding;
  final double? itemHeight;
  final bool titleCapitalize;
  final Function? onSeeAllPressed;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductsViewModel>.reactive(
      viewModelBuilder: () => ProductsViewModel(
        context,
        vendorType,
        type,
        categoryId: category?.id,
      ),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return CustomVisibilty(
          visible: !model.isBusy && model.products.isNotEmpty,
          child: VStack(
            [
              //
              HStack(
                [
                  (!titleCapitalize ? "$title" : "$title".toUpperCase())
                      .text
                      .semiBold
                      .xl
                      .make()
                      .expand(),
                  UiSpacer.horizontalSpace(),
                  HStack(
                    [
                      "See all"
                          .tr()
                          .text
                          .lg
                          .medium
                          .color(AppColor.primaryColor)
                          .make(),
                      // UiSpacer.smHorizontalSpace(),
                      // Icon(
                      //   Utils.isArabic
                      //       ? FlutterIcons.arrow_left_evi
                      //       : FlutterIcons.arrow_right_evi,
                      // ),
                    ],
                  ).onInkTap(
                    () {
                      if (onSeeAllPressed != null) {
                        onSeeAllPressed!();
                      } else {
                        openSearchPage(context);
                      }
                    },
                  ),
                ],
              )
                  // .box
                  // .p12
                  // .color(context.theme.colorScheme.surface)
                  // .outerShadowSm
                  // .roundedSM
                  // .make()
                  .wFull(context),
              UiSpacer.vSpace(10),
              CustomVisibilty(
                visible: !showGrid,
                child: CustomListView(
                  isLoading: model.isBusy,
                  dataSet: model.products,
                  scrollDirection: scrollDirection ?? Axis.horizontal,
                  separatorBuilder:
                      (scrollDirection ?? Axis.horizontal) == Axis.horizontal
                          ? (_, __) => 12.widthBox
                          : null,
                  itemBuilder: (context, index) {
                    final product = model.products[index];
                    return FittedBox(
                      child: CommerceProductListItem(
                        product,
                        height: 80,
                      )
                          .w(context.percentWidth * 35)
                          .pOnly(bottom: itemBottomPadding ?? 0),
                    );
                  },
                ).h(itemHeight ?? (Platform.isAndroid ? 160 : 190)),
              ),
              CustomVisibilty(
                visible: showGrid,
                child: CustomMasonryGridView(
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  crossAxisCount: crossAxisCount ?? 2,
                  isLoading: model.isBusy,
                  items: List.generate(
                    model.products.length,
                    (index) {
                      //
                      final product = model.products[index];
                      return Container(
                        constraints: BoxConstraints(
                          maxHeight: maxHeight ?? double.infinity,
                        ),
                        child: CommerceProductListItem(
                          product,
                          // height: 120,
                          boxFit: BoxFit.cover,
                        ).wFull(context),
                      );
                    },
                  ),
                ),
              ),
            ],
          ).py12(),
        );
      },
    );
  }

  //
  openSearchPage(BuildContext context) {
    //
    final search = Search(
      type: type.name,
      category: category,
      vendorType: vendorType,
      showProductsTag: true,
      productDataFetchType: type,
      // showType: 2,
    );
    //open search
    context.push(
      (context) => SearchPage(
        search: search,
      ),
    );
  }
}
