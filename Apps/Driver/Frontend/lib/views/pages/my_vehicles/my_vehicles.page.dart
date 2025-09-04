import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/language.service.dart';

class MyVehiclesPage extends StatefulWidget {
  const MyVehiclesPage({Key? key}) : super(key: key);

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Vehicles',
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
              // TODO: Navigate to add vehicle
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Add vehicle coming soon!')),
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
              
              // Vehicle Card
              _buildVehicleCard(
                'Toyota Premio',
                'UBA 123X',
                'White',
                '2020',
                'Verified',
                Icons.directions_car,
                Colors.green,
                screenWidth,
                screenHeight,
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              // Add Vehicle Button
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
                      Icons.add_circle_outline,
                      size: screenWidth * 0.1,
                      color: Color(0xFFE91E63),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    Text(
                      'Add New Vehicle',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.01),
                    
                    Text(
                      'Register a new vehicle to expand your service offerings',
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
  
  Widget _buildVehicleCard(
    String model,
    String plateNumber,
    String color,
    String year,
    String status,
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
                  color: Color(0xFFE91E63).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Color(0xFFE91E63),
                  size: screenWidth * 0.05,
                ),
              ),
              
              SizedBox(width: screenWidth * 0.04),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    Text(
                      plateNumber,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
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
              _buildVehicleDetail('Color', color, screenWidth, screenHeight),
              _buildVehicleDetail('Year', year, screenWidth, screenHeight),
            ],
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Edit vehicle
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit vehicle coming soon!')),
                    );
                  },
                  icon: Icon(Icons.edit, size: screenWidth * 0.04),
                  label: Text('Edit'),
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
                    // TODO: View details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vehicle details coming soon!')),
                    );
                  },
                  icon: Icon(Icons.visibility, size: screenWidth * 0.04),
                  label: Text('View Details'),
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
  
  Widget _buildVehicleDetail(
    String label,
    String value,
    double screenWidth,
    double screenHeight,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: screenHeight * 0.005),
          
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
