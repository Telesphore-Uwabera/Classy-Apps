import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class EmergencySosPage extends StatefulWidget {
  const EmergencySosPage({Key? key}) : super(key: key);

  @override
  State<EmergencySosPage> createState() => _EmergencySosPageState();
}

class _EmergencySosPageState extends State<EmergencySosPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: Text(
          'Emergency SOS',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              
              // Emergency Button
              Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    _showEmergencyDialog(context);
                  },
                  icon: Icon(
                    Icons.emergency,
                    size: screenWidth * 0.3,
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              Text(
                'Press for Emergency',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              Text(
                'This will immediately contact emergency services and send your location',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.05),
              
              // Emergency Contacts
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.05),
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
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    _buildContactItem(
                      'Police',
                      '+256 112',
                      Icons.local_police,
                      Colors.blue,
                      screenWidth,
                      screenHeight,
                    ),
                    
                    _buildContactItem(
                      'Ambulance',
                      '+256 112',
                      Icons.medical_services,
                      Colors.red,
                      screenWidth,
                      screenHeight,
                    ),
                    
                    _buildContactItem(
                      'Fire Department',
                      '+256 112',
                      Icons.fire_truck,
                      Colors.orange,
                      screenWidth,
                      screenHeight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContactItem(
    String title,
    String number,
    IconData icon,
    Color color,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: screenWidth * 0.05,
            ),
          ),
          
          SizedBox(width: screenWidth * 0.04),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: () {
              // TODO: Handle call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $title...')),
              );
            },
            icon: Icon(
              Icons.call,
              color: Colors.green,
              size: screenWidth * 0.05,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 10),
            Text('Emergency SOS'),
          ],
        ),
        content: Text('Are you sure you want to trigger an emergency alert? This will contact emergency services immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Emergency alert sent! Help is on the way.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Send SOS'),
          ),
        ],
      ),
    );
  }
}
