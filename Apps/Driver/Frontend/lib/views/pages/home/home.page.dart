import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDriverActive = true;

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
          'Classy Provider',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045, // 4.5% of screen width
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE91E63),
        elevation: 0,
        actions: [
          // Driver Status Toggle
          Container(
            margin: EdgeInsets.only(right: screenWidth * 0.04), // 4% of screen width
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDriverActive ? 'Active' : 'Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.03, // 3% of screen width
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02), // 2% of screen width
                Switch(
                  value: _isDriverActive,
                  onChanged: (value) {
                    setState(() {
                      _isDriverActive = value;
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey[400],
                ),
              ],
            ),
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
                  
                  // Driver Status Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.05), // 5% of screen width
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isDriverActive 
                          ? [Color(0xFFE91E63), Color(0xFF9C27B0)]
                          : [Colors.grey[400]!, Colors.grey[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isDriverActive ? Icons.check_circle : Icons.pause_circle,
                              color: Colors.white,
                              size: screenWidth * 0.06, // 6% of screen width
                            ),
                            SizedBox(width: screenWidth * 0.03), // 3% of screen width
                            Text(
                              _isDriverActive ? 'You are Online' : 'You are Offline',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.045, // 4.5% of screen width
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
                        Text(
                          _isDriverActive 
                            ? 'Ready to accept ride requests and earn money!'
                            : 'Go online to start receiving ride requests',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: screenWidth * 0.035, // 3.5% of screen width
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // New Ride Request Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Ride Request',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isDriverActive ? () {
                                  // TODO: Accept ride logic
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ride accepted!')),
                                  );
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('Accept'),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isDriverActive ? () {
                                  // TODO: Reject ride logic
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ride rejected')),
                                  );
                                } : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Service History Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Trips',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/service-history');
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Track your earnings and trip history',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/service-history');
                          },
                          icon: Icon(Icons.history),
                          label: Text('View Service History'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE91E63),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
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
}
