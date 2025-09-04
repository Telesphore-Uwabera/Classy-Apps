import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    // Responsive mobile design - adapts to actual screen size
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045, // 4.5% of screen width
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          child: Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  
                  // Profile Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.05), // 5% of screen width
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
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: screenWidth * 0.2, // 20% of screen width
                          height: screenWidth * 0.2,
                          decoration: BoxDecoration(
                            color: Color(0xFFE91E63).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: screenWidth * 0.1, // 10% of screen width
                            color: Color(0xFFE91E63),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.02), // 2% of screen height
                        
                        Text(
                          'Jane Provider',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06, // 6% of screen width
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.01), // 1% of screen height
                        
                        Text(
                          '+256 700 000000',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // 4% of screen width
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // 5% of screen width
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  
                  _buildQuickActionCard(
                    'Emergency SOS',
                    Icons.emergency,
                    Colors.red,
                    () {
                      Navigator.of(context).pushNamed('/emergency-sos');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  SizedBox(width: screenWidth * 0.02), // 2% of screen width
                  
                  // Notifications
                  _buildQuickActionCard(
                    'Notifications',
                    Icons.notifications,
                    Colors.blue,
                    () {
                      Navigator.of(context).pushNamed('/notifications');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Complaints
                  _buildQuickActionCard(
                    'Complaints',
                    Icons.report_problem,
                    Colors.orange,
                    () {
                      Navigator.of(context).pushNamed('/complaints');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  _buildQuickActionCard(
                    'About Us',
                    Icons.info,
                    Colors.teal,
                    () {
                      Navigator.of(context).pushNamed('/about-us');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Account Management
                  Text(
                    'Account Management',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // 5% of screen width
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  
                  _buildQuickActionCard(
                    'Edit Profile',
                    Icons.edit,
                    Color(0xFFE91E63),
                    () {
                      Navigator.of(context).pushNamed('/edit-profile');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // My Vehicles Section
                  _buildQuickActionCard(
                    'My Vehicles',
                    Icons.directions_car,
                    Colors.green,
                    () {
                      Navigator.of(context).pushNamed('/my-vehicles');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  // Documents Section
                  _buildQuickActionCard(
                    'Documents',
                    Icons.description,
                    Colors.blue,
                    () {
                      Navigator.of(context).pushNamed('/my-documents');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Settings Section
                  _buildQuickActionCard(
                    'Settings',
                    Icons.settings,
                    Colors.grey,
                    () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Service History Section
                  _buildQuickActionCard(
                    'Service History',
                    Icons.history,
                    Colors.orange,
                    () {
                      Navigator.of(context).pushNamed('/service-history');
                    },
                    screenWidth,
                    screenHeight,
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.06, // 6% of screen height
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: screenWidth * 0.05, // 5% of screen width
                      ),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: screenWidth * 0.04, // 4% of screen width
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.05), // 5% of screen height
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFE91E63),
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 3, // Profile is active
        onTap: (index) {
          // Handle navigation between main sections
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              Navigator.of(context).pushNamed('/bookings');
              break;
            case 2:
              Navigator.of(context).pushNamed('/wallet');
              break;
            case 3:
              // Already on Profile
              break;
          }
        },
      ),
    );
  }
  
  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015), // 1.5% of screen height
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.025), // 2.5% of screen width
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: screenWidth * 0.05, // 5% of screen width
                  ),
                ),
                
                SizedBox(width: screenWidth * 0.04), // 4% of screen width
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // 4% of screen width
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: screenWidth * 0.04, // 4% of screen width
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
              size: screenWidth * 0.05, // 5% of screen width
            ),
            SizedBox(width: screenWidth * 0.02), // 2% of screen width
            Text('Logout'),
          ],
        ),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to login
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
