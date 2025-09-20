import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_init_service.dart';
import 'services/settings_service.dart';
import 'screens/professional_splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/professional_login_screen.dart';
import 'screens/auth/professional_register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'constants/app_theme.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.instance.initialize();
  
  // Initialize Firestore collections
  await FirestoreInitService.instance.initializeCollections();
  
  // Initialize Settings
  await SettingsService.instance.initialize();
  
  runApp(const VendorApp());
}

class VendorApp extends StatelessWidget {
  const VendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService.instance),
        ChangeNotifierProvider(create: (_) => SettingsService.instance),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Class Vendor',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            debugShowCheckedModeBanner: false,
            home: const ProfessionalSplashScreen(),
                  routes: {
                    '/onboarding': (context) => const OnboardingScreen(),
                    '/login': (context) => const ProfessionalLoginScreen(),
                    '/register': (context) => const ProfessionalRegisterScreen(),
                    '/dashboard': (context) => const DashboardScreen(),
                  },
          );
        },
      ),
    );
  }
}