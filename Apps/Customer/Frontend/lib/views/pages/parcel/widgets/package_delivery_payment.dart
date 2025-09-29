import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class PackageDeliveryPayment extends StatelessWidget {
  const PackageDeliveryPayment({Key? key, this.vm}) : super(key: key);

  final dynamic vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: "Package Delivery Payment".text.make().centered(),
    ).px20().py8();
  }
}
