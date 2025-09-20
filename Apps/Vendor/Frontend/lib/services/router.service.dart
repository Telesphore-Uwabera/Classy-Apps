import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'constants/app_routes.dart';
import 'models/order.dart';
import 'models/notification.dart';
import 'models/product.dart';
import 'views/pages/auth/forgot_password.page.dart';
import 'views/pages/auth/login.page.dart';
import 'views/pages/home.page.dart';
// import 'widgets/cards/language_selector.view.dart'; // Removed language selection
import 'views/pages/notification/notification_details.page.dart';
import 'views/pages/notification/notifications.page.dart';

import 'views/pages/order/orders_details.page.dart';
import 'views/pages/product/product_details.page.dart';
import 'views/pages/profile/change_password.page.dart';
import 'views/pages/profile/edit_profile.page.dart';
import 'views/pages/terms_conditions.page.dart';
import 'views/pages/privacy_policy.page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.loginRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());

    case AppRoutes.forgotPasswordRoute:
      return MaterialPageRoute(builder: (context) => ForgotPasswordPage());

    case AppRoutes.homeRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.homeRoute, arguments: Map()),
        builder: (context) => HomePage(),
      );

    //order details page
    case AppRoutes.orderDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.orderDetailsRoute),
        builder: (context) => OrderDetailsPage(
          order: settings.arguments as Order,
        ),
      );
    case AppRoutes.productDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.productDetailsRoute),
        builder: (context) => ProductDetailsPage(
          product: settings.arguments as Product,
        ),
      );
    //chat page
    case AppRoutes.chatRoute:
      return FirestoreChat().chatPageWidget(
        settings.arguments as ChatEntity,
      );

    //
    case AppRoutes.editProfileRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.editProfileRoute),
        builder: (context) => EditProfilePage(),
      );

    //change password
    case AppRoutes.changePasswordRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.changePasswordRoute),
        builder: (context) => ChangePasswordPage(),
      );

    //profile settings/actions
    case AppRoutes.notificationsRoute:
      return MaterialPageRoute(
        settings:
            RouteSettings(name: AppRoutes.notificationsRoute, arguments: Map()),
        builder: (context) => NotificationsPage(),
      );

    //
    case AppRoutes.notificationDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(
            name: AppRoutes.notificationDetailsRoute, arguments: Map()),
        builder: (context) => NotificationDetailsPage(
          notification: settings.arguments as NotificationModel,
        ),
      );

    // Terms and Privacy Policy routes
    case '/terms':
      return MaterialPageRoute(builder: (context) => TermsConditionsPage());
    
    case '/privacy':
      return MaterialPageRoute(builder: (context) => PrivacyPolicyPage());

    default:
      // Redirect to login instead of onboarding
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
