import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/constants/app_colors.dart';

class LocationPermissionHelper {
  static void showLocationPermissionDialog(BuildContext context, {
    required VoidCallback onRetry,
    required VoidCallback onUseMap,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 8),
            "Location Access Required".text.bold.make(),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "To use your current location, please:".text.make(),
            SizedBox(height: 12),
            "1. Click 'Allow' when your browser asks for location permission".text.sm.make(),
            SizedBox(height: 8),
            "2. Make sure location services are enabled in your browser".text.sm.make(),
            SizedBox(height: 8),
            "3. Try refreshing the page if permission was previously denied".text.sm.make(),
            SizedBox(height: 16),
            "Alternatively, you can select your location on the map.".text.gray600.sm.make(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onUseMap();
            },
            child: "Use Map Instead".text.color(Colors.grey).make(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
            ),
            child: "Try Again".text.white.make(),
          ),
        ],
      ),
    );
  }

  static void showLocationDisabledDialog(BuildContext context, {
    required VoidCallback onUseMap,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_disabled, color: Colors.red),
            SizedBox(width: 8),
            "Location Services Disabled".text.bold.make(),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "Location services are disabled in your browser.".text.make(),
            SizedBox(height: 12),
            "To enable location services:".text.bold.make(),
            SizedBox(height: 8),
            "• Chrome: Click the location icon in the address bar".text.sm.make(),
            SizedBox(height: 4),
            "• Firefox: Click the shield icon and allow location".text.sm.make(),
            SizedBox(height: 4),
            "• Safari: Go to Safari > Preferences > Websites > Location".text.sm.make(),
            SizedBox(height: 16),
            "Or you can select your location on the map below.".text.gray600.sm.make(),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUseMap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
            ),
            child: "Select on Map".text.white.make(),
          ),
        ],
      ),
    );
  }

  static void showLocationTimeoutDialog(BuildContext context, {
    required VoidCallback onRetry,
    required VoidCallback onUseMap,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange),
            SizedBox(width: 8),
            "Location Request Timed Out".text.bold.make(),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            "The location request took too long to complete.".text.make(),
            SizedBox(height: 12),
            "This might be due to:".text.bold.make(),
            SizedBox(height: 8),
            "• Slow internet connection".text.sm.make(),
            SizedBox(height: 4),
            "• GPS signal issues".text.sm.make(),
            SizedBox(height: 4),
            "• Browser restrictions".text.sm.make(),
            SizedBox(height: 16),
            "You can try again or select your location on the map.".text.gray600.sm.make(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onUseMap();
            },
            child: "Use Map Instead".text.color(Colors.grey).make(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
            ),
            child: "Try Again".text.white.make(),
          ),
        ],
      ),
    );
  }
}
