import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Classy/services/auth_migration.service.dart';

class AuthValidationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Validate if a phone number is already registered
  static Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      print("🔍 Checking if phone number is registered: $phoneNumber");
      
      // Query users collection for the phone number
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      final isRegistered = querySnapshot.docs.isNotEmpty;
      print("📱 Phone number $phoneNumber is ${isRegistered ? 'registered' : 'not registered'}");
      
      return isRegistered;
    } catch (e) {
      print("❌ Error checking phone number registration: $e");
      return false;
    }
  }

  /// Get user data by phone number
  static Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
    try {
      print("🔍 Getting user data for phone: $phoneNumber");
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        print("✅ User data found: ${userData['name']} (${userData['email']})");
        return userData;
      } else {
        print("❌ No user found with phone number: $phoneNumber");
        return null;
      }
    } catch (e) {
      print("❌ Error getting user by phone: $e");
      return null;
    }
  }

  /// Validate login credentials
  static Future<Map<String, dynamic>?> validateLoginCredentials(
    String phoneNumber,
    String password,
  ) async {
    try {
      print("🔐 Validating login credentials for phone: $phoneNumber");
      
      // Get user data from Firestore
      final userData = await getUserByPhone(phoneNumber);
      if (userData == null) {
        print("❌ No user found with this phone number");
        return null;
      }

      final storedEmail = userData['email'] as String;
      print("🔍 Verifying credentials:");
      print("   Phone: $phoneNumber");
      print("   Stored email: $storedEmail");
      
      // Try to authenticate with the stored email (works for both old and new formats)
      try {
        print("✅ Attempting Firebase authentication with stored email: $storedEmail");
        
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: storedEmail,
          password: password,
        );
        
        if (userCredential.user != null) {
          print("✅ Firebase authentication successful");
          return {
            'success': true,
            'user': userCredential.user,
            'userData': userData,
          };
        }
      } catch (firebaseError) {
        print("❌ Firebase authentication failed: $firebaseError");
        
        // If the stored email doesn't work, try the generated email format
        final generatedEmail = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
        if (storedEmail != generatedEmail) {
          print("🔄 Trying with generated email format: $generatedEmail");
          try {
            final userCredential = await _auth.signInWithEmailAndPassword(
              email: generatedEmail,
              password: password,
            );
            
            if (userCredential.user != null) {
              print("✅ Firebase authentication successful with generated email");
              
              // Attempt to migrate the user to the unified format
              print("🔄 Attempting to migrate user to unified format...");
              await AuthMigrationService.migrateUserToUnifiedFormat(phoneNumber);
              
              return {
                'success': true,
                'user': userCredential.user,
                'userData': userData,
              };
            }
          } catch (generatedEmailError) {
            print("❌ Generated email authentication also failed: $generatedEmailError");
          }
        }
        
        return {
          'success': false,
          'error': firebaseError.toString(),
        };
      }
      
      print("❌ Email format mismatch - user may have been registered differently");
      return {
        'success': false,
        'error': 'Phone number not found or registered with different method',
      };
    } catch (e) {
      print("❌ Error validating login credentials: $e");
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Check if user exists in Firebase Auth
  static Future<bool> userExistsInFirebaseAuth(String email) async {
    try {
      print("🔍 Checking if user exists in Firebase Auth: $email");
      
      // Try to sign in with a dummy password to check if user exists
      // This will fail with 'wrong-password' if user exists, or 'user-not-found' if not
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: 'dummy_password_check',
        );
        // If we get here, the password was correct (unlikely)
        return true;
      } catch (e) {
        if (e.toString().contains('wrong-password')) {
          print("✅ User exists in Firebase Auth (wrong password error)");
          return true;
        } else if (e.toString().contains('user-not-found')) {
          print("❌ User does not exist in Firebase Auth");
          return false;
        } else {
          print("⚠️ Unexpected error checking user existence: $e");
          return false;
        }
      }
    } catch (e) {
      print("❌ Error checking user existence: $e");
      return false;
    }
  }

  /// Get all registered phone numbers (for debugging)
  static Future<List<String>> getAllRegisteredPhones() async {
    try {
      print("🔍 Getting all registered phone numbers...");
      
      final querySnapshot = await _firestore
          .collection('users')
          .get();
      
      final phones = querySnapshot.docs
          .map((doc) => doc.data()['phone'] as String?)
          .where((phone) => phone != null)
          .cast<String>()
          .toList();
      
      print("📱 Found ${phones.length} registered phone numbers: $phones");
      return phones;
    } catch (e) {
      print("❌ Error getting registered phones: $e");
      return [];
    }
  }
}
