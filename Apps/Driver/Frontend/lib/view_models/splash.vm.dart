import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:stacked/stacked.dart';

class SplashViewModel extends BaseViewModel {
  final BuildContext viewContext;

  SplashViewModel(this.viewContext);

  //
  initialise() async {
    // Show splash screen for 3 seconds, then navigate to login
    await Future.delayed(Duration(seconds: 3));
    loadNextPage();
  }

  //
  loadNextPage() async {
    try {
      // Navigate directly to login page
      Navigator.of(viewContext).pushReplacementNamed(AppRoutes.loginRoute);
    } catch (e) {
      print("Navigation error: $e");
      // Fallback: show a simple message
      showDialog(
        context: viewContext,
        builder: (context) => AlertDialog(
          title: Text('Welcome to Classy Driver'),
          content: Text('App is ready! Navigation will be implemented next.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
