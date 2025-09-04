import 'package:flutter/material.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/view_models/vendor/categories.vm.dart';
import 'package:Classy/views/pages/service/widgets/modern_category_gridview.list_item.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/custom_dynamic_grid_view.dart';
// import 'package:Classy/widgets/custom_masonry_grid_view.dart';
import 'package:Classy/widgets/list_items/category.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
// import 'package:velocity_x/velocity_x.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({this.vendorType, Key? key}) : super(key: key);

  final VendorType? vendorType;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CategoriesViewModel>.reactive(
      viewModelBuilder:
          () => CategoriesViewModel(context, vendorType: vendorType),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showCart: true,
          showLeadingAction: true,
          title: "Categories".tr(),
          body:
          /*
          CustomMasonryGridView(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: AppStrings.categoryPerRow,
            isLoading: vm.isBusy,
            dynamicSide: Axis.horizontal,
            canRefresh: true,
            refreshController: vm.refreshController,
            onRefresh: () => vm.loadCategories(),
            padding: EdgeInsets.all(12),
            items: List.generate(
              vm.categories.length,
              (index) {
                final category = vm.categories[index];
                return CategoryListItem(
                  category: category,
                  onPressed: vm.categorySelected,
                  maxLine: false,
                  inverted: true,
                  // textColor: Utils.textColorByBrightness(),
                ).wFull(context);
              },
            ),
          ),
*/
          CustomDynamicHeightGridView(
            noScrollPhysics: true,
            crossAxisCount:
                (vm.vendorType?.isService ?? false)
                    ? 2
                    : AppStrings.categoryPerRow,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            isLoading: vm.isBusy,
            itemCount: vm.categories.length,
            canRefresh: true,
            refreshController: vm.refreshController,
            onRefresh: () => vm.loadCategories(),
            padding: EdgeInsets.all(20),
            itemBuilder: (context, index) {
              if (vm.vendorType?.isService ?? false) {
                return ModernCategoryGridviewListItem(
                  category: vm.categories[index],
                  onPressed: vm.categorySelected,
                );
              }
              return CategoryListItem(
                category: vm.categories[index],
                onPressed: vm.categorySelected,
                maxLine: false,
                textColor: Utils.textColorByBrightness(),
              );
            },
          ),
        );
      },
    );
  }
}
