import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AreasOfOperationWidget extends StatelessWidget {
  const AreasOfOperationWidget({
    Key? key,
    this.countries,
    this.states,
    this.cities,
  }) : super(key: key);

  final List<dynamic>? countries;
  final List<dynamic>? states;
  final List<dynamic>? cities;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: "Areas of Operation".text.make().centered(),
    ).px20().py8();
  }
}
