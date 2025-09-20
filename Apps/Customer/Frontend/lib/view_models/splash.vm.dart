import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/constants/app_theme.dart';
import 'package:Classy/requests/settings.request.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase.service.dart';
import 'package:Classy/services/websocket.service.dart';
import 'package:Classy/utils/utils.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'base.view_model.dart';

class SplashViewModel extends MyBaseViewModel {
  SplashViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  SettingsRequest settingsRequest = SettingsRequest();

  //
  initialise() async {
    super.initialise();
    await loadAppSettings();
    if (AuthServices.authenticated()) {
      await AuthServices.getCurrentUser(force: true);
    }
  }

  //

  //
  loadAppSettings() async {
    setBusy(true);
    try {
      print("🔧 Loading app settings...");
      final appSettingsObject = await SettingsRequest.appSettings();
      
      print("📡 API Response received: ${appSettingsObject.code}");
      print("📦 Response body type: ${appSettingsObject.body.runtimeType}");
      
      // Check if we have valid data
      if (appSettingsObject.body == null) {
        print("⚠️ App settings body is null, using fallback");
        // Use fallback settings
        appSettingsObject.body = {
          'app_name': 'Classy',
          'app_version': '1.0.0',
          'currency': 'USD',
          'strings': {
            'app_name': 'Classy',
            'company_name': 'Classy Inc',
            'currency_symbol': '\$',
            'country_code': 'US',
          },
          'websocket': {
            'url': 'wss://classy.app/ws',
            'enabled': true,
          },
        };
      }
      
      print("✅ App settings body is not null");
      
      //START: WEBSOCKET SETTINGS
      if (appSettingsObject.body["websocket"] != null) {
        print("🔌 Websocket settings found");
        await WebsocketService().saveWebsocketDetails(
          appSettingsObject.body["websocket"],
        );
      }
      //END: WEBSOCKET SETTINGS

      // Safely get strings with fallback
      Map<String, dynamic> appGenSettings = {};
      if (appSettingsObject.body["strings"] != null) {
        print("📝 App strings found");
        appGenSettings = Map<String, dynamic>.from(appSettingsObject.body["strings"]);
      } else {
        print("⚠️ No app strings found, using defaults");
      }
      
      //set the app name from package to the app settings
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      appGenSettings["app_name"] = appName;
      print("📱 App name set: $appName");
      
      //app settings
      await updateAppVariables(appGenSettings);
      print("💾 App variables updated");
      
      //colors - safely handle null colors
      if (appSettingsObject.body["colors"] != null) {
        print("🎨 App colors found");
        await updateAppTheme(appSettingsObject.body["colors"]);
      } else {
        print("🎨 Using default colors");
        // Use default colors if none provided
        await updateAppTheme({});
      }
      
      print("✅ App settings loaded successfully");
      loadNextPage();
    } catch (error) {
      setError(error);
      print("❌ Error loading app settings ==> $error");
      // Use fallback settings instead of showing error
      print("🔄 Using fallback settings due to error");
      final fallbackSettings = {
        'app_name': 'Classy',
        'app_version': '1.0.0',
        'currency': 'USD',
        'strings': {
          'app_name': 'Classy',
          'company_name': 'Classy Inc',
          'currency_symbol': '\$',
          'country_code': 'US',
        },
        'websocket': {
          'url': 'wss://classy.app/ws',
          'enabled': true,
        },
      };
      
      await updateAppVariables(fallbackSettings);
      await updateAppTheme({});
      await loadNextPage();
    }
    setBusy(false);
  }

  //
  updateAppVariables(dynamic json) async {
    //
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    //
    // Merge server colors with our pink brand overrides so UI is not blue
    Map<String, dynamic> mergedColors = {};
    if (colorJson is Map<String, dynamic>) {
      mergedColors.addAll(colorJson);
    }
    // Forced pink palette
    mergedColors['primaryColor'] = '#E91E63';
    mergedColors['primaryColorDark'] = '#D81B60';
    mergedColors['accentColor'] = '#E91E63';
    // Optional supportive tints used in onboarding/backgrounds
    mergedColors['onboarding1Color'] = mergedColors['onboarding1Color'] ?? '#FDE1EB';
    mergedColors['onboarding2Color'] = mergedColors['onboarding2Color'] ?? '#FDE1EB';
    mergedColors['onboarding3Color'] = mergedColors['onboarding3Color'] ?? '#FDE1EB';
    // Save
    await AppColor.saveColorsToLocalStorage(jsonEncode(mergedColors));
    //change theme
    // await AdaptiveTheme.of(viewContext).reset();
    AdaptiveTheme.of(viewContext).setTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      notify: true,
    );
    await AdaptiveTheme.of(viewContext).persist();
  }

  //
  loadNextPage() async {
    //
    await Utils.setJiffyLocale();
    //
    // Mark first time as completed since we're skipping language selection
    if (AuthServices.firstTimeOnApp()) {
      await AuthServices.firstTimeCompleted();
    }
    //
    // After splash → go to Login when not authenticated; else Home
    if (AuthServices.authenticated()) {
      Navigator.of(viewContext).pushNamedAndRemoveUntil(
        AppRoutes.homeRoute,
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(viewContext).pushNamedAndRemoveUntil(
        AppRoutes.loginRoute,
        (Route<dynamic> route) => false,
      );
    }

    //
    if (!kIsWeb) {
      RemoteMessage? initialMessage =
          await FirebaseService().firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        //
        FirebaseService().saveNewNotification(initialMessage);
        FirebaseService().notificationPayloadData = initialMessage.data;
        FirebaseService().selectNotification("");
      }
    }
  }
}
