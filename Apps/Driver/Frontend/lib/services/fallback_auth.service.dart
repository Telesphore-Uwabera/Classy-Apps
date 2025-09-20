import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FallbackAuthService {
  static const String _userKey = 'fallback_user';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Register a user using fallback authentication
  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      // Generate a mock user ID
      final userId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      
      final user = {
        'id': userId,
        'name': userData['name'],
        'phone': userData['phone'],
        'email': userData['email'],
        'role': 'driver',
        'service_type': userData['service_type'],
        'address': userData['address'],
        'country_code': userData['country_code'],
        'driver_type': userData['driver_type'],
        'is_active': true,
        'is_online': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'status': 'pending', // New drivers need approval
        'is_fallback_user': true, // Mark as fallback user
      };

      // Save user to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user));
      await prefs.setBool(_isLoggedInKey, true);

      return user;
    } catch (e) {
      throw Exception('Fallback registration failed: $e');
    }
  }

  /// Login a user using fallback authentication
  static Future<Map<String, dynamic>?> loginUser(String phone, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        
        // Simple phone number matching (in real app, you'd verify password)
        if (user['phone'] == phone) {
          await prefs.setBool(_isLoggedInKey, true);
          return user;
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Fallback login failed: $e');
    }
  }

  /// Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_isLoggedInKey);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  /// Update user data
  static Future<void> updateUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        user.addAll(userData);
        user['updated_at'] = DateTime.now().toIso8601String();
        
        await prefs.setString(_userKey, jsonEncode(user));
      }
    } catch (e) {
      print('Update user error: $e');
    }
  }
}
