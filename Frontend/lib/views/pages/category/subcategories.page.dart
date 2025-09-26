import 'package:flutter/material.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/category.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/view_models/vendor/sub_categories.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/custom_dynamic_grid_view.dart';
import 'package:Classy/widgets/list_items/category.list_item.dart';
import 'package:Classy/widgets/states/subcategories.empty.dart';
import 'package:stacked/stacked.dart';

class SubcategoriesPage extends StatelessWidget {
  const SubcategoriesPage({
    required this.category,
    Key? key,
  }) : super(key: key);

  final Category category;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SubcategoriesViewModel>.reactive(
      viewModelBuilder: () => SubcategoriesViewModel(context, category),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showCart: true,
          showLeadingAction: true,
          title: category.name,
          body: CustomDynamicHeightGridView(
            noScrollPhysics: true,
            crossAxisCount: AppStrings.categoryPerRow,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            isLoading: vm.isBusy,
            itemCount: vm.subcategories.length,
            canRefresh: true,
            refreshController: vm.refreshController,
            onRefresh: () => vm.loadSubcategories(),
            padding: EdgeInsets.all(12),
            emptyWidget: EmptySubcategoriesView(),
            itemBuilder: (context, index) {
              return CategoryListItem(
                category: vm.subcategories[index],
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
