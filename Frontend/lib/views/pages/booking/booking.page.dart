import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/view_models/service.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:Classy/views/pages/vendor/widgets/section_products.view.dart';
import 'package:Classy/widgets/list_items/horizontal_product.list_item.dart';
import 'package:Classy/enums/product_fetch_data_type.enum.dart';
import 'package:Classy/models/search.dart';
import 'package:Classy/widgets/inputs/search_bar.input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class BookingPage extends StatefulWidget {
  const BookingPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with AutomaticKeepAliveClientMixin<BookingPage> {
  GlobalKey pageKey = GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ViewModelBuilder<ServiceViewModel>.reactive(
      viewModelBuilder: () => ServiceViewModel(context, widget.vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: !AppStrings.isSingleVendorMode,
          elevation: 0,
          title: "${widget.vendorType.name}",
          appBarColor: context.theme.colorScheme.surface,
          appBarItemColor: AppColor.primaryColor,
          showCart: true,
          key: pageKey,
          body: VStack(
            [
              // search bar
              SearchBarInput(
                hintText: 'Search services or providers',
                search: Search(
                  vendorType: widget.vendorType,
                  showServicesTag: true,
                  showVendorsTag: true,
                ),
              ).px12(),
              12.heightBox,
              // featured providers
              SectionVendorsView(
                widget.vendorType,
                title: 'Popular providers'.tr(),
                type: SearchFilterType.sales,
                scrollDirection: Axis.horizontal,
                byLocation: true,
                itemWidth: context.percentWidth * 60,
                spacer: 0,
              ),
              // available services
              SectionProductsView(
                widget.vendorType,
                title: 'Available services'.tr(),
                scrollDirection: Axis.vertical,
                type: ProductFetchDataType.BEST,
                byLocation: true,
                viewType: HorizontalProductListItem,
              ),
              12.heightBox,
            ],
          ).scrollVertical(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
