import 'package:flutter/material.dart';
import 'package:Classy/enums/product_fetch_data_type.enum.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/view_models/products.vm.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/custom_list_view.dart';
import 'package:Classy/widgets/list_items/commerce_product.list_item.dart';
import 'package:Classy/widgets/list_items/food_horizontal_product.list_item.dart';
import 'package:Classy/widgets/list_items/grid_view_product.list_item.dart';
import 'package:Classy/widgets/list_items/grocery_product.list_item.dart';
import 'package:Classy/widgets/list_items/horizontal_product.list_item.dart';
import 'package:Classy/widgets/section.title.dart';
import 'package:Classy/widgets/states/vendor.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SectionProductsView extends StatelessWidget {
  const SectionProductsView(
    this.vendorType, {
    this.title = "",
    this.scrollDirection = Axis.vertical,
    this.type = ProductFetchDataType.BEST,
    this.itemWidth,
    this.itemHeight,
    this.viewType,
    this.listHeight = 195,
    this.separator,
    this.byLocation = false,
    this.hideEmpty = false,
    this.itemsPadding,
    this.titlePadding,
    this.spacer,
    Key? key,
  }) : super(key: key);

  final VendorType? vendorType;
  final Axis scrollDirection;
  final ProductFetchDataType type;
  final String title;
  final double? itemWidth;
  final double? itemHeight;
  final dynamic viewType;
  final double? listHeight;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final double? spacer;
  final bool hideEmpty;

  @override
  Widget build(BuildContext context) {
    return CustomVisibilty(
      // visible: !AppStrings.enableSingleVendor,
      child: ViewModelBuilder<ProductsViewModel>.reactive(
        viewModelBuilder: () => ProductsViewModel(
          context,
          vendorType,
          type,
          byLocation: byLocation,
        ),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          //if not busy and list is empty && hideEmpty == true
          if (!model.isBusy && model.products.isEmpty && hideEmpty) {
            return 0.widthBox;
          }
          //listview
          Widget listView = CustomListView(
            scrollDirection: scrollDirection,
            padding: itemsPadding ?? EdgeInsets.symmetric(horizontal: 10),
            dataSet: model.products,
            isLoading: model.isBusy,
            noScrollPhysics: scrollDirection != Axis.horizontal,
            itemBuilder: (context, index) {
              //
              final product = model.products[index];
              Widget itemView;

              //
              if (viewType != null && viewType == HorizontalProductListItem) {
                itemView = HorizontalProductListItem(
                  product,
                  qtyUpdated: model.addToCartDirectly,
                  onPressed: model.productSelected,
                  height: itemHeight,
                );
              } else if (viewType != null &&
                  viewType == FoodHorizontalProductListItem) {
                itemView = FoodHorizontalProductListItem(
                  product,
                  qtyUpdated: model.addToCartDirectly,
                  onPressed: model.productSelected,
                  height: itemHeight,
                );
              } else if (viewType != null &&
                  viewType == GridViewProductListItem) {
                itemView = GridViewProductListItem(
                  product: product,
                  qtyUpdated: model.addToCartDirectly,
                  onPressed: model.productSelected,
                );
              } else {
                //grocery product list item
                if (product.vendor.vendorType.isGrocery) {
                  itemView = GroceryProductListItem(
                    product: product,
                    onPressed: model.productSelected,
                    qtyUpdated: model.addToCartDirectly,
                  );
                }
                //regular views
                itemView = CommerceProductListItem(
                  product,
                  height: 80,
                );
              }

              //
              if (itemWidth != null) {
                return itemView.w(itemWidth!);
              }
              return itemView;
            },
            emptyWidget: EmptyVendor(),
            separatorBuilder:
                separator != null ? (ctx, index) => separator! : null,
          );
          //
          return CustomVisibilty(
            visible: !model.isBusy && !model.products.isEmpty,
            child: VStack(
              [
                //
                Padding(
                  padding: titlePadding ?? EdgeInsets.symmetric(horizontal: 12),
                  child: SectionTitle("$title"),
                ),
                //
                if (model.products.isEmpty)
                  listView.h(240)
                else if (listHeight != null)
                  listView.h(listHeight!)
                else
                  listView
              ],
              spacing: spacer ?? 5,
            ),
          );

          //
        },
      ),
    );
  }
}
