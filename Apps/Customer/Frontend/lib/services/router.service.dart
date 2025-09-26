import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/models/checkout.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/models/app_notification.dart';
import 'package:Classy/models/order.dart';
import 'package:Classy/models/product.dart';
import 'package:Classy/models/search.dart';
import 'package:Classy/models/service.dart';
import 'package:Classy/models/vendor.dart';
import 'package:Classy/views/pages/auth/forgot_password.page.dart';
import 'package:Classy/views/pages/auth/login.page.dart';
import 'package:Classy/views/pages/auth/register.page.dart';
import 'package:Classy/views/pages/checkout/checkout.page.dart';
import 'package:Classy/views/pages/delivery_address/delivery_addresses.page.dart';
import 'package:Classy/views/pages/delivery_address/edit_delivery_addresses.page.dart';
import 'package:Classy/views/pages/delivery_address/new_delivery_addresses.page.dart';
import 'package:Classy/views/pages/favourite/favourites.page.dart';
import 'package:Classy/views/pages/home.page.dart';
import 'package:Classy/views/pages/order/orders_tracking.page.dart';
import 'package:Classy/views/pages/profile/change_password.page.dart';
import 'package:Classy/views/pages/service/service_details.page.dart';
import 'package:Classy/views/pages/vendor_details/vendor_details.page.dart';
import 'package:Classy/views/pages/notification/notification_details.page.dart';
import 'package:Classy/views/pages/notifications/notifications_page.dart';

