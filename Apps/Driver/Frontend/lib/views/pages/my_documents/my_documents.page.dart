import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class MyDocumentsPage extends StatefulWidget {
  const MyDocumentsPage({Key? key}) : super(key: key);

  @override
  State<MyDocumentsPage> createState() => _MyDocumentsPageState();
}

class _MyDocumentsPageState extends State<MyDocumentsPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Documents',
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
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // TODO: Upload document
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload document coming soon!')),
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
              
              // Document Cards
              _buildDocumentCard(
                'Driver\'s License',
                'Verified',
                'Expires: Dec 2025',
                Icons.drive_file_rename_outline,
                Colors.green,
                screenWidth,
                screenHeight,
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              _buildDocumentCard(
                'National ID',
                'Verified',
                'Expires: Mar 2026',
                Icons.credit_card,
                Colors.green,
                screenWidth,
                screenHeight,
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              _buildDocumentCard(
                'Vehicle Registration',
                'Pending',
                'Under Review',
                Icons.description,
                Colors.orange,
                screenWidth,
                screenHeight,
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              _buildDocumentCard(
                'Insurance Certificate',
                'Expired',
                'Expired: Jan 2025',
                Icons.security,
                Colors.red,
                screenWidth,
                screenHeight,
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Upload New Document
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFFE91E63),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: screenWidth * 0.1,
                      color: Color(0xFFE91E63),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    Text(
                      'Upload New Document',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.01),
                    
                    Text(
                      'Add new documents to expand your service capabilities',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
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
  
  Widget _buildDocumentCard(
    String title,
    String status,
    String expiry,
    IconData icon,
    Color statusColor,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: statusColor,
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
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    Text(
                      expiry,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: View document
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing document: $title')),
                    );
                  },
                  icon: Icon(Icons.visibility, size: screenWidth * 0.04),
                  label: Text('View'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFE91E63)),
                    foregroundColor: Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: screenWidth * 0.03),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Download document
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading document: $title')),
                    );
                  },
                  icon: Icon(Icons.download, size: screenWidth * 0.04),
                  label: Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
