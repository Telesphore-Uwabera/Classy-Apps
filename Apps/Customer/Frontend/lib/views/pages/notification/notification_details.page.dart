import 'package:flutter/material.dart';
import 'package:Classy/models/app_notification.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/custom_image.view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class NotificationDetailsPage extends StatelessWidget {
  const NotificationDetailsPage({
    required this.notification,
    Key? key,
  }) : super(key: key);

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Notifications",
      showAppBar: true,
      showLeadingAction: true,
      body: SafeArea(
        child: VStack(
          [
            VxBox(
              child: VStack([
                "${notification.title}"
                    .text
                    .bold
                    .xl2
                    .fontFamily(GoogleFonts.nunito().fontFamily!)
                    .make(),
                notification.formattedTime.text.medium
                    .color(Colors.grey)
                    .fontFamily(GoogleFonts.nunito().fontFamily!)
                    .make()
                    .pOnly(bottom: 10),
                if (notification.data['image'] != null && notification.data['image'].isNotEmpty)
                  CustomImage(
                    imageUrl: notification.data['image'],
                    width: double.infinity,
                    height: context.percentHeight * 30,
                  ).py12(),
                "${notification.body}"
                    .text
                    .lg
                    .fontFamily(GoogleFonts.nunito().fontFamily!)
                    .make(),
              ]).p16(),
            ).withRounded(value: 20).color(context.cardColor).shadowXs.make(),
          ],
        ).p20().scrollVertical(),
      ),
    );
  }
}
