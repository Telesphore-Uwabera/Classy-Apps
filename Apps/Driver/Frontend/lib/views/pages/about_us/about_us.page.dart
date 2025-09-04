import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'About Us',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.03),
              
              // Logo
              Center(
                child: Container(
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              Text(
                'Classy Provider',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.01),
              
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.04),
              
              // About Content
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
                      'About Classy Provider',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    Text(
                      'Classy Provider is a leading multi-service delivery platform that connects skilled service providers with customers who need their expertise. Our mission is to make quality services accessible, reliable, and convenient for everyone.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    Text(
                      'What We Offer',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    _buildFeatureItem(
                      '🚗 Transportation Services',
                      'Professional drivers for safe and comfortable rides',
                      screenWidth,
                      screenHeight,
                    ),
                    
                    _buildFeatureItem(
                      '📦 Delivery Services',
                      'Fast and reliable delivery of goods and packages',
                      screenWidth,
                      screenHeight,
                    ),
                    
                    _buildFeatureItem(
                      '🔧 Technical Support',
                      'Expert technicians for various technical needs',
                      screenWidth,
                      screenHeight,
                    ),
                    
                    _buildFeatureItem(
                      '🏠 Home Services',
                      'Professional home maintenance and repair services',
                      screenWidth,
                      screenHeight,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Contact Info
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
                      'Contact Information',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    _buildContactItem(
                      'Email',
                      'support@classyprovider.com',
                      Icons.email,
                      screenWidth,
                      screenHeight,
                    ),
                    
                    _buildContactItem(
                      'Phone',
                      '+256 700 000000',
                      Icons.phone,
                      screenWidth,
                      screenHeight,
                    ),
                    
                    _buildContactItem(
                      'Website',
                      'www.classyprovider.com',
                      Icons.language,
                      screenWidth,
                      screenHeight,
                    ),
                    
                    _buildContactItem(
                      'Address',
                      'Kampala, Uganda',
                      Icons.location_on,
                      screenWidth,
                      screenHeight,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(
    String title,
    String description,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(width: screenWidth * 0.02),
          
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(
    String title,
    String value,
    IconData icon,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFFE91E63),
            size: screenWidth * 0.04,
          ),
          
          SizedBox(width: screenWidth * 0.03),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
