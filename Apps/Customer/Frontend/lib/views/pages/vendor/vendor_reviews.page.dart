import 'package:flutter/material.dart';
import 'package:Classy/models/vendor.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorReviewsPage extends StatelessWidget {
  const VendorReviewsPage(this.vendor, {Key? key}) : super(key: key);

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Reviews",
      body: VStack([
        "Reviews for ${vendor.name}".text.xl.bold.make().px20().py16(),
        "Reviews coming soon".text.make().px20().py8(),
      ]).scrollVertical(),
    );
  }
}
