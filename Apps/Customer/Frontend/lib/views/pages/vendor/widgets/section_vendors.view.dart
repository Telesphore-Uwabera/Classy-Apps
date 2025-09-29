import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:velocity_x/velocity_x.dart';

class SectionVendorsView extends StatelessWidget {
  const SectionVendorsView(
    this.vendorType, {
    Key? key,
    this.title = "Vendors",
    this.type,
    this.scrollDirection,
    this.byLocation,
    this.itemWidth,
    this.spacer,
    this.hideEmpty,
    this.titlePadding,
    this.itemsPadding,
  }) : super(key: key);

  final VendorType? vendorType;
  final String title;
  final dynamic type;
  final Axis? scrollDirection;
  final bool? byLocation;
  final double? itemWidth;
  final double? spacer;
  final bool? hideEmpty;
  final EdgeInsets? titlePadding;
  final EdgeInsets? itemsPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: VStack([
        title.text.xl.bold.make(),
        "Vendors coming soon".text.make().centered().expand(),
      ]),
    ).px20().py8();
  }
}
