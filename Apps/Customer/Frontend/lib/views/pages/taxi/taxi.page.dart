import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/services/location.service.dart';
import 'driver_connection.page.dart';
import 'driver_search.page.dart';

class TaxiPage extends StatefulWidget {
  const TaxiPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;

  @override
  _TaxiPageState createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            // Background color (light blue)
            Container(
              color: Colors.lightBlue.shade50,
            ),
            
            // Main content
            Column(
              children: [
                // Location Input Card
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Back button and route line
                      Row(
                        children: [
                          // Back button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          
                          SizedBox(width: 16),
                          
                          // Route line with dotted pattern
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 2,
                                  height: 20,
                                  child: CustomPaint(
                                    painter: DottedLinePainter(),
                                  ),
                                ),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(width: 16),
                          
                          // Target icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.my_location, color: Colors.white, size: 20),
                              onPressed: () {
                                // TODO: Get current location
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Input fields
                      Column(
                        children: [
                          // From field
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Current Location",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // To field
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showLocationSearch(context),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        "Where to?",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Spacer(),
                
                // Google logo at bottom left
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(left: 20, bottom: 20),
                  child: Text(
                    "Google",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Current location circle and NOW button
                Positioned(
                  bottom: 80,
                  left: 20,
                  child: Row(
                    children: [
                      // Current location circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // NOW button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            // Button
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Text(
                                "NOW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            // Triangle pointer
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: CustomPaint(
                                size: Size(20, 20),
                                painter: TrianglePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLocationSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header with back button and search bar
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Search for a location",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (query) {
                            // TODO: Implement real location search API
                            // For now, show filtered results based on query
                            _filterLocations(query);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Results Section
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Search Results",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Expanded(
                        child: _buildSearchResults(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    // Use location service for search results
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: LocationService.searchLocations(''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error loading locations'));
        }
        
        final searchResults = snapshot.data ?? [];

        return ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final location = searchResults[index];
            return _buildSearchResultItem(
              icon: location['icon'] as IconData,
              title: location['title'] as String,
              subtitle: location['subtitle'] as String,
              type: location['type'] as String,
              onTap: () => _selectDestination(context, location['title'] as String),
            );
          },
        );
       },
     );
   }

  Widget _buildSearchResultItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String type,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColor.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: AppColor.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterLocations(String query) {
    // TODO: Implement real location filtering with search results
    // This would call a location search API like Google Places, Mapbox, etc.
    print('Searching for: $query');
    // In the future, this would update the search results in real-time
  }
  
  Widget _buildRecentPlace({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColor.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _selectDestination(BuildContext context, String destination) {
    Navigator.pop(context);
    _showBodaTypeSelection(context, destination);
  }
  
  void _showBodaTypeSelection(BuildContext context, String destination) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Draggable handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Title
              Text(
                "Select Boda Type",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              
              SizedBox(height: 24),
              
              // Boda options
              _buildBodaOption(
                icon: Icons.electric_bike,
                title: "Electric",
                capacity: "1",
                priceRange: "UGX 4,500 - 6,750",
                onTap: () => _selectBodaType(context, "Electric", destination),
              ),
              
              SizedBox(height: 16),
              
              _buildBodaOption(
                icon: Icons.motorcycle,
                title: "Standard",
                capacity: "1",
                priceRange: "UGX 6,500 - 9,750",
                onTap: () => _selectBodaType(context, "Standard", destination),
              ),
              
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildBodaOption({
    required IconData icon,
    required String title,
    required String capacity,
    required String priceRange,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColor.primaryColor,
                size: 24,
              ),
            ),
            
            SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 4),
                      Text(
                        capacity,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceRange,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Price range",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _selectBodaType(BuildContext context, String bodaType, String destination) {
    Navigator.pop(context);
    _showPaymentMethodSelection(context, bodaType, destination);
  }
  
  void _showPaymentMethodSelection(BuildContext context, String bodaType, String destination) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Draggable handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Header
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    "Select Payment Method",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Payment options
              _buildPaymentOption(
                icon: Icons.money,
                title: "Cash",
                onTap: () => _selectPaymentMethod(context, "Cash", bodaType, destination),
              ),
              
              SizedBox(height: 16),
              
              _buildPaymentOption(
                icon: Icons.credit_card,
                title: "Cashless",
                onTap: () => _selectPaymentMethod(context, "Cashless", bodaType, destination),
              ),
              
              SizedBox(height: 24),
              
              // Order Now button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _placeOrder(context, bodaType, destination),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.grey.shade600,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Order Now",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColor.primaryColor,
                size: 24,
              ),
            ),
            
            SizedBox(width: 16),
            
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  void _selectPaymentMethod(BuildContext context, String paymentMethod, String bodaType, String destination) {
    Navigator.pop(context);
    _placeOrder(context, bodaType, destination);
  }
  
  void _placeOrder(BuildContext context, String bodaType, String destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DriverSearchPage(
          pickup: "Current Location",
          destination: destination,
          serviceType: bodaType.toLowerCase(),
          vehicleTypeId: bodaType.toLowerCase() == 'boda' ? 2 : 1, // 1 for taxi, 2 for boda
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 3;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
