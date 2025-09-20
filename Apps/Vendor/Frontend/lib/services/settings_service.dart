import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SettingsService extends ChangeNotifier {
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();
  
  SettingsService._();

  // Notification settings
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  
  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  
  // Language settings
  String _language = 'en';
  
  // Business settings
  bool _autoAcceptOrders = false;
  bool _lowStockAlerts = true;
  bool _dailyReports = true;
  bool _orderSoundNotifications = true;

  // Getters
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get autoAcceptOrders => _autoAcceptOrders;
  bool get lowStockAlerts => _lowStockAlerts;
  bool get dailyReports => _dailyReports;
  bool get orderSoundNotifications => _orderSoundNotifications;

  // Initialize settings from SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    _pushNotificationsEnabled = prefs.getBool('push_notifications') ?? true;
    _emailNotificationsEnabled = prefs.getBool('email_notifications') ?? true;
    _themeMode = ThemeMode.values[prefs.getInt('theme_mode') ?? 0];
    _language = prefs.getString('language') ?? 'en';
    _autoAcceptOrders = prefs.getBool('auto_accept_orders') ?? false;
    _lowStockAlerts = prefs.getBool('low_stock_alerts') ?? true;
    _dailyReports = prefs.getBool('daily_reports') ?? true;
    _orderSoundNotifications = prefs.getBool('order_sound_notifications') ?? true;
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('push_notifications', _pushNotificationsEnabled);
    await prefs.setBool('email_notifications', _emailNotificationsEnabled);
    await prefs.setInt('theme_mode', _themeMode.index);
    await prefs.setString('language', _language);
    await prefs.setBool('auto_accept_orders', _autoAcceptOrders);
    await prefs.setBool('low_stock_alerts', _lowStockAlerts);
    await prefs.setBool('daily_reports', _dailyReports);
    await prefs.setBool('order_sound_notifications', _orderSoundNotifications);
  }

  // Notification settings
  Future<void> setPushNotifications(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool enabled) async {
    _emailNotificationsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Theme settings
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveSettings();
    notifyListeners();
  }

  // Language settings
  Future<void> setLanguage(String languageCode) async {
    _language = languageCode;
    await _saveSettings();
    notifyListeners();
  }

  // Business settings
  Future<void> setAutoAcceptOrders(bool enabled) async {
    _autoAcceptOrders = enabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLowStockAlerts(bool enabled) async {
    _lowStockAlerts = enabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDailyReports(bool enabled) async {
    _dailyReports = enabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setOrderSoundNotifications(bool enabled) async {
    _orderSoundNotifications = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Get dynamic icon based on setting state
  IconData getNotificationIcon(bool isEnabled) {
    return isEnabled ? Icons.notifications : Icons.notifications_off;
  }

  IconData getEmailIcon(bool isEnabled) {
    return isEnabled ? Icons.email : Icons.email_outlined;
  }

  IconData getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.auto_mode;
    }
  }

  IconData getLanguageIcon(String language) {
    switch (language) {
      case 'en':
        return Icons.language;
      case 'es':
        return Icons.flag;
      case 'fr':
        return Icons.flag;
      default:
        return Icons.language;
    }
  }

  IconData getBusinessIcon(String setting, bool isEnabled) {
    switch (setting) {
      case 'auto_accept':
        return isEnabled ? Icons.check_circle : Icons.radio_button_unchecked;
      case 'low_stock':
        return isEnabled ? Icons.warning : Icons.warning_outlined;
      case 'daily_reports':
        return isEnabled ? Icons.analytics : Icons.analytics_outlined;
      case 'sound_notifications':
        return isEnabled ? Icons.volume_up : Icons.volume_off;
      default:
        return Icons.settings;
    }
  }

  // Get setting status text
  String getSettingStatusText(String setting, bool isEnabled) {
    switch (setting) {
      case 'push_notifications':
        return isEnabled ? 'Enabled' : 'Disabled';
      case 'email_notifications':
        return isEnabled ? 'Enabled' : 'Disabled';
      case 'auto_accept_orders':
        return isEnabled ? 'Auto-accepting orders' : 'Manual order approval';
      case 'low_stock_alerts':
        return isEnabled ? 'Alerts enabled' : 'Alerts disabled';
      case 'daily_reports':
        return isEnabled ? 'Reports enabled' : 'Reports disabled';
      case 'sound_notifications':
        return isEnabled ? 'Sound enabled' : 'Sound disabled';
      default:
        return isEnabled ? 'On' : 'Off';
    }
  }

  // Get theme display name
  String getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get language display name
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    _pushNotificationsEnabled = true;
    _emailNotificationsEnabled = true;
    _themeMode = ThemeMode.system;
    _language = 'en';
    _autoAcceptOrders = false;
    _lowStockAlerts = true;
    _dailyReports = true;
    _orderSoundNotifications = true;
    
    await _saveSettings();
    notifyListeners();
  }
}
