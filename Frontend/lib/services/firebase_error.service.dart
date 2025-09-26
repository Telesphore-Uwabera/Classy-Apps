import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorService {
  // Handle Firebase Auth exceptions
  static String handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // Registration errors
      case 'email-already-in-use':
        return "An account with this phone number already exists.";
      case 'weak-password':
        return "Password is too weak. Please choose a stronger password.";
      case 'invalid-email':
        return "Invalid phone number format.";
      case 'operation-not-allowed':
        return "Registration is not allowed.";
      
      // Login errors
      case 'user-not-found':
        return "No account found with this phone number.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'user-disabled':
        return "Account has been disabled.";
      case 'too-many-requests':
        return "Too many failed attempts. Please try again later.";
      case 'invalid-credential':
        return "Invalid credentials. Please check your phone number and password.";
      
      // Network errors
      case 'network-request-failed':
        return "Network error. Please check your internet connection.";
      case 'timeout':
        return "Request timed out. Please try again.";
      
      // General errors
      case 'unknown':
        return "An unknown error occurred. Please try again.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }

  // Check if error is a network error
  static bool isNetworkError(FirebaseAuthException e) {
    return e.code == 'network-request-failed' || 
           e.code == 'timeout' ||
           e.message?.contains('network') == true;
  }

  // Check if error is a credential error
  static bool isCredentialError(FirebaseAuthException e) {
    return e.code == 'user-not-found' || 
           e.code == 'wrong-password' ||
           e.code == 'invalid-credential';
  }

  // Check if error is a registration error
  static bool isRegistrationError(FirebaseAuthException e) {
    return e.code == 'email-already-in-use' || 
           e.code == 'weak-password' ||
           e.code == 'invalid-email';
  }

  // Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleAuthException(error);
    }
    
    // Handle string errors
    if (error is String) {
      if (error.contains('email-already-in-use')) {
        return "An account with this phone number already exists.";
      } else if (error.contains('weak-password')) {
        return "Password is too weak. Please choose a stronger password.";
      } else if (error.contains('user-not-found')) {
        return "No account found with this phone number.";
      } else if (error.contains('wrong-password')) {
        return "Incorrect password.";
      } else if (error.contains('network')) {
        return "Network error. Please check your internet connection.";
      }
    }
    
    return "An error occurred. Please try again.";
  }
}
