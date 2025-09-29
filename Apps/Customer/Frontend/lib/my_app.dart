import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:Classy/constants/app_theme.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/views/pages/splash.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'constants/app_strings.dart';
import 'package:Classy/services/router.service.dart' as router;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return AdaptiveTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      initial: kIsWeb ? AdaptiveThemeMode.light : AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp(
          navigatorKey: AppService().navigatorKey,
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          onGenerateRoute: router.generateRoute,
          onUnknownRoute: (RouteSettings settings) {
            // open your app when is executed from outside when is terminated.
            return router.generateRoute(settings);
          },
          // initialRoute: _startRoute,
          localizationsDelegates: translator.delegates,
          locale: translator.activeLocale,
          supportedLocales: translator.locals(),
          builder: (context, child) {
            final content = Stack(children: [child!, DropdownAlert()]);
            if (!kIsWeb) return content;
            // On web, constrain to a phone-like viewport and also override MediaQuery width
            const double appWidth = 390;
            final mq = MediaQuery.of(context);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: appWidth),
                child: MediaQuery(
                  data: mq.copyWith(
                    size: Size(appWidth, mq.size.height),
                  ),
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: content,
                  ),
                ),
              ),
            );
          },
          home: SplashPage(),
          theme: theme,
          darkTheme: darkTheme,
        );
      },
    );
  }
}
