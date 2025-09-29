import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:velocity_x/velocity_x.dart';

class Banners extends StatelessWidget {
  const Banners(
    this.vendorType, {
    Key? key,
    this.featured,
    this.padding,
    this.viewportFraction,
    this.height,
    this.itemRadius,
  }) : super(key: key);

  final VendorType? vendorType;
  final bool? featured;
  final double? padding;
  final double? viewportFraction;
  final double? height;
  final double? itemRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: "Banners coming soon".text.make().centered(),
    ).px20().py8();
  }
}
