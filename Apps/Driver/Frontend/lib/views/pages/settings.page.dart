import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language.service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationServicesEnabled = true;
  bool _autoAcceptRides = false;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  double _maxDistance = 10.0;
  double _minFare = 500.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE91E63),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(screenWidth, screenHeight),
            
            // General Settings
            _buildSettingsSection(
              'General Settings',
              [
                _buildSwitchTile(
                  'Notifications',
                  'Receive push notifications',
                  Icons.notifications,
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  'Location Services',
                  'Allow location access',
                  Icons.location_on,
                  _locationServicesEnabled,
                  (value) {
                    setState(() {
                      _locationServicesEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  'Auto-accept Rides',
                  'Automatically accept ride requests',
                  Icons.auto_awesome,
                  _autoAcceptRides,
                  (value) {
                    setState(() {
                      _autoAcceptRides = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  'Dark Mode',
                  'Use dark theme',
                  Icons.dark_mode,
                  _darkModeEnabled,
                  (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
              ],
            ),
            
            // Ride Preferences
            _buildSettingsSection(
              'Ride Preferences',
              [
                _buildSliderTile(
                  'Maximum Distance',
                  '${_maxDistance.toStringAsFixed(1)} km',
                  Icons.straighten,
                  _maxDistance,
                  1.0,
                  50.0,
                  (value) {
                    setState(() {
                      _maxDistance = value;
                    });
                  },
                ),
                _buildSliderTile(
                  'Minimum Fare',
                  'RWF ${_minFare.toStringAsFixed(0)}',
                  Icons.attach_money,
                  _minFare,
                  100.0,
                  2000.0,
                  (value) {
                    setState(() {
                      _minFare = value;
                    });
                  },
                ),
              ],
            ),
            
            // Language & Region
            _buildSettingsSection(
              'Language & Region',
              [
                _buildListTile(
                  'Language',
                  _selectedLanguage,
                  Icons.language,
                  () => _showLanguageDialog(),
                ),
                _buildListTile(
                  'Time Zone',
                  'GMT+2 (Kigali)',
                  Icons.access_time,
                  () {},
                ),
                _buildListTile(
                  'Currency',
                  'RWF (Rwandan Franc)',
                  Icons.currency_exchange,
                  () {},
                ),
              ],
            ),
            
            // Privacy & Security
            _buildSettingsSection(
              'Privacy & Security',
              [
                _buildListTile(
                  'Privacy Policy',
                  'View our privacy policy',
                  Icons.privacy_tip,
                  () => _navigateToPrivacyPolicy(),
                ),
                _buildListTile(
                  'Terms of Service',
                  'View terms and conditions',
                  Icons.description,
                  () => _navigateToTermsOfService(),
                ),
                _buildListTile(
                  'Data Usage',
                  'Manage your data preferences',
                  Icons.data_usage,
                  () => _navigateToDataUsage(),
                ),
              ],
            ),
            
            // Support & Help
            _buildSettingsSection(
              'Support & Help',
              [
                _buildListTile(
                  'Help Center',
                  'Get help and support',
                  Icons.help,
                  () => _navigateToHelpCenter(),
                ),
                _buildListTile(
                  'Contact Support',
                  'Reach out to our team',
                  Icons.support_agent,
                  () => _navigateToContactSupport(),
                ),
                _buildListTile(
                  'Report an Issue',
                  'Report bugs or problems',
                  Icons.bug_report,
                  () => _navigateToReportIssue(),
                ),
              ],
            ),
            
            // Account
            _buildSettingsSection(
              'Account',
              [
                _buildListTile(
                  'Change Password',
                  'Update your password',
                  Icons.lock,
                  () => _navigateToChangePassword(),
                ),
                _buildListTile(
                  'Delete Account',
                  'Permanently delete account',
                  Icons.delete_forever,
                  () => _showDeleteAccountDialog(),
                  isDestructive: true,
                ),
              ],
            ),
            
            // App Info
            _buildSettingsSection(
              'App Information',
              [
                _buildListTile(
                  'Version',
                  '1.0.0',
                  Icons.info,
                  () {},
                  isInfo: true,
                ),
                _buildListTile(
                  'Build Number',
                  '2024.01.15',
                  Icons.build,
                  () {},
                  isInfo: true,
                ),
                _buildListTile(
                  'About Classy Driver',
                  'Learn more about the app',
                  Icons.info_outline,
                  () => _navigateToAbout(),
                ),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // Logout Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              height: screenHeight * 0.07,
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Color(0xFFE91E63),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: screenWidth * 0.08,
            ),
          ),
          
          SizedBox(width: screenWidth * 0.04),
          
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Driver',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Professional Driver',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Member since January 2024',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Edit Button
          IconButton(
            onPressed: () => _navigateToEditProfile(),
            icon: Icon(
              Icons.edit,
              color: Color(0xFFE91E63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFE91E63).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Color(0xFFE91E63), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFFE91E63),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String value,
    IconData icon,
    double sliderValue,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFE91E63).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Color(0xFFE91E63), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Color(0xFFE91E63),
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: sliderValue,
            min: min,
            max: max,
            divisions: ((max - min) / 0.5).round(),
            onChanged: onChanged,
            activeColor: Color(0xFFE91E63),
            inactiveColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool isInfo = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : Color(0xFFE91E63).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : Color(0xFFE91E63),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive ? Colors.red.withValues(alpha: 0.7) : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: isInfo
          ? null
          : Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
      onTap: isInfo ? null : onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'English',
            'Kinyarwanda',
            'French',
            'Swahili',
          ].map((language) => RadioListTile<String>(
            title: Text(language),
            value: language,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE91E63),
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deletion requested'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToEditProfile() {
    Navigator.of(context).pushNamed('/edit-profile');
  }

  void _navigateToPrivacyPolicy() {
    Navigator.of(context).pushNamed('/privacy-policy');
  }

  void _navigateToTermsOfService() {
    Navigator.of(context).pushNamed('/terms-of-service');
  }

  void _navigateToDataUsage() {
    // TODO: Navigate to data usage page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data usage page coming soon')),
    );
  }

  void _navigateToHelpCenter() {
    Navigator.of(context).pushNamed('/help-center');
  }

  void _navigateToContactSupport() {
    Navigator.of(context).pushNamed('/support');
  }

  void _navigateToReportIssue() {
    Navigator.of(context).pushNamed('/complaints');
  }

  void _navigateToChangePassword() {
    Navigator.of(context).pushNamed('/change-password');
  }

  void _navigateToAbout() {
    Navigator.of(context).pushNamed('/about-us');
  }
}
