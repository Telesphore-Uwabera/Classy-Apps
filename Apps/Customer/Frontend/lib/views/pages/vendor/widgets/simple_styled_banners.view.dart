import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:velocity_x/velocity_x.dart';

class SimpleStyledBanners extends StatelessWidget {
  const SimpleStyledBanners(
    this.vendorType, {
    Key? key,
    this.height,
    this.withPadding,
    this.viewportFraction,
    this.hideEmpty,
  }) : super(key: key);

  final VendorType? vendorType;
  final double? height;
  final bool? withPadding;
  final double? viewportFraction;
  final bool? hideEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: "Simple banners coming soon".text.make().centered(),
    ).px20().py8();
  }
}
