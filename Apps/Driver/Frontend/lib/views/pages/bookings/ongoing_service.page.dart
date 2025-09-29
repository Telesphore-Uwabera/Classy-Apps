import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class OngoingServicePage extends StatefulWidget {
  const OngoingServicePage({Key? key}) : super(key: key);

  @override
  State<OngoingServicePage> createState() => _OngoingServicePageState();
}

class _OngoingServicePageState extends State<OngoingServicePage> {
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
          'Ongoing Service',
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
                  
                  // Map/Status Card
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.3, // 30% of screen height
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Map Placeholder
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: screenWidth * 0.15, // 15% of screen width
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: screenHeight * 0.01), // 1% of screen height
                              Text(
                                'Live Map View',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: screenWidth * 0.035, // 3.5% of screen width
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Status Badge
                        Positioned(
                          top: screenHeight * 0.02, // 2% of screen height
                          right: screenWidth * 0.04, // 4% of screen width
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04, // 4% of screen width
                              vertical: screenHeight * 0.01, // 1% of screen height
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'En Route to Pickup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03, // 3% of screen width
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Trip Details
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Details',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045, // 4.5% of screen width
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.02), // 2% of screen height
                        
                        // Passenger Name
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.025), // 2.5% of screen width
                              decoration: BoxDecoration(
                                color: Color(0xFFE91E63).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Color(0xFFE91E63),
                                size: screenWidth * 0.05, // 5% of screen width
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04), // 4% of screen width
                            Text(
                              'John Doe',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04, // 4% of screen width
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: screenHeight * 0.02), // 2% of screen height
                        
                        // Destination
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.025), // 2.5% of screen width
                              decoration: BoxDecoration(
                                color: Color(0xFFE91E63).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Color(0xFFE91E63),
                                size: screenWidth * 0.05, // 5% of screen width
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04), // 4% of screen width
                            Expanded(
                              child: Text(
                                'Destination: Garden City Mall',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04, // 4% of screen width
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: screenHeight * 0.02), // 2% of screen height
                        
                        // Vehicle Details
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.025), // 2.5% of screen width
                              decoration: BoxDecoration(
                                color: Color(0xFFE91E63).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: Color(0xFFE91E63),
                                size: screenWidth * 0.05, // 5% of screen width
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04), // 4% of screen width
                            Expanded(
                              child: Text(
                                'Toyota Premio, UBA 123X',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04, // 4% of screen width
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: screenHeight * 0.02), // 2% of screen height
                        
                        // ETA
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.025), // 2.5% of screen width
                              decoration: BoxDecoration(
                                color: Color(0xFFE91E63).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: Color(0xFFE91E63),
                                size: screenWidth * 0.05, // 5% of screen width
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04), // 4% of screen width
                            Text(
                              'ETA: 6 min',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04, // 4% of screen width
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: screenHeight * 0.06, // 6% of screen height
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Handle navigation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Opening navigation...')),
                              );
                            },
                            icon: Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: screenWidth * 0.05, // 5% of screen width
                            ),
                            label: Text(
                              'Navigate',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04, // 4% of screen width
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE91E63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: screenWidth * 0.03), // 3% of screen width
                      
                      Expanded(
                        child: Container(
                          height: screenHeight * 0.06, // 6% of screen height
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Handle contact
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calling passenger...')),
                              );
                            },
                            icon: Icon(
                              Icons.phone,
                              color: Colors.green,
                              size: screenWidth * 0.05, // 5% of screen width
                            ),
                            label: Text(
                              'Contact',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: screenWidth * 0.04, // 4% of screen width
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  
                  // End Trip Button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.065, // 6.5% of screen height
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Handle end trip
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('End Trip'),
                            content: Text('Are you sure you want to end this trip?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop(); // Go back to home
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Trip ended successfully!')),
                                  );
                                },
                                child: Text('End Trip'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'End Trip',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // 4.5% of screen width
                          fontWeight: FontWeight.w600,
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
        currentIndex: 1, // Bookings is active
        onTap: (index) {
          // Handle navigation between main sections
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              // Already on Bookings
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
