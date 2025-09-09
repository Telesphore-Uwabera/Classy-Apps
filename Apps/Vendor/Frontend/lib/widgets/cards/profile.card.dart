import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/view_models/profile.vm.dart';
import 'package:fuodz/views/pages/profile/paymet_accounts.page.dart';
import 'package:fuodz/views/pages/profile/business_settings.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/menu_item.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fuodz/extensions/context.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {Key? key}) : super(key: key);

  final ProfileViewModel model;
  @override
  Widget build(BuildContext context) {
    return VStack([
          //profile card with pink header
          (model.isBusy || model.currentUser == null)
              ? BusyIndicator().centered().p20()
              : Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: VStack([
                    HStack([
                      //
                      CachedNetworkImage(
                            imageUrl: model.currentUser!.photo,
                            progressIndicatorBuilder: (context, imageUrl, progress) {
                              return BusyIndicator();
                            },
                            errorWidget: (context, imageUrl, progress) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            },
                          )
                          .wh(80, 80)
                          .box
                          .roundedFull
                          .clip(Clip.antiAlias)
                          .make(),

                      //
                      VStack([
                        //name
                        model.currentUser!.name.text.xl2.semiBold.white.make(),
                                            //phone number
                    model.currentUser!.phone.text.light.white.make(),
                      ]).px20().expand(),
                    ]).p20(),
                    
                    // Edit Profile button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: OutlinedButton(
                        onPressed: model.openEditProfile,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
          
          // Business Settings section
          VStack([
            MenuItem(
              title: "Business Settings".tr(),
              prefix: Icon(
                Icons.business,
                color: const Color(0xFFE91E63),
              ),
              onPressed: () {
                context.push((ctx) => const BusinessSettingsPage());
              },
              topDivider: true,
            ),
            
            MenuItem(
              title: "Support".tr(),
              prefix: Icon(
                Icons.headset_mic,
                color: const Color(0xFFE91E63),
              ),
              onPressed: () {
                // TODO: Navigate to support
              },
            ),
            
            MenuItem(
              title: "About Us".tr(),
              prefix: Icon(
                Icons.info,
                color: const Color(0xFFE91E63),
              ),
              onPressed: () {
                // TODO: Navigate to about us
              },
            ),
            
            MenuItem(
              title: "Privacy Policy".tr(),
              prefix: Icon(
                Icons.privacy_tip,
                color: const Color(0xFFE91E63),
              ),
              onPressed: () {
                // TODO: Navigate to privacy policy
              },
            ),
            
            MenuItem(
              title: "Terms and Conditions".tr(),
              prefix: Icon(
                Icons.description,
                color: const Color(0xFFE91E63),
              ),
              onPressed: () {
                // TODO: Navigate to terms
              },
              divider: false,
            ),
          ]).py12(),
          
          // Other menu items
          VStack([
            MenuItem(
              title: "Change Password".tr(),
              prefix: Icon(EvaIcons.keypadOutline, color: const Color(0xFFE91E63)),
              onPressed: model.openChangePassword,
              topDivider: true,
            ),

            Divider(),
            //
            MenuItem(
              title: "Backend".tr(),
              prefix: Icon(EvaIcons.browserOutline, color: const Color(0xFFE91E63)),
              onPressed: () async {
                try {
                  final url = Api.redirectAuth("dummy_token");
                  model.openExternalWebpageLink(url);
                } catch (error) {
                  model.toastError("$error");
                }
              },
              topDivider: true,
              divider: false,
            ),
            //
            MenuItem(
              title: "Payment Accounts".tr(),
              prefix: Icon(EvaIcons.creditCardOutline, color: const Color(0xFFE91E63)),
              onPressed: () {
                context.push((ctx) => PaymentAccountsPage());
              },
              topDivider: true,
              divider: false,
            ),
          ]).py12(),
        ])
        .wFull(context)
        .box
        .border(color: Vx.zinc200)
        .withRounded(value: Sizes.radiusSmall)
        .make();
  }
}
