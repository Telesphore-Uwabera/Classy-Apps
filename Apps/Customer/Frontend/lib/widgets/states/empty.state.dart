import 'package:flutter/material.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    Key? key,
    this.imageUrl,
    this.title = "",
    this.actionText = "Action",
    this.description = "",
    this.showAction = false,
    this.showImage = true,
    this.actionPressed,
    this.auth = false,
  }) : super(key: key);

  final String title;
  final String actionText;
  final String description;
  final String? imageUrl;
  final VoidCallback? actionPressed;
  final bool showAction;
  final bool showImage;
  final bool auth;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: VStack(
        [
          //
          (imageUrl != null && imageUrl.isNotEmptyAndNotNull)
              ? Image.asset(imageUrl!)
                  .wh(
                    context.percentWidth * 40,
                    context.percentWidth * 40,
                  )
                  .box
                  .makeCentered()
                  .wFull(context)
              : UiSpacer.emptySpace(),
          UiSpacer.vSpace(5),

          //
          (title.isNotEmpty)
              ? title.text.xl2.semiBold.center.makeCentered()
              : SizedBox.shrink(),

          //
          (auth && showImage)
              ? Image.asset(
                  AppImages.appLogo,
                )
                    .wh(
                      context.percentWidth * 24,
                      context.percentWidth * 24,
                    )
                    .box
                    .roundedFull
                    .color(Colors.white.withOpacity(0.1))
                    .p16
                    .makeCentered()
                    .py12()
                    .wFull(context)
              : SizedBox.shrink(),
          //
          auth
              ? VStack([
                  "Login or Create Account".tr().text.xl2.semiBold.center.make(),
                  6.heightBox,
                  "Sign in to view your orders and history".tr().text.lg.center.make(),
                ]).py12()
              : description.isNotEmpty
                  ? description.text.lg.light.center.makeCentered()
                  : SizedBox.shrink(),

          //
          auth
              ? VStack([
                  CustomButton(
                    title: "Login".tr(),
                    onPressed: actionPressed,
                    elevation: 4,
                  ).w(context.percentWidth * 0.9).centered(),
                  8.heightBox,
                  OutlinedButton(
                    onPressed: actionPressed,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.pink, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("Create Account".tr(), style: TextStyle(color: Colors.pink)),
                  ).w(context.percentWidth * 0.9).centered(),
                ])
              : showAction
                  ? CustomButton(
                      title: actionText.tr(),
                      onPressed: actionPressed,
                    ).w(context.percentWidth * 0.9).centered().py12()
                  : SizedBox.shrink(),
        ],
        crossAlignment: CrossAxisAlignment.center,
        alignment: MainAxisAlignment.center,
      ).wFull(context),
    );
  }
}
