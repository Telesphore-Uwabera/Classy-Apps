import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../../services/auth_service.dart';
import '../../../constants/simple_app_colors.dart';
import '../../../constants/simple_app_strings.dart';
import '../../../widgets/custom_button.dart';
import 'profile_settings_screen.dart';
import 'business_settings_screen.dart';
import 'payment_accounts_screen.dart';
import 'printer_settings_screen.dart';

class ProfessionalSettingsScreen extends StatefulWidget {
  const ProfessionalSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalSettingsScreen> createState() => _ProfessionalSettingsScreenState();
}

class _ProfessionalSettingsScreenState extends State<ProfessionalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: "Settings".text.xl.bold.make(),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionHeader("Profile"),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.person,
                title: "Profile Settings",
                subtitle: "Manage your personal information",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.business,
                title: "Business Settings",
                subtitle: "Configure your business details",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BusinessSettingsScreen(),
                    ),
                  );
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Financial Section
            _buildSectionHeader("Financial"),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.account_balance,
                title: "Payment Accounts",
                subtitle: "Manage your payment methods",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentAccountsScreen(),
                    ),
                  );
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // System Section
            _buildSectionHeader("System"),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.print,
                title: "Printer Settings",
                subtitle: "Configure receipt printing",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrinterSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.notifications,
                title: "Notifications",
                subtitle: "Manage notification preferences",
                onTap: () {
                  // TODO: Implement notifications settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications settings coming soon'),
                      backgroundColor: AppColor.infoColor,
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.language,
                title: "Language",
                subtitle: "Change app language",
                onTap: () {
                  // TODO: Implement language settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language settings coming soon'),
                      backgroundColor: AppColor.infoColor,
                    ),
                  );
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Support Section
            _buildSectionHeader("Support"),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.help,
                title: "Help & Support",
                subtitle: "Get help and contact support",
                onTap: () {
                  // TODO: Implement help & support
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help & support coming soon'),
                      backgroundColor: AppColor.infoColor,
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.info,
                title: "About",
                subtitle: "App version and information",
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Logout Section
            _buildSectionHeader("Account"),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.logout,
                title: "Sign Out",
                subtitle: "Sign out of your account",
                onTap: _showLogoutDialog,
                textColor: AppColor.errorColor,
                iconColor: AppColor.errorColor,
              ),
            ]),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColor.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColor.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColor.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: "1.0.0",
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.storefront,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text("Professional vendor management app for Classy platform."),
        const SizedBox(height: 16),
        const Text("Built with Flutter and Firebase."),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
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
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColor.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
