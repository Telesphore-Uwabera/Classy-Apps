import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuodz/services/alert.service.dart';

class DriverStatusService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if driver is approved and can login
  static Future<Map<String, dynamic>> validateDriverStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'canLogin': false,
          'reason': 'No authenticated user',
          'status': 'error'
        };
      }

      // Get driver document from Firestore
      final driverDoc = await _firestore
          .collection('drivers')
          .doc(user.uid)
          .get();

      if (!driverDoc.exists) {
        return {
          'canLogin': false,
          'reason': 'Driver profile not found',
          'status': 'error'
        };
      }

      final driverData = driverDoc.data()!;
      final status = driverData['status'] ?? 'unknown';

      switch (status) {
        case 'approved':
          return {
            'canLogin': true,
            'reason': 'Driver approved',
            'status': 'approved',
            'driverData': driverData
          };
        
        case 'pending':
          return {
            'canLogin': false,
            'reason': 'Your account is pending admin approval. Please wait for approval.',
            'status': 'pending'
          };
        
        case 'rejected':
          return {
            'canLogin': false,
            'reason': 'Your account has been rejected. Please contact support.',
            'status': 'rejected'
          };
        
        case 'suspended':
          return {
            'canLogin': false,
            'reason': 'Your account has been suspended. Please contact support.',
            'status': 'suspended'
          };
        
        default:
          return {
            'canLogin': false,
            'reason': 'Unknown account status. Please contact support.',
            'status': 'unknown'
          };
      }
    } catch (e) {
      return {
        'canLogin': false,
        'reason': 'Error checking driver status: $e',
        'status': 'error'
      };
    }
  }

  /// Get driver status for display
  static Future<String> getDriverStatus() async {
    final validation = await validateDriverStatus();
    return validation['status'] ?? 'unknown';
  }

  /// Check if driver can access the app
  static Future<bool> canDriverAccessApp() async {
    final validation = await validateDriverStatus();
    return validation['canLogin'] ?? false;
  }

  /// Show appropriate message based on status
  static void showStatusMessage(Map<String, dynamic> validation) {
    if (!validation['canLogin']) {
      // This will be handled by the login view model with detailed dialogs
      print("Driver access denied: ${validation['reason']}");
    }
  }
}
