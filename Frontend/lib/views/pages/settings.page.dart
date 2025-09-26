import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _locationServices = true;
  bool _darkMode = false;
  bool _biometricAuth = false;

  Future<String> _version() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}';
  }

  void _togglePushNotifications(bool value) {
    setState(() {
      _pushNotifications = value;
    });
    // TODO: Save to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? "Push notifications enabled" : "Push notifications disabled"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleLocationServices(bool value) {
    setState(() {
      _locationServices = value;
    });
    // TODO: Save to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? "Location services enabled" : "Location services disabled"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
    // TODO: Implement dark mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? "Dark mode enabled" : "Dark mode disabled"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleBiometricAuth(bool value) {
    setState(() {
      _biometricAuth = value;
    });
    // TODO: Implement biometric authentication
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? "Biometric authentication enabled" : "Biometric authentication disabled"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Settings'.tr(),
      body: VStack([
        _SectionHeader(title: 'Notifications'.tr()),
        _TileSwitch(
          icon: Icons.notifications_active_outlined,
          title: 'Push Notifications'.tr(),
          value: _pushNotifications,
          onChanged: _togglePushNotifications,
        ),
        _Tile(
          icon: Icons.email_outlined,
          title: 'Email Preferences'.tr(),
          onTap: () => Navigator.of(context).pushNamed('email_preferences'),
        ),
        16.heightBox,
        _SectionHeader(title: 'Privacy & Location'.tr()),
        _TileSwitch(
          icon: Icons.my_location_outlined,
          title: 'Location Services'.tr(),
          value: _locationServices,
          onChanged: _toggleLocationServices,
        ),
        _TileSwitch(
          icon: Icons.fingerprint_outlined,
          title: 'Biometric Authentication'.tr(),
          value: _biometricAuth,
          onChanged: _toggleBiometricAuth,
        ),
        _Tile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy'.tr(),
          onTap: () => NavigationService.navigateToPrivacyPolicy(),
        ),
        _Tile(
          icon: Icons.description_outlined,
          title: 'Terms of Service'.tr(),
          onTap: () => NavigationService.navigateToTermsConditions(),
        ),
        16.heightBox,
        _SectionHeader(title: 'Appearance'.tr()),
        _TileSwitch(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode'.tr(),
          value: _darkMode,
          onChanged: _toggleDarkMode,
        ),
        16.heightBox,
        _SectionHeader(title: 'About'.tr()),
        FutureBuilder<String>(
          future: _version(),
          builder: (context, snap) => _Tile(
            icon: Icons.info_outline,
            title: 'App Version'.tr(),
            trailing: (snap.data ?? '—').text.make(),
          ),
        ),
        _Tile(
          icon: Icons.star_outline,
          title: 'Rate the App'.tr(),
          onTap: () => launchUrlString('https://play.google.com/store/apps/details?id=com.example.app'),
        ),
        _Tile(
          icon: Icons.credit_card_outlined,
          title: 'Payment Methods'.tr(),
          onTap: () => Navigator.of(context).pushNamed('payment_methods'),
        ),
        _Tile(
          icon: Icons.support_agent_outlined,
          title: 'Contact Support'.tr(),
          onTap: () => Navigator.of(context).pushNamed('help_support'),
        ),
      ]).p20().scrollVertical(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return VStack([
      12.heightBox,
      title.text.semiBold.make(),
      8.heightBox,
      Divider(height: 1, color: Colors.grey.shade300),
    ]);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColor.faintBgColor,
        child: Icon(icon, color: AppColor.primaryColor),
      ),
      title: title.text.make(),
      trailing: trailing ?? Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _TileSwitch extends StatelessWidget {
  const _TileSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      secondary: CircleAvatar(
        backgroundColor: AppColor.faintBgColor,
        child: Icon(icon, color: AppColor.primaryColor),
      ),
      title: title.text.make(),
      value: value,
      onChanged: onChanged,
      activeColor: AppColor.primaryColor,
    );
  }
}


