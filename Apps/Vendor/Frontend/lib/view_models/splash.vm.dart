import 'dart:convert';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_theme.dart';
import 'package:fuodz/requests/settings.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/websocket.service.dart';
import 'package:fuodz/utils/utils.dart';

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
  }

  //

  //
  loadAppSettings() async {
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();
      
      // Check if the response is valid
      if (appSettingsObject.body == null) {
        print("Backend not available, using default settings");
        await loadDefaultSettings();
        loadNextPage();
        return;
      }
      
      //START: WEBSOCKET SETTINGS
      if (appSettingsObject.body["websocket"] != null) {
        await WebsocketService().saveWebsocketDetails(
          appSettingsObject.body["websocket"],
        );
      }
      //END: WEBSOCKET SETTINGS
      Map<String, dynamic> appGenSettings = appSettingsObject.body["strings"];
      //set the app name ffrom package to the app settings
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      appGenSettings["app_name"] = appName;
      //app settings
      await updateAppVariables(appGenSettings);
      //colors
      await updateAppTheme(appSettingsObject.body["colors"]);
      loadNextPage();
    } catch (error) {
      setError(error);
      print("Error loading app settings ==> $error");
      // Load default settings when backend is not available
      await loadDefaultSettings();
      loadNextPage();
    }
    setBusy(false);
  }

  // Load default settings when backend is not available
  loadDefaultSettings() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      
      // Default app settings
      Map<String, dynamic> defaultSettings = {
        "app_name": appName,
        "app_version": packageInfo.version,
        "build_number": packageInfo.buildNumber,
        "package_name": packageInfo.packageName,
      };
      
      // Default colors (Classy pink theme)
      Map<String, dynamic> defaultColors = {
        "primary": "#E91E63",
        "primary_dark": "#C2185B",
        "accent": "#FF4081",
        "background": "#FFFFFF",
        "surface": "#F5F5F5",
        "text": "#212121",
        "text_secondary": "#757575",
      };
      
      await updateAppVariables(defaultSettings);
      await updateAppTheme(defaultColors);
      
      print("Default settings loaded successfully");
    } catch (error) {
      print("Error loading default settings: $error");
    }
  }

  //
  Future<void> updateAppVariables(dynamic json) async {
    //
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    //
    await AppColor.saveColorsToLocalStorage(jsonEncode(colorJson));
    //change theme - Force light theme
    AdaptiveTheme.of(viewContext).setTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      notify: true,
    );
    // Force light theme mode
    AdaptiveTheme.of(viewContext).setThemeMode(AdaptiveThemeMode.light);
    await AdaptiveTheme.of(viewContext).persist();
  }

  //
  loadNextPage() async {
    //
    await Utils.setJiffyLocale();
    
    // Navigate to appropriate page based on authentication status
    if (!AuthServices.authenticated()) {
      Navigator.of(
        viewContext,
      ).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
    } else {
      await AuthServices.getCurrentUser(force: true);
      Navigator.of(
        viewContext,
      ).pushNamedAndRemoveUntil(AppRoutes.homeRoute, (route) => false);
    }

    //
    // Firebase functionality removed - will be added back later
  }
}
