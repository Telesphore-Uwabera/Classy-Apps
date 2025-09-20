import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'constants/sizes.dart';
import 'models/package_type.dart';
import 'widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class PackageTypeListItem extends StatelessWidget {
  const PackageTypeListItem({
    required this.packageType,
    this.selected = false,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final PackageType packageType;
  final bool selected;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return HStack(
          [
            //image
            CustomImage(
              imageUrl: packageType.photo,
            ).wh(Vx.dp56, Vx.dp56).pOnly(right: Vx.dp12),

            VStack([
              //name
              packageType.name.text.semiBold.make(),
              //description
              packageType.description.text.sm.make(),
            ]).expand(),
          ],
          crossAlignment: CrossAxisAlignment.start,
          // alignment: MainAxisAlignment.start,
        )
        .p(Sizes.paddingSizeSmall)
        .onInkTap(() => onPressed())
        .box
        .withRounded(value: Sizes.radiusDefault)
        .border(
          color: selected ? AppColor.primaryColor : Vx.zinc200,
          width: selected ? 3 : 2,
        )
        .make();
  }
}
