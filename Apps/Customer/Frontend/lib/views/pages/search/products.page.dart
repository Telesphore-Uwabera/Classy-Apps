import 'package:flutter/material.dart';
import 'package:Classy/constants/sizes.dart';
import 'package:Classy/enums/product_fetch_data_type.enum.dart';
import 'package:Classy/models/category.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/view_models/see_all_products.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/custom_dynamic_grid_view.dart';
import 'package:Classy/widgets/custom_list_view.dart';
import 'package:Classy/widgets/list_items/commerce_product.list_item.dart';
import 'package:Classy/widgets/list_items/grocery_product.list_item.dart';
import 'package:Classy/widgets/list_items/horizontal_product.list_item.dart';
import 'package:Classy/widgets/states/product.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ProducsPage extends StatelessWidget {
  const ProducsPage({
    required this.title,
    this.vendorType,
    this.type = ProductFetchDataType.RANDOM,
    this.category,
    this.showGrid = true,
    Key? key,
  }) : super(key: key);

  //
  final String title;
  final ProductFetchDataType type;
  final VendorType? vendorType;
  final Category? category;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SeeAllProductsViewModel>.reactive(
      viewModelBuilder: () => SeeAllProductsViewModel(
        context,
        type: type,
        category: category,
        vendorType: vendorType,
      ),
      onViewModelReady: (model) => model.startSearch(),
      disposeViewModel: false,
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: title,
          body: showGrid
              ? CustomDynamicHeightGridView(
                  noScrollPhysics: true,
                  refreshController: model.refreshController,
                  canRefresh: true,
                  canPullUp: true,
                  onRefresh: model.startSearch,
                  onLoading: () => model.startSearch(initialLoaoding: false),
                  isLoading: model.isBusy,
                  itemCount: model.products.length,
                  crossAxisSpacing: Sizes.paddingSizeDefault,
                  mainAxisSpacing: Sizes.paddingSizeDefault,
                  padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    final product = model.products[index];
                    return CommerceProductListItem(
                      product,
                      height: 80,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      Sizes.paddingSizeDefault.heightBox,
                  emptyWidget: EmptyProduct(),
                )
              : CustomListView(
                  refreshController: model.refreshController,
                  canRefresh: true,
                  canPullUp: true,
                  padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                  onRefresh: model.startSearch,
                  onLoading: () => model.startSearch(initialLoaoding: false),
                  isLoading: model.isBusy,
                  dataSet: model.products,
                  itemBuilder: (context, index) {
                    final product = model.products[index];

                    //grocery product list item
                    if (product.vendor.vendorType.isGrocery) {
                      return GroceryProductListItem(
                        product: product,
                        onPressed: model.productSelected,
                        qtyUpdated: model.addToCartDirectly,
                      );
                    } else if (product.vendor.vendorType.isCommerce) {
                      return CommerceProductListItem(
                        product,
                        height: 80,
                      );
                    } else {
                      //regular views
                      return HorizontalProductListItem(
                        product,
                        onPressed: model.productSelected,
                        qtyUpdated: model.addToCartDirectly,
                      );
                    }
                  },
                  separatorBuilder: (context, index) =>
                      Sizes.paddingSizeDefault.heightBox,
                  emptyWidget: EmptyProduct(),
                ),
        );
      },
    );
  }
}
