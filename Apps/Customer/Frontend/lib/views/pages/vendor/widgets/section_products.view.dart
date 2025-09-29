import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:velocity_x/velocity_x.dart';

class SectionProductsView extends StatelessWidget {
  const SectionProductsView(
    this.vendorType, {
    Key? key,
    this.title = "Products",
    this.type,
    this.scrollDirection,
    this.byLocation,
    this.itemWidth,
    this.spacer,
    this.viewType,
    this.hideEmpty,
    this.itemsPadding,
    this.titlePadding,
    this.listHeight,
  }) : super(key: key);

  final VendorType? vendorType;
  final String title;
  final dynamic type;
  final Axis? scrollDirection;
  final bool? byLocation;
  final double? itemWidth;
  final double? spacer;
  final dynamic viewType;
  final bool? hideEmpty;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final double? listHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: VStack([
        title.text.xl.bold.make(),
        "Products coming soon".text.make().centered().expand(),
      ]),
    ).px20().py8();
  }
}
