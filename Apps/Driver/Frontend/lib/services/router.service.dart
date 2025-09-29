import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/views/pages/auth/login.page.dart';
import 'package:fuodz/views/pages/auth/register.page.dart';
import 'package:fuodz/views/pages/auth/forgot_password.page.dart';
import 'package:fuodz/views/pages/dashboard/dashboard.page.dart';
import 'package:fuodz/views/pages/home/home.page.dart';
import 'package:fuodz/views/pages/profile/profile.page.dart';
import 'package:fuodz/views/pages/settings.page.dart';
import 'package:fuodz/views/pages/welcome.page.dart';

class RouterService {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.loginRoute:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case AppRoutes.registerRoute:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case AppRoutes.forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
      case AppRoutes.homeRoute:
        return MaterialPageRoute(builder: (_) => HomePage());
      case AppRoutes.dashboardRoute:
        return MaterialPageRoute(builder: (_) => DashboardPage());
      case AppRoutes.profileRoute:
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case AppRoutes.settingsRoute:
        return MaterialPageRoute(builder: (_) => SettingsPage());
      case AppRoutes.welcomeRoute:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}