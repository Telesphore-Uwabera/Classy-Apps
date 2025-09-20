import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/settings_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../constants/app_theme.dart';
import 'business_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'printer_settings_screen.dart';
import 'payment_accounts_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _settingsService.initialize();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<SettingsService>(
      builder: (context, settings, child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSectionCard(
            'Profile',
            [
              _buildSettingsItem(
                icon: Icons.person,
                title: 'Profile Settings',
                subtitle: 'Manage your personal information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Business Section
          _buildSectionCard(
            'Business',
            [
              _buildSettingsItem(
                icon: Icons.business,
                title: 'Business Settings',
                subtitle: 'Manage your business information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BusinessSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.print,
                title: 'Printer Settings',
                subtitle: 'Configure receipt and order printing',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrinterSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.account_balance_wallet,
                title: 'Payment Accounts',
                subtitle: 'Manage payment methods and accounts',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentAccountsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.location_on,
                title: 'Delivery Zones',
                subtitle: 'Configure delivery areas',
                onTap: () {
                  // Navigate to delivery zones
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigate to delivery zones')),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Notifications Section
          _buildSectionCard(
            'Notifications',
            [
              _buildSettingsItem(
                icon: _settingsService.getNotificationIcon(settings.pushNotificationsEnabled),
                title: 'Push Notifications',
                subtitle: _settingsService.getSettingStatusText('push_notifications', settings.pushNotificationsEnabled),
                trailing: Switch(
                  value: settings.pushNotificationsEnabled,
                  onChanged: (value) async {
                    await _settingsService.setPushNotifications(value);
                    setState(() {});
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              _buildSettingsItem(
                icon: _settingsService.getEmailIcon(settings.emailNotificationsEnabled),
                title: 'Email Notifications',
                subtitle: _settingsService.getSettingStatusText('email_notifications', settings.emailNotificationsEnabled),
                trailing: Switch(
                  value: settings.emailNotificationsEnabled,
                  onChanged: (value) async {
                    await _settingsService.setEmailNotifications(value);
                    setState(() {});
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // App Section
          _buildSectionCard(
            'App',
            [
              _buildSettingsItem(
                icon: _settingsService.getThemeIcon(settings.themeMode),
                title: 'Theme',
                subtitle: _settingsService.getThemeDisplayName(settings.themeMode),
                onTap: () {
                  _showThemeDialog();
                },
              ),
              _buildSettingsItem(
                icon: _settingsService.getLanguageIcon(settings.language),
                title: 'Language',
                subtitle: _settingsService.getLanguageDisplayName(settings.language),
                onTap: () {
                  _showLanguageDialog();
                },
              ),
              _buildSettingsItem(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  _showHelpDialog();
                },
              ),
              _buildSettingsItem(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Logout Button
          CustomButton(
            text: 'Logout',
            onPressed: () => _showLogoutDialog(),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.light_mode,
                color: _settingsService.themeMode == ThemeMode.light ? AppTheme.primaryColor : null,
              ),
              title: Text(
                'Light',
                style: TextStyle(
                  color: _settingsService.themeMode == ThemeMode.light ? AppTheme.primaryColor : null,
                  fontWeight: _settingsService.themeMode == ThemeMode.light ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _settingsService.setThemeMode(ThemeMode.light);
                setState(() {});
              },
            ),
            ListTile(
              leading: Icon(
                Icons.dark_mode,
                color: _settingsService.themeMode == ThemeMode.dark ? AppTheme.primaryColor : null,
              ),
              title: Text(
                'Dark',
                style: TextStyle(
                  color: _settingsService.themeMode == ThemeMode.dark ? AppTheme.primaryColor : null,
                  fontWeight: _settingsService.themeMode == ThemeMode.dark ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _settingsService.setThemeMode(ThemeMode.dark);
                setState(() {});
              },
            ),
            ListTile(
              leading: Icon(
                Icons.auto_mode,
                color: _settingsService.themeMode == ThemeMode.system ? AppTheme.primaryColor : null,
              ),
              title: Text(
                'System',
                style: TextStyle(
                  color: _settingsService.themeMode == ThemeMode.system ? AppTheme.primaryColor : null,
                  fontWeight: _settingsService.themeMode == ThemeMode.system ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _settingsService.setThemeMode(ThemeMode.system);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.language,
                color: _settingsService.language == 'en' ? AppTheme.primaryColor : null,
              ),
              title: Text(
                'English',
                style: TextStyle(
                  color: _settingsService.language == 'en' ? AppTheme.primaryColor : null,
                  fontWeight: _settingsService.language == 'en' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _settingsService.setLanguage('en');
                setState(() {});
              },
            ),
            ListTile(
              leading: Icon(
                Icons.flag,
                color: _settingsService.language == 'es' ? AppTheme.primaryColor : null,
              ),
              title: Text(
                'Español',
                style: TextStyle(
                  color: _settingsService.language == 'es' ? AppTheme.primaryColor : null,
                  fontWeight: _settingsService.language == 'es' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _settingsService.setLanguage('es');
                setState(() {});
              },
            ),
            ListTile(
              leading: Icon(
                Icons.flag,
                color: _settingsService.language == 'fr' ? AppTheme.primaryColor : null,
              ),
              title: Text(
                'Français',
                style: TextStyle(
                  color: _settingsService.language == 'fr' ? AppTheme.primaryColor : null,
                  fontWeight: _settingsService.language == 'fr' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _settingsService.setLanguage('fr');
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 8),
            Text('📧 Email: support@classyapps.com'),
            Text('📞 Phone: +1 (555) 123-4567'),
            Text('💬 Live Chat: Available 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Classy Apps - Vendor App'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 2024.01.01'),
            SizedBox(height: 8),
            Text('© 2024 Classy Apps. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}