import 'package:shared_preferences/shared_preferences.dart';

class LocationPreferencesService {
  static const String _workAddressKey = 'work_address';
  static const String _homeAddressKey = 'home_address';
  static const String _currentLocationKey = 'current_location';
  
  static final LocationPreferencesService _instance = LocationPreferencesService._internal();
  factory LocationPreferencesService() => _instance;
  LocationPreferencesService._internal();

  // Get work address
  Future<String?> getWorkAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_workAddressKey);
  }

  // Set work address
  Future<bool> setWorkAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_workAddressKey, address);
  }

  // Get home address
  Future<String?> getHomeAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_homeAddressKey);
  }

  // Set home address
  Future<bool> setHomeAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_homeAddressKey, address);
  }

  // Clear work address
  Future<bool> clearWorkAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_workAddressKey);
  }

  // Clear home address
  Future<bool> clearHomeAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_homeAddressKey);
  }

  // Get formatted work address for display
  Future<String> getFormattedWorkAddress() async {
    final address = await getWorkAddress();
    return address ?? "Not set";
  }

  // Get formatted home address for display
  Future<String> getFormattedHomeAddress() async {
    final address = await getHomeAddress();
    return address ?? "Not set";
  }

  // Get current location
  Future<String?> getCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentLocationKey);
  }

  // Set current location
  Future<bool> saveCurrentLocation(String address) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_currentLocationKey, address);
  }

  // Clear current location
  Future<bool> clearCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_currentLocationKey);
  }
}
