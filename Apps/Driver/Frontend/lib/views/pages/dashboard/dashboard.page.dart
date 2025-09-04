import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';
import '../../../services/auth.service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
          'Classy Driver Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045, // 4.5% of screen width
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE91E63),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
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
                  
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.05), // 5% of screen width
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${AuthServices.currentUser?.name ?? 'Driver'}! 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.06, // 6% of screen width
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01), // 1% of screen height
                        Text(
                          'Ready to connect with new opportunities?',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: screenWidth * 0.04, // 4% of screen width
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Quick Actions Grid
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // 5% of screen width
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: screenWidth * 0.04, // 4% of screen width
                    mainAxisSpacing: screenHeight * 0.02, // 2% of screen height
                    childAspectRatio: 1.2,
                    children: [
                      _buildQuickActionCard(
                        'Ride Requests',
                        Icons.directions_car,
                        Colors.blue,
                        () {
                          Navigator.of(context).pushNamed('/ride-requests');
                        },
                        screenWidth,
                        screenHeight,
                      ),
                      
                      _buildQuickActionCard(
                        'My Bookings',
                        Icons.list_alt,
                        Colors.green,
                        () {
                          Navigator.of(context).pushReplacementNamed('/bookings');
                        },
                        screenWidth,
                        screenHeight,
                      ),
                      
                      _buildQuickActionCard(
                        'Wallet',
                        Icons.account_balance_wallet,
                        Colors.orange,
                        () {
                          Navigator.of(context).pushReplacementNamed('/wallet');
                        },
                        screenWidth,
                        screenHeight,
                      ),
                      
                      _buildQuickActionCard(
                        'Statistics',
                        Icons.bar_chart,
                        Colors.purple,
                        () {
                          // TODO: Navigate to statistics
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Statistics coming soon!')),
                          );
                        },
                        screenWidth,
                        screenHeight,
                      ),
                      
                      _buildQuickActionCard(
                        'Service History',
                        Icons.history,
                        Colors.indigo,
                        () {
                          Navigator.of(context).pushNamed('/service-history');
                        },
                        screenWidth,
                        screenHeight,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // 5% of screen width
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  
                  _buildActivityItem(
                    'Trip completed',
                    'Kigali to Musanze',
                    '2 hours ago',
                    Icons.check_circle,
                    Colors.green,
                    screenWidth,
                    screenHeight,
                  ),
                  
                  _buildActivityItem(
                    'New booking received',
                    'Food delivery - Kigali',
                    '1 hour ago',
                    Icons.notifications,
                    Colors.blue,
                    screenWidth,
                    screenHeight,
                  ),
                  
                  _buildActivityItem(
                    'Payment received',
                    'RWF 5,000',
                    '30 minutes ago',
                    Icons.payment,
                    Colors.green,
                    screenWidth,
                    screenHeight,
                  ),
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
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation between main sections
          switch (index) {
            case 0:
              // Already on Home
              break;
            case 1:
              Navigator.of(context).pushNamed('/bookings');
              break;
            case 2:
              Navigator.of(context).pushNamed('/wallet');
              break;
            case 3:
              Navigator.of(context).pushNamed('/profile');
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03), // 3% of screen width
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: screenWidth * 0.06, // 6% of screen width
                ),
              ),
              SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
              Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.035, // 3.5% of screen width
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015), // 1.5% of screen height
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                    fontSize: screenWidth * 0.035, // 3.5% of screen width
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.003), // 0.3% of screen height
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03, // 3% of screen width
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: screenWidth * 0.025, // 2.5% of screen width
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
