import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorHeader extends StatelessWidget {
  const VendorHeader(
    this.vendorType, {
    Key? key,
    this.model,
    this.onrefresh,
    this.showSearch,
    this.bottomPadding,
  }) : super(key: key);

  final VendorType vendorType;
  final dynamic model;
  final VoidCallback? onrefresh;
  final bool? showSearch;
  final bool? bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: VStack([
        vendorType.name.text.xl.bold.make(),
        "Header content coming soon".text.make(),
      ]),
    ).px20().py8();
  }
}
