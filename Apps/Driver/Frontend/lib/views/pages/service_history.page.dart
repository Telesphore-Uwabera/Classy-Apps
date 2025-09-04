import 'package:flutter/material.dart';

class ServiceHistoryPage extends StatefulWidget {
  const ServiceHistoryPage({Key? key}) : super(key: key);

  @override
  State<ServiceHistoryPage> createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends State<ServiceHistoryPage> {
  final List<Map<String, dynamic>> _serviceHistory = [
    {
      'id': '1',
      'date': '2024-01-15',
      'time': '14:30',
      'pickup': 'Kigali International Airport',
      'destination': 'Kigali City Center',
      'distance': '12.5 km',
      'duration': '25 min',
      'earnings': 2500,
      'status': 'completed',
      'customerName': 'John Doe',
      'vehiclePlate': 'RAB 123A',
    },
    {
      'id': '2',
      'date': '2024-01-14',
      'time': '09:15',
      'pickup': 'Kigali Convention Center',
      'destination': 'Kigali Heights',
      'distance': '8.2 km',
      'duration': '18 min',
      'earnings': 1800,
      'status': 'completed',
      'customerName': 'Sarah Wilson',
      'vehiclePlate': 'RAB 123A',
    },
    {
      'id': '3',
      'date': '2024-01-13',
      'time': '16:45',
      'pickup': 'Kigali Mall',
      'destination': 'Remera',
      'distance': '6.8 km',
      'duration': '15 min',
      'earnings': 1500,
      'status': 'completed',
      'customerName': 'Mike Johnson',
      'vehiclePlate': 'RAB 123A',
    },
    {
      'id': '4',
      'date': '2024-01-12',
      'time': '11:20',
      'pickup': 'Kigali Heights',
      'destination': 'Kigali International Airport',
      'distance': '12.5 km',
      'duration': '28 min',
      'earnings': 2500,
      'status': 'completed',
      'customerName': 'Emma Davis',
      'vehiclePlate': 'RAB 123A',
    },
    {
      'id': '5',
      'date': '2024-01-11',
      'time': '13:10',
      'pickup': 'Remera',
      'destination': 'Kigali Convention Center',
      'distance': '8.2 km',
      'duration': '20 min',
      'earnings': 1800,
      'status': 'completed',
      'customerName': 'David Brown',
      'vehiclePlate': 'RAB 123A',
    },
  ];

  String _selectedFilter = 'all';
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Service History',
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
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Color(0xFFE91E63),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Period Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPeriodChip('Week', 'week'),
                    _buildPeriodChip('Month', 'month'),
                    _buildPeriodChip('Year', 'year'),
                  ],
                ),
                
                SizedBox(height: screenHeight * 0.03),
                
                // Summary Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryCard(
                      'Total Trips',
                      '${_serviceHistory.length}',
                      Icons.directions_car,
                      Colors.blue,
                    ),
                    _buildSummaryCard(
                      'Total Earnings',
                      'RWF ${_calculateTotalEarnings()}',
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                    _buildSummaryCard(
                      'Avg. Rating',
                      '4.8',
                      Icons.star,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Service History List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: _serviceHistory.length,
              itemBuilder: (context, index) {
                final service = _serviceHistory[index];
                return _buildServiceHistoryCard(service, screenWidth, screenHeight);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFFE91E63) : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHistoryCard(Map<String, dynamic> service, double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
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
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and earnings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(service['date']),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      service['time'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'RWF ${service['earnings']}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Trip details
            Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFFE91E63), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    service['pickup'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.01),
            
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    service['destination'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Trip stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTripStat('Distance', service['distance']),
                _buildTripStat('Duration', service['duration']),
                _buildTripStat('Customer', service['customerName']),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewServiceDetails(service),
                    icon: Icon(Icons.visibility, size: 18),
                    label: Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFFE91E63),
                      side: BorderSide(color: Color(0xFFE91E63)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _repeatService(service),
                    icon: Icon(Icons.replay, size: 18),
                    label: Text('Repeat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  int _calculateTotalEarnings() {
    return _serviceHistory.fold(0, (sum, service) => sum + (service['earnings'] as int));
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Services'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('All Services'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text('Completed'),
              value: 'completed',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text('Cancelled'),
              value: 'cancelled',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewServiceDetails(Map<String, dynamic> service) {
    // TODO: Navigate to service details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for service ${service['id']}'),
        backgroundColor: Color(0xFFE91E63),
      ),
    );
  }

  void _repeatService(Map<String, dynamic> service) {
    // TODO: Navigate to booking page with pre-filled details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Repeating service to ${service['destination']}'),
        backgroundColor: Color(0xFFE91E63),
      ),
    );
  }
}
