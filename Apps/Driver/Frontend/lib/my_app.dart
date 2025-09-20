import 'package:flutter/material.dart';
import 'package:fuodz/views/pages/splash.page.dart';
import 'package:fuodz/views/pages/welcome.page.dart';
import 'package:fuodz/views/pages/language_selection.page.dart';
import 'package:fuodz/views/pages/auth/login.page.dart';
import 'package:fuodz/views/pages/auth/register.page.dart';
import 'package:fuodz/views/pages/auth/forgot_password.page.dart';

import 'package:fuodz/services/language.service.dart';
import 'package:provider/provider.dart';
import 'package:fuodz/views/pages/dashboard/dashboard.page.dart';
import 'package:fuodz/views/pages/ride_requests/ride_requests.page.dart';
import 'package:fuodz/views/pages/home/home.page.dart';
import 'package:fuodz/views/pages/bookings/ongoing_service.page.dart';
import 'package:fuodz/views/pages/wallet/wallet.page.dart';
import 'package:fuodz/views/pages/profile/profile.page.dart';
import 'package:fuodz/views/pages/emergency_sos/emergency_sos.page.dart';
import 'package:fuodz/views/pages/notifications/notifications.page.dart';
import 'package:fuodz/views/pages/complaints/complaints.page.dart';
import 'package:fuodz/views/pages/about_us/about_us.page.dart';
import 'package:fuodz/views/pages/edit_profile/edit_profile.page.dart';
import 'package:fuodz/views/pages/my_vehicles/my_vehicles.page.dart';
import 'package:fuodz/views/pages/my_documents/my_documents.page.dart';
import 'package:fuodz/views/pages/settings.page.dart';
import 'package:fuodz/views/pages/service_history.page.dart';
import 'package:fuodz/views/pages/firebase_status.page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageService()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Classy Driver",
        home: SplashPage(),
        routes: {
          '/welcome': (context) => WelcomePage(),
          '/language': (context) => LanguageSelectionPage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/forgot-password': (context) => ForgotPasswordPage(),

                                '/dashboard': (context) => DashboardPage(),
                      '/ride-requests': (context) => RideRequestsPage(),
                      '/home': (context) => HomePage(),
          '/bookings': (context) => OngoingServicePage(),
          '/ongoing-service': (context) => OngoingServicePage(),
          '/service-history': (context) => ServiceHistoryPage(),
          '/wallet': (context) => WalletPage(),
          '/profile': (context) => ProfilePage(),
          '/emergency-sos': (context) => EmergencySosPage(),
          '/notifications': (context) => NotificationsPage(),
          '/complaints': (context) => ComplaintsPage(),
          '/about-us': (context) => AboutUsPage(),
          '/edit-profile': (context) => EditProfilePage(),
          '/my-vehicles': (context) => MyVehiclesPage(),
          '/my-documents': (context) => MyDocumentsPage(),
          '/settings': (context) => SettingsPage(),
          '/firebase-status': (context) => FirebaseStatusPage(),
        },
        theme: ThemeData(
          primarySwatch: Colors.pink,
          primaryColor: Color(0xFFE91E63),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFFE91E63),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE91E63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFFE91E63),
              side: BorderSide(color: Color(0xFFE91E63)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

