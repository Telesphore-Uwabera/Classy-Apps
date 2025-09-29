
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuodz/my_app.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize localization with English only
      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: ['en'], // Only English
        assetsDirectory: 'assets/lang/',
      );

      // Initialize local storage
      await LocalStorageService.getPrefs();
      
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
