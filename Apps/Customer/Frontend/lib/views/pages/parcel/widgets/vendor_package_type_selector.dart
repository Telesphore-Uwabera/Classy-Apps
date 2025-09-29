import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorPackageTypeSelector extends StatelessWidget {
  const VendorPackageTypeSelector({Key? key, this.vm}) : super(key: key);

  final dynamic vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: "Vendor Package Type Selector".text.make().centered(),
    ).px20().py8();
  }
}
