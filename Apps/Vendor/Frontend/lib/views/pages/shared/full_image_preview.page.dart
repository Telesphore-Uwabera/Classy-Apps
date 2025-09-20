import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'constants/app_images.dart';
import 'utils/ui_spacer.dart';
import 'widgets/base.page.dart';
import 'widgets/busy_indicator.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:velocity_x/velocity_x.dart';
import 'extensions/context.dart';

class FullImagePreviewPage extends StatelessWidget {
  const FullImagePreviewPage(
    this.imageUrl, {
    this.boxFit,
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final BoxFit? boxFit;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      backgroundColor: Colors.black.withValues(alpha: 0.2),
      body: SafeArea(
        child: Column(
          children: [
            //header
            HStack(
              [
                //
                Icon(
                  FlutterIcons.close_ant,
                  color: Colors.white,
                ).box.p4.roundedFull.red500.make().onInkTap(() {
                  context.pop();
                }),
                UiSpacer.expandedSpace(),
              ],
            ).p20(),
            //
            PinchZoom(
              maxScale: 5,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                errorWidget: (context, imageUrl, _) => Image.asset(
                  AppImages.appLogo,
                  fit: boxFit ?? BoxFit.cover,
                ),
                fit: boxFit ?? BoxFit.cover,
                progressIndicatorBuilder: (context, imageURL, progress) =>
                    BusyIndicator().centered(),
              ),
            ).expand(),
          ],
        ),
      ),
    );
  }
}
