import 'dart:async';
import 'dart:io';

import 'package:custom_faqs/custom_faqs.dart';
import 'package:flutter/material.dart';
import 'package:Classy/extensions/dynamic.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/view_models/payment.view_model.dart';
import 'package:Classy/views/pages/loyalty/loyalty_point.page.dart';
import 'package:Classy/views/pages/profile/account_delete.page.dart';
import 'package:Classy/views/pages/splash.page.dart';
import 'package:Classy/constants/api.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/widgets/bottomsheets/referral.bottomsheet.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Classy/extensions/context.dart';

class ProfileViewModel extends PaymentViewModel {
  //
  String appVersionInfo = "";
  bool authenticated = false;
  User? currentUser;

  //
  AuthRequest _authRequest = AuthRequest();
  StreamSubscription? authStateListenerStream;

  ProfileViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    //
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    appVersionInfo = "$versionName($versionCode)";
    authenticated = await AuthServices.authenticated();
    if (authenticated) {
      currentUser = await AuthServices.getCurrentUser(force: true);
    } else {
      listenToAuthChange();
    }
    notifyListeners();
  }

  dispose() {
    super.dispose();
    authStateListenerStream?.cancel();
  }

  listenToAuthChange() {
    authStateListenerStream?.cancel();
    authStateListenerStream = AuthServices.listenToAuthState().listen((
      event,
    ) async {
      if (event != null && event) {
        authenticated = event;
        currentUser = await AuthServices.getCurrentUser(force: true);
        notifyListeners();
        authStateListenerStream?.cancel();
      }
    });
  }

  /**
   * Edit Profile
   */

  openEditProfile() async {
    final result = await Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.editProfileRoute);

    if (result != null && result is bool && result) {
      initialise();
    }
  }

  /**
   * Change Password
   */

  openChangePassword() async {
    Navigator.of(viewContext).pushNamed(AppRoutes.changePasswordRoute);
  }

  //
  openRefer() async {
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReferralBottomsheet(this),
    );
  }

  //
  openLoyaltyPoint() {
    viewContext.nextPage(LoyaltyPointPage());
  }

  openWallet() {
    Navigator.of(viewContext).pushNamed(AppRoutes.walletRoute);
  }

  /**
   * Delivery addresses
   */
  openDeliveryAddresses() {
    Navigator.of(viewContext).pushNamed(AppRoutes.deliveryAddressesRoute);
  }

  //
  openFavourites() {
    Navigator.of(viewContext).pushNamed(AppRoutes.favouritesRoute);
  }

  /**
   * Logout
   */
  logoutPressed() async {
    AlertService.confirm(
      title: "Logout".tr(),
      text: "Are you sure you want to logout?".tr(),
      onConfirm: () {
        processLogout();
      },
    );
  }

  void processLogout() async {
    //
    AlertService.loading(
      title: "Logout".tr(),
      text: "Logging out Please wait...".tr(),
      barrierDismissible: false,
    );

    //
          final apiResponse = await AuthRequest.logoutRequest();

    //
    viewContext.pop();

    if (!apiResponse.allGood && apiResponse.code != 401) {
      //
      AlertService.error(title: "Logout".tr(), text: apiResponse.message);
    } else {
      //
      await AuthServices.logout();
      // Navigator.of(viewContext).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => SplashPage()),
      //   (route) => false,
      // );
      Navigator.of(viewContext).pushNamedAndRemoveUntil(
        AppRoutes.loginRoute,
        (route) => false,
      );
    }
  }

  openNotification() async {
    Navigator.of(viewContext).pushNamed(AppRoutes.notificationsRoute);
  }

  /**
   * App Rating & Review
   */
  openReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (Platform.isAndroid) {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    } else if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    }
  }

  //
  openPrivacyPolicy() async {
    final url = "https://classy.app/privacy-policy";
    openWebpageLink(url);
  }

  openTerms() {
    final url = "https://classy.app/terms";
    openWebpageLink(url);
  }

  openFaqs() {
    viewContext.nextPage(
      CustomFaqPage(title: 'Faqs'.tr(), link: "https://classy.app/faqs"),
    );
  }

  //
  openContactUs() async {
    final url = "https://classy.app/contact-us";
    openWebpageLink(url);
  }

  openLivesupport() async {
    final url = "https://classy.app/support";
    openWebpageLink(url);
  }

  //
  changeLanguage() async {
    // Language selection removed - only English is used in Uganda
    // This method is kept for compatibility but does nothing
    print("Language selection is not available - only English is supported");
  }

  openLogin() async {
    await Navigator.of(viewContext).pushNamed(AppRoutes.loginRoute);
    //
    initialise();
  }

  void shareReferralCode() {
    Share.share(
      "%s is inviting you to join %s via this referral code: %s".tr().fill([
            currentUser!.name,
            AppStrings.appName,
            currentUser!.code,
          ]) +
          "\n" +
          AppStrings.androidDownloadLink +
          "\n" +
          AppStrings.iOSDownloadLink +
          "\n",
    );
  }

  //
  deleteAccount() {
    viewContext.nextPage(AccountDeletePage());
  }

  openRefundPolicy() {
    final url = "https://classy.app/refund-terms";
    openWebpageLink(url);
  }

  openCancellationPolicy() {
    final url = "https://classy.app/cancellation-terms";
    openWebpageLink(url);
  }

  openShippingPolicy() {
    final url = "https://classy.app/shipping-terms";
    openWebpageLink(url);
  }
}
