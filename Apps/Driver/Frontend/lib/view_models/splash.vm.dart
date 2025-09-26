import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_theme.dart';
import 'package:fuodz/requests/settings.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/firebase.service.dart';
import 'package:fuodz/services/websocket.service.dart';
import 'package:fuodz/services/driver_status.service.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/utils/utils.dart';

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
    if (await AuthServices.authenticated()) {
      await AuthServices.getCurrentUser(force: true);
    }
  }

  //

  //
  loadAppSettings() async {
    setBusy(true);
    try {
      print("🔧 Loading app settings...");
      var appSettingsObject = await SettingsRequest.appSettings();
      
      print("📡 API Response received: ${appSettingsObject.code}");
      print("📦 Response body type: ${appSettingsObject.body.runtimeType}");
      
      // Check if we have valid data
      if (appSettingsObject.body == null) {
        print("⚠️ App settings body is null, using fallback");
        // Use fallback settings
        appSettingsObject = ApiResponse(
          code: appSettingsObject.code,
          message: appSettingsObject.message,
          body: {
            'app_name': 'Classy Driver',
            'app_version': '1.0.0',
            'currency': 'USD',
            'strings': {
              'app_name': 'Classy Driver',
              'company_name': 'Classy Inc',
              'currency_symbol': '\$',
              'country_code': 'US',
            },
            'websocket': {
              'url': 'wss://classy.app/ws',
              'enabled': true,
            },
          },
        );
      }
      
      print("✅ App settings body is not null");
      
      //START: WEBSOCKET SETTINGS
      if (appSettingsObject.body["websocket"] != null) {
        print("🔌 Websocket settings found");
        await WebsocketService.instance.saveWebsocketDetails(
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
        'app_name': 'Classy Driver',
        'app_version': '1.0.0',
        'currency': 'USD',
        'strings': {
          'app_name': 'Classy Driver',
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
  }

  //
  loadNextPage() async {
    try {
      print("🚀 Starting navigation logic...");
      
      //
      await Utils.setJiffyLocale();
      //
      // Mark first time as completed since we're skipping language selection
      if (AuthServices.firstTimeOnApp()) {
        await AuthServices.firstTimeCompleted();
      }
      
      print("🔐 Checking authentication status...");
      final isAuthenticated = await AuthServices.authenticated();
      print("🔐 Authentication status: $isAuthenticated");
      
      // After splash → go to Login when not authenticated; else Home
      if (viewContext != null) {
        if (isAuthenticated) {
          print("🔐 User is authenticated, checking driver status...");
          // ✅ CRITICAL SECURITY FIX: Check driver status before allowing access
          final canAccess = await DriverStatusService.canDriverAccessApp();
          print("🔐 Driver access status: $canAccess");
          
          if (canAccess) {
            print("✅ Driver approved, navigating to home...");
            Navigator.of(viewContext!).pushNamedAndRemoveUntil(
              AppRoutes.homeRoute,
              (Route<dynamic> route) => false,
            );
          } else {
            print("❌ Driver not approved, showing status and redirecting to login...");
            // Driver not approved, show status and redirect to login
            final statusValidation = await DriverStatusService.validateDriverStatus();
            DriverStatusService.showStatusMessage(statusValidation);
            
            Navigator.of(viewContext!).pushNamedAndRemoveUntil(
              AppRoutes.loginRoute,
              (Route<dynamic> route) => false,
            );
          }
        } else {
          print("🔐 User not authenticated, navigating to welcome...");
          Navigator.of(viewContext!).pushNamedAndRemoveUntil(
            AppRoutes.welcomeRoute,
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print("❌ ViewContext is null, cannot navigate");
      }
    } catch (e) {
      print("❌ Error in loadNextPage: $e");
      // Fallback navigation
      if (viewContext != null) {
        Navigator.of(viewContext!).pushNamedAndRemoveUntil(
          AppRoutes.welcomeRoute,
          (Route<dynamic> route) => false,
        );
      }
    }

    //
    if (!kIsWeb) {
      RemoteMessage? initialMessage =
          await FirebaseService.instance.firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        //
        FirebaseService.instance.saveNewNotification(initialMessage);
        FirebaseService.instance.notificationPayloadData = initialMessage.data;
        FirebaseService.instance.selectNotification("");
      }
    }
  }
}