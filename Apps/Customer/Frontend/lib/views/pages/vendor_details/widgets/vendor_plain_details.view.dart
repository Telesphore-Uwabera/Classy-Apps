import 'package:flutter/material.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/vendor_details.vm.dart';
import 'package:Classy/views/pages/vendor_details/service_vendor_details.page.dart';
import 'package:Classy/views/pages/vendor_details/widgets/vendor_with_subcategory.view.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/bottomsheets/cart.bottomsheet.dart';
import 'package:Classy/widgets/buttons/custom_rounded_leading.dart';
import 'package:Classy/widgets/buttons/share.btn.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/cart_page_action.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorPlainDetailsView extends StatelessWidget {
  const VendorPlainDetailsView(this.model, {Key? key}) : super(key: key);
  final VendorDetailsViewModel model;
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      showCart: true,
      elevation: 0,
      extendBodyBehindAppBar: true,
      appBarColor: Colors.transparent,
      backgroundColor: context.theme.colorScheme.surface,
      leading: CustomRoundedLeading(),
      // fab: UploadPrescriptionFab(model),
      actions: [
        SizedBox(
          width: 50,
          height: 50,
          child: FittedBox(
            child: ShareButton(
              model: model,
            ),
          ),
        ),
        UiSpacer.hSpace(10),
        PageCartAction(),
      ],
      body: VStack(
        [
          //subcategories && hide for service vendor type
          CustomVisibilty(
            visible: (model.vendor!.hasSubcategories &&
                !model.vendor!.isServiceType),
            child: VendorDetailsWithSubcategoryPage(
              vendor: model.vendor!,
            ),
          ),

          //show for service vendor type
          CustomVisibilty(
            visible: model.vendor!.isServiceType,
            child: ServiceVendorDetailsPage(
              model,
              vendor: model.vendor!,
            ),
          ),
        ],
      ),
      //
      bottomSheet: CartViewBottomSheet(),
    );
  }
}