import 'package:Classy/views/pages/order/orders_details.page.dart';
import 'package:Classy/views/pages/product/product_details.page.dart';
import 'package:Classy/views/pages/profile/edit_profile.page.dart';
import 'package:Classy/views/pages/search/search.page.dart';
// Wallet functionality removed - using Eversend, MoMo, and card payments only
import 'package:Classy/views/shared/location_fetch.page.dart';
import 'package:Classy/views/pages/settings.page.dart';
import 'package:Classy/views/pages/help_support.page.dart';
import 'package:Classy/views/pages/privacy_policy.page.dart';
import 'package:Classy/views/pages/terms_conditions.page.dart';
import 'package:Classy/views/pages/taxi/taxi.page.dart';
import 'package:Classy/views/pages/food/food.page.dart';
import 'package:Classy/views/pages/food/order_confirmation.page.dart';
import 'package:Classy/views/pages/boda/boda.page.dart';
import 'package:Classy/views/pages/ride_history.page.dart';
import 'package:Classy/models/payment_method.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/views/pages/payment_methods.page.dart';
import 'package:Classy/views/pages/location/work_location.page.dart';
import 'package:Classy/views/pages/location/home_location.page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {


    case AppRoutes.loginRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case AppRoutes.registerRoute:
      return MaterialPageRoute(builder: (context) => RegisterPage());

    case AppRoutes.forgotPasswordRoute:
      return MaterialPageRoute(builder: (context) => ForgotPasswordPage());

    case AppRoutes.homeRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.homeRoute, arguments: Map()),
        builder: (context) => HomePage(),
      );

    //SEARCH
    case AppRoutes.search:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.search),
        builder: (context) => SearchPage(search: settings.arguments as Search),
      );

    //Product details
    case AppRoutes.product:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.product),
        builder:
            (context) =>
                ProductDetailsPage(product: settings.arguments as Product),
      );

    //Vendor details
    case AppRoutes.vendorDetails:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.vendorDetails),
        builder:
            (context) =>
                VendorDetailsPage(vendor: settings.arguments as Vendor),
      );
    //Service details
    case AppRoutes.serviceDetails:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.serviceDetails),
        builder: (context) => ServiceDetailsPage(settings.arguments as Service),
      );

    //Checkout page
    case AppRoutes.checkoutRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.checkoutRoute),
        builder:
            (context) => CheckoutPage(checkout: settings.arguments as CheckOut),
      );

    //order details page
    case AppRoutes.orderDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.orderDetailsRoute),
        builder:
            (context) => OrderDetailsPage(order: settings.arguments as Order),
      );
    //order tracking page
    case AppRoutes.orderTrackingRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.orderTrackingRoute),
        builder:
            (context) => OrderTrackingPage(order: settings.arguments as Order),
      );
    //chat page
    case AppRoutes.chatRoute:
      return FirestoreChat().chatPageWidget(settings.arguments as ChatEntity);

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

    //Delivery addresses
    case AppRoutes.deliveryAddressesRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.deliveryAddressesRoute),
        builder: (context) => DeliveryAddressesPage(),
      );
    case AppRoutes.newDeliveryAddressesRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.newDeliveryAddressesRoute),
        builder: (context) => NewDeliveryAddressesPage(),
      );
    case AppRoutes.editDeliveryAddressesRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.editDeliveryAddressesRoute),
        builder:
            (context) => EditDeliveryAddressesPage(
              deliveryAddress: settings.arguments as DeliveryAddress,
            ),
      );

    //wallets
    // Wallet functionality removed - using Eversend, MoMo, and card payments only

    case AppRoutes.paymentMethodsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.paymentMethodsRoute),
        builder: (context) => PaymentMethodsPage(),
      );

    case AppRoutes.settingsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.settingsRoute),
        builder: (context) => SettingsPage(),
      );

    case AppRoutes.helpSupportRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.helpSupportRoute),
        builder: (context) => HelpSupportPage(),
      );

    case AppRoutes.privacyPolicyRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.privacyPolicyRoute),
        builder: (context) => PrivacyPolicyPage(),
      );

    case AppRoutes.termsConditionsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.termsConditionsRoute),
        builder: (context) => TermsConditionsPage(),
      );

    //favourites
    case AppRoutes.favouritesRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.favouritesRoute),
        builder: (context) => FavouritesPage(),
      );

    //profile settings/actions
    case AppRoutes.notificationsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(
          name: AppRoutes.notificationsRoute,
          arguments: Map(),
        ),
        builder: (context) => NotificationsPage(),
      );

    //
    case AppRoutes.notificationDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(
          name: AppRoutes.notificationDetailsRoute,
          arguments: Map(),
        ),
        builder:
            (context) => NotificationDetailsPage(
              notification: settings.arguments as AppNotification,
            ),
      );

    // Taxi/Ride services
    case AppRoutes.taxiRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.taxiRoute),
        builder: (context) => TaxiPage(
          VendorType(
            id: 1,
            name: 'Taxi',
            description: 'Taxi & Ride Services',
            slug: 'taxi',
            color: '#E91E63',
            isActive: 1,
            logo: '',
            hasBanners: false,
          ),
        ),
      );

    // Food services
    case AppRoutes.foodRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.foodRoute),
        builder: (context) => FoodPage(
          VendorType(
            id: 2,
            name: 'Food',
            description: 'Food & Restaurant Services',
            slug: 'food',
            color: '#E91E63',
            isActive: 1,
            logo: '',
            hasBanners: false,
          ),
        ),
      );

    // Boda Boda services
    case AppRoutes.bodabodaRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.bodabodaRoute),
        builder: (context) => BodaPage(
          VendorType(
            id: 3,
            name: 'Boda Boda',
            description: 'Motorcycle Ride Services',
            slug: 'bodaboda',
            color: '#E91E63',
            isActive: 1,
            logo: '',
            hasBanners: false,
          ),
        ),
      );

    // Flights services (placeholder - you can create a dedicated FlightsPage later)
    case AppRoutes.flightsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.flightsRoute),
        builder: (context) => TaxiPage(
          VendorType(
            id: 4,
            name: 'Flights',
            description: 'Flight Booking Services',
            slug: 'flights',
            color: '#E91E63',
            isActive: 1,
            logo: '',
            hasBanners: false,
          ),
        ),
      );
      
    case AppRoutes.rideHistoryRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.rideHistoryRoute),
        builder: (context) => RideHistoryPage(),
      );
      
    case AppRoutes.orderConfirmationRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.orderConfirmationRoute),
        builder: (context) => OrderConfirmationPage(
          orderDetails: settings.arguments as Map<String, dynamic>,
        ),
      );

    case AppRoutes.workLocationRoute:
      return MaterialPageRoute(
        builder: (context) => WorkLocationPage(),
      );

    case AppRoutes.homeLocationRoute:
      return MaterialPageRoute(
        builder: (context) => HomeLocationPage(),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => LoginPage(),
      );
  }
}
