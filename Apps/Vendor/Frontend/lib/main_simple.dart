import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_languages.dart';
import 'package:fuodz/my_app.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

//ssll handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize localization
      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );

      // Initialize local storage
      await LocalStorageService.getPrefs();

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
      
      // Simple error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };
      
      // Run app!
      runApp(LocalizedApp(child: MyApp()));
    },
    (error, stackTrace) {
      // Simple error logging
      print('Error: $error');
      print('StackTrace: $stackTrace');
    },
  );
}
