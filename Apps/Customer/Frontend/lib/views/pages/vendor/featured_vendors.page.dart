import 'package:flutter/material.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';

class FeaturedVendorsPage extends StatelessWidget {
  const FeaturedVendorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Featured Vendors",
      body: VStack([
        "Featured Vendors".text.xl.bold.make().px20().py16(),
        "Featured vendors coming soon".text.make().px20().py8(),
      ]).scrollVertical(),
    );
  }
}
