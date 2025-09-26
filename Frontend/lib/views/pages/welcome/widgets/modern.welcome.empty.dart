import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/constants/home_screen.config.dart';
import 'package:Classy/enums/product_fetch_data_type.enum.dart';
import 'package:Classy/models/search.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/view_models/welcome.vm.dart';
import 'package:Classy/views/pages/vendor/widgets/banners.view.dart';
import 'package:Classy/views/pages/vendor/widgets/section_products.view.dart';
import 'package:Classy/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:Classy/views/pages/welcome/widgets/welcome_header.section.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
// Wallet functionality removed - using Eversend, MoMo, and card payments only
import 'package:Classy/widgets/list_items/modern_vendor_type.vertical_list_item.dart';
import 'package:Classy/widgets/states/loading.shimmer.dart';
import 'package:Classy/views/shared/payment_method_selection.page.dart';
import 'package:Classy/models/payment_method.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:velocity_x/velocity_x.dart';

class ModernEmptyWelcome extends StatelessWidget {
  const ModernEmptyWelcome({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack([
      //
      WelcomeHeaderSection(vm),
      VStack([
            //finance section
            if (HomeScreenConfig.showWalletOnHomeScreen && vm.isAuthenticated())
              // Payment Methods - Clickable card that redirects to payment methods page
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: AppColor.primaryColor,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payment Methods",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Eversend, MoMo, Card",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ).onTap(() {
                _openPaymentMethodSelection(context);
              }).onInkTap(() {
                _openPaymentMethodSelection(context);
              }),

            //top banner
            if ((HomeScreenConfig.showBannerOnHomeScreen &&
                HomeScreenConfig.isBannerPositionTop))
              Banners(null, featured: true, padding: 0),
            //
            VStack([
              //gridview
              if (HomeScreenConfig.isVendorTypeListingGridView &&
                  vm.showGrid &&
                  vm.isBusy)
                LoadingShimmer().px20().centered(),

              CustomVisibilty(
                visible:
                    HomeScreenConfig.isVendorTypeListingGridView &&
                    vm.showGrid &&
                    !vm.isBusy,
                child: AnimationLimiter(
                  child: MasonryGrid(
                    column: HomeScreenConfig.vendorTypePerRow,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: List.generate(vm.vendorTypes.length, (index) {
                      final vendorType = vm.vendorTypes[index];
                      return ModernVendorTypeVerticalListItem(
                        vendorType,
                        onPressed: () {
                          NavigationService.pageSelected(
                            vendorType,
                            context: context,
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ]).px20(),

            //botton banner
            if (HomeScreenConfig.showBannerOnHomeScreen &&
                !HomeScreenConfig.isBannerPositionTop)
              Banners(null, featured: true),

            //featured vendors
            // FeaturedVendorsView(
            //   title: "Featured Vendors".tr(),
            //   scrollDirection: Axis.horizontal,
            //   itemWidth: context.percentWidth * 48,
            //   listViewPadding: Vx.mSymmetric(h: 20),
            //   titlePadding: Vx.(h: 20, v: 6),
            //   onSeeAllPressed: () {
            //     vm.openFeaturedVendors();
            //   },
            //   onVendorSelected: (vendor) {
            //     NavigationService.openVendorDetailsPage(
            //       vendor,
            //       context: context,
            //     );
            //   },
            // ),
            SectionVendorsView(
              null,
              title: "Featured Vendors".tr(),
              scrollDirection: Axis.horizontal,
              type: SearchFilterType.featured,
              itemWidth: context.percentWidth * 48,
              byLocation: AppStrings.enableFatchByLocation,
              hideEmpty: true,
              titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemsPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
            //featured products
            SectionProductsView(
              null,
              title: "Featured Products".tr(),
              scrollDirection: Axis.horizontal,
              type: ProductFetchDataType.featured,
              itemWidth: context.percentWidth * 42,
              byLocation: AppStrings.enableFatchByLocation,
              hideEmpty: true,
              itemsPadding: EdgeInsets.fromLTRB(20, 0, 20, 5),
              titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              listHeight: context.percentHeight * 20,
            ),
            //spacing
            100.heightBox,
          ], spacing: 16)
          .scrollVertical()
          .box
          .color(context.theme.colorScheme.surface)
          .make()
          .expand(),
    ]);
  }

  void _openPaymentMethodSelection(BuildContext context) async {
    // Create a list of available payment methods
    final List<PaymentMethod> paymentMethods = [
      PaymentMethod.eversend(),
      PaymentMethod.momo(),
      PaymentMethod.card(),
    ];

    // Navigate to the shared payment method selection page
    final selectedPaymentMethod = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentMethodSelectionPage(
          list: paymentMethods,
        ),
      ),
    );

    // Handle the selected payment method if needed
    if (selectedPaymentMethod != null) {
      print("Selected payment method: ${selectedPaymentMethod.name}");
    }
  }
}
