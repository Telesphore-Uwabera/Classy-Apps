import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Notifications',
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              
              // Notification List
              _buildNotificationItem(
                'New Ride Request',
                'You have a new ride request from John Doe',
                '2 min ago',
                Icons.directions_car,
                Colors.blue,
                true,
                screenWidth,
                screenHeight,
              ),
              
              _buildNotificationItem(
                'Payment Received',
                'UGX 12,000 has been added to your wallet',
                '1 hour ago',
                Icons.payment,
                Colors.green,
                false,
                screenWidth,
                screenHeight,
              ),
              
              _buildNotificationItem(
                'Document Verified',
                'Your driver\'s license has been verified',
                '2 hours ago',
                Icons.verified,
                Colors.orange,
                false,
                screenWidth,
                screenHeight,
              ),
              
              _buildNotificationItem(
                'App Update',
                'New version available with improved features',
                '1 day ago',
                Icons.system_update,
                Colors.purple,
                false,
                screenWidth,
                screenHeight,
              ),
              
              _buildNotificationItem(
                'Welcome to Classy Provider',
                'Thank you for joining our platform!',
                '2 days ago',
                Icons.waving_hand,
                Color(0xFFE91E63),
                false,
                screenWidth,
                screenHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotificationItem(
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
    bool isUnread,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Handle notification tap
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening notification: $title')),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                color: isUnread ? Colors.black87 : Colors.black87,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: screenWidth * 0.02,
                              height: screenWidth * 0.02,
                              decoration: BoxDecoration(
                                color: Color(0xFFE91E63),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: screenHeight * 0.005),
                      
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.005),
                      
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: screenWidth * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
