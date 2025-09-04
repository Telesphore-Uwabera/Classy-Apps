import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_finance_settings.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/constants/app_ui_settings.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/view_models/profile.vm.dart';
import 'package:Classy/widgets/busy_indicator.dart';
import 'package:Classy/widgets/cards/custom.visibility.dart';
import 'package:Classy/widgets/menu_item.dart';
import 'package:Classy/widgets/states/empty.state.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {Key? key}) : super(key: key);

  final ProfileViewModel model;
  @override
  Widget build(BuildContext context) {
    return model.authenticated
        ? VStack(
            [
              //profile card
              VStack([
                // avatar with camera badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CachedNetworkImage(
                      imageUrl: model.currentUser?.photo ?? "",
                      progressIndicatorBuilder: (context, imageUrl, progress) {
                        return BusyIndicator();
                      },
                      errorWidget: (context, imageUrl, progress) {
                        return Image.asset(AppImages.user);
                      },
                    )
                        .wh(96, 96)
                        .box
                        .roundedFull
                        .clip(Clip.antiAlias)
                        .make(),
                    Icon(Icons.camera_alt, size: 20, color: Colors.white)
                        .box
                        .roundedFull
                        .color(Colors.pink)
                        .p8
                        .make(),
                  ],
                ).centered(),
                12.heightBox,
                model.currentUser!.name.text.xl2.semiBold.makeCentered(),
                8.heightBox,
                // contact card
                VStack([
                  HStack([
                    const Icon(Icons.phone, color: Colors.pink),
                    12.widthBox,
                    (model.currentUser?.phone ?? "").text.make(),
                  ]),
                  const Divider(height: 16),
                  HStack([
                    const Icon(Icons.email_outlined, color: Colors.pink),
                    12.widthBox,
                    (model.currentUser?.email ?? "").text.make(),
                  ]),
                ])
                    .p16()
                    .wFull(context)
                    .box
                    .roundedLg
                    .color(Theme.of(context).cardColor)
                    .shadowXs
                    .make(),
                10.heightBox,
                // verified pill
                HStack([
                  const Icon(Icons.verified, color: Colors.pink),
                  8.widthBox,
                  (() {
                    final now = DateTime.now();
                    const months = [
                      'January',
                      'February',
                      'March',
                      'April',
                      'May',
                      'June',
                      'July',
                      'August',
                      'September',
                      'October',
                      'November',
                      'December',
                    ];
                    final monthName = months[now.month - 1];
                    return "Verified Member • $monthName ${now.year}".text.make();
                  })(),
                ])
                    .p8()
                    .box
                    .roundedFull
                    .color(Theme.of(context).cardColor)
                    .shadowXs
                    .make(),
              ]),

              10.heightBox,

              //
              VStack(
                [
                  MenuItem(
                    title: "Edit Profile".tr(),
                    onPressed: model.openEditProfile,
                    prefix: Icon(HugeIcons.strokeRoundedUserEdit01),
                  ),
                  //change password
                  MenuItem(
                    title: "Change Password".tr(),
                    onPressed: model.openChangePassword,
                    prefix: Icon(HugeIcons.strokeRoundedResetPassword),
                  ),
                  //referral
                  CustomVisibilty(
                    visible: AppStrings.enableReferSystem,
                    child: MenuItem(
                      title: "Refer & Earn".tr(),
                      onPressed: model.openRefer,
                      prefix: Icon(HugeIcons.strokeRoundedShare01),
                    ),
                  ),
                  //loyalty point
                  CustomVisibilty(
                    visible: AppFinanceSettings.enableLoyalty,
                    child: MenuItem(
                      title: "Loyalty Points".tr(),
                      onPressed: model.openLoyaltyPoint,
                      prefix: Icon(HugeIcons.strokeRoundedGift),
                    ),
                  ),
                  //Wallet
                  CustomVisibilty(
                    visible: AppUISettings.allowWallet,
                    child: MenuItem(
                      title: "Wallet".tr(),
                      onPressed: model.openWallet,
                      prefix: Icon(HugeIcons.strokeRoundedWallet01),
                    ),
                  ),
                  //addresses
                  MenuItem(
                    title: "Delivery Addresses".tr(),
                    onPressed: model.openDeliveryAddresses,
                    prefix: Icon(HugeIcons.strokeRoundedPinLocation01),
                  ),
                  //favourites
                  MenuItem(
                    title: "Favourites".tr(),
                    onPressed: model.openFavourites,
                    prefix: Icon(HugeIcons.strokeRoundedFavourite),
                  ),
                  //
                  MenuItem(
                    title: "Logout".tr(),
                    onPressed: model.logoutPressed,
                    suffix: Icon(
                      HugeIcons.strokeRoundedLogout01,
                      size: 20,
                    ),
                  ),
                  MenuItem(
                    child: "Delete Account".tr().text.red500.make(),
                    onPressed: model.deleteAccount,
                    suffix: Icon(
                      HugeIcons.strokeRoundedDelete01,
                      size: 20,
                      color: Vx.red400,
                    ),
                  ),
                  //
                  UiSpacer.vSpace(15),
                ],
              ),
            ],
          )
        : EmptyState(
            auth: true,
            showAction: true,
            actionPressed: model.openLogin,
          ).py12();
  }
}
