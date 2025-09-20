import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to handle authentication migration from old email formats to new unified system
class AuthMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Migrate user from old email format to new unified format
  /// This helps users who were registered with direct emails to continue using the app
  static Future<bool> migrateUserToUnifiedFormat(String phoneNumber) async {
    try {
      print("🔄 Starting migration for phone: $phoneNumber");
      
      // Get user data from Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        print("❌ No user found for migration");
        return false;
      }
      
      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final currentEmail = userData['email'] as String;
      
      // Check if user is already using the new format
      final expectedEmail = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
      if (currentEmail == expectedEmail) {
        print("✅ User already using unified format");
        return true;
      }
      
      print("📧 Current email: $currentEmail");
      print("📧 Expected email: $expectedEmail");
      
      // Check if the expected email already exists in Firebase Auth
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(expectedEmail);
        if (methods.isNotEmpty) {
          print("⚠️ Expected email already exists in Firebase Auth");
          return false;
        }
      } catch (e) {
        // Email doesn't exist, which is good
        print("✅ Expected email is available");
      }
      
      // Update the user document in Firestore with the new email format
      await userDoc.reference.update({
        'email': expectedEmail,
        'migratedAt': FieldValue.serverTimestamp(),
        'originalEmail': currentEmail, // Keep track of original email
      });
      
      print("✅ User migrated successfully to unified format");
      return true;
      
    } catch (e) {
      print("❌ Migration failed: $e");
      return false;
    }
  }

  /// Check if user needs migration
  static Future<bool> needsMigration(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return false;
      }
      
      final userData = querySnapshot.docs.first.data();
      final currentEmail = userData['email'] as String;
      final expectedEmail = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
      
      return currentEmail != expectedEmail;
    } catch (e) {
      print("❌ Error checking migration status: $e");
      return false;
    }
  }

  /// Get all users that need migration (for admin purposes)
  static Future<List<Map<String, dynamic>>> getUsersNeedingMigration() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .get();
      
      final usersNeedingMigration = <Map<String, dynamic>>[];
      
      for (final doc in querySnapshot.docs) {
        final userData = doc.data();
        final phone = userData['phone'] as String?;
        final email = userData['email'] as String?;
        
        if (phone != null && email != null) {
          final expectedEmail = "${phone.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
          if (email != expectedEmail) {
            usersNeedingMigration.add({
              'id': doc.id,
              'phone': phone,
              'currentEmail': email,
              'expectedEmail': expectedEmail,
              'name': userData['name'],
            });
          }
        }
      }
      
      return usersNeedingMigration;
    } catch (e) {
      print("❌ Error getting users needing migration: $e");
      return [];
    }
  }
}
