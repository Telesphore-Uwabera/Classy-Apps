import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/view_models/vendor/categories_services.vm.dart';
import 'package:Classy/views/pages/service/widgets/category_services.view.dart';
import 'package:Classy/widgets/states/loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoriesServicesView extends StatefulWidget {
  const CategoriesServicesView(
    this.vendorType, {
    Key? key,
    this.showTitle = true,
    this.maxCategories,
  }) : super(key: key);

  final VendorType vendorType;
  final bool showTitle;
  final int? maxCategories;

  @override
  _CategoriesServicesViewState createState() => _CategoriesServicesViewState();
}

class _CategoriesServicesViewState extends State<CategoriesServicesView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CategoriesServicesViewModel>.reactive(
      viewModelBuilder: () => CategoriesServicesViewModel(
        context,
        widget.vendorType,
        maxCategories: widget.maxCategories,
      ),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        //
        if (!vm.isBusy && vm.categories.isEmpty) {
          return SizedBox.shrink();
        }
        //
        return VStack(
          [
            //
            ...(vm.categories.map(
              (category) {
                return LoadingShimmer(
                  loading: vm.busy("category.${category.id}"),
                  child: CategoryServicesView(
                    category,
                    loading: vm.busy("category.${category.id}"),
                    hideEmpty: true,
                    showTitle: true,
                  ),
                );
              },
            ).toList()),
          ],
          spacing: 10,
        ).py12();
      },
    );
  }
}
