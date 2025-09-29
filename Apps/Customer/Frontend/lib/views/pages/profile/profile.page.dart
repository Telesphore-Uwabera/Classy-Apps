import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/extensions/context.dart';
import 'package:Classy/extensions/dynamic.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/utils/app_text_style.dart';
import 'package:Classy/view_models/profile.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/cards/profile.card.dart';
import 'package:Classy/widgets/states/empty.state.dart';
import 'package:Classy/widgets/main_bottom_nav.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:stacked/stacked.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  //
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      disposeViewModel: false,
      builder: (context, model, child) {
        return BasePage(
          showAppBar: false,
          body: VStack([
            // Pink Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: VStack([
                // Status bar spacer
                UiSpacer.verticalSpace(space: 50),
                
                // Back button and title
                HStack([
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: "Profile".tr().text.white.bold.xl2.make().centered(),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () => NavigationService.navigateToEditProfile(),
                  ),
                ]).py12(),
                
                // Profile Picture
                VStack([
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: model.currentUser?.photo != null
                            ? NetworkImage(model.currentUser!.photo!)
                            : AssetImage(AppImages.appLogo) as ImageProvider,
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: AppColor.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  "Change Profile Photo".tr().text.white.make().py8(),
                ]).py20(),
              ]).p20(),
            ),
            
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: VStack([
                  UiSpacer.verticalSpace(space: 20),
                  
                  // Work Section
                  _buildMenuCard(
                    icon: Icons.work,
                    title: "Work",
                    subtitle: "Not set",
                    showAddButton: true,
                    onTap: () {},
                  ),
                  
                  // Ride History Section
                  _buildMenuCard(
                    icon: Icons.history,
                    title: "Ride History",
                    subtitle: "View your past rides and deliveries",
                    onTap: () {},
                  ),
                  
                  // Payment Methods Section
                  _buildMenuCard(
                    icon: Icons.payment,
                    title: "Payment Methods",
                    subtitle: "Manage your payment options",
                    onTap: () => NavigationService.navigateToPaymentMethods(),
                  ),
                  
                  // Support Section
                  _buildMenuCard(
                    icon: Icons.headset_mic,
                    title: "Support",
                    subtitle: "Get help with your account",
                    onTap: () => NavigationService.navigateToHelpSupport(),
                  ),
                  
                  // Settings Section
                  _buildMenuCard(
                    icon: Icons.settings,
                    title: "Settings",
                    subtitle: "Customize your app experience",
                    onTap: () => NavigationService.navigateToSettings(),
                  ),
                  
                  UiSpacer.verticalSpace(space: 20),
                  
                  // Sign Out Button
                  CustomButton(
                    title: "Sign Out",
                    icon: Icons.logout,
                    color: AppColor.primaryColor,
                    titleStyle: AppTextStyle.h3TitleTextStyle(
                      color: Colors.white,
                    ),
                    onPressed: () => model.processLogout(),
                  ).wFull(context).py12(),
                  
                  UiSpacer.verticalSpace(space: 20),
                ]).px20(),
              ),
            ),
          ]),
        );
      },
    );
  }
  
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showAddButton = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HStack([
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: AppColor.primaryColor,
                      size: 24,
                    ),
                  ),
                  UiSpacer.horizontalSpace(space: 16),
                  Expanded(
                    child: VStack([
                      title.text.bold.lg.make(),
                      subtitle.text.gray500.make().py4(),
                    ], crossAlignment: CrossAxisAlignment.start),
                  ),
                  if (!showAddButton)
                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ]),
                
                if (showAddButton) ...[
                  UiSpacer.verticalSpace(space: 16),
                  CustomButton(
                    title: "+ Add New Location",
                    icon: Icons.add,
                    color: AppColor.primaryColor,
                    titleStyle: AppTextStyle.h3TitleTextStyle(
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ).wFull(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
