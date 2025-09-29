import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/services/transport_api.service.dart';
import 'package:Classy/services/location.service.dart';
import 'package:location/location.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class DriverSearchPage extends StatefulWidget {
  final String pickup;
  final String destination;
  final String serviceType; // 'taxi' or 'boda'
  final int? vehicleTypeId;

  const DriverSearchPage({
    Key? key,
    required this.pickup,
    required this.destination,
    required this.serviceType,
    this.vehicleTypeId,
  }) : super(key: key);

  @override
  _DriverSearchPageState createState() => _DriverSearchPageState();
}

class _DriverSearchPageState extends State<DriverSearchPage>
    with TickerProviderStateMixin {
  final TransportApiService _transportApiService = TransportApiService();
  final LocationService _locationService = LocationService();
  
  late AnimationController _searchController;
  late Animation<double> _searchAnimation;
  
  bool _isSearching = false;
  bool _searchCompleted = false;
  Map<String, dynamic>? _searchResults;
  String _currentSearchRadius = '';
  List<Map<String, dynamic>> _drivers = [];
  
  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.easeInOut),
    );
    
    _startDriverSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startDriverSearch() async {
    setState(() {
      _isSearching = true;
      _searchCompleted = false;
    });
    
    _searchController.repeat();
    
    try {
      // Get current location
      final locationData = await LocationService.location.getLocation();
      final latitude = locationData.latitude ?? 0.3476; // Kampala default
      final longitude = locationData.longitude ?? 32.5825;
      
      // Search for nearest driver
      final response = await _transportApiService.findNearestDriver(
        latitude: latitude,
        longitude: longitude,
        vehicleTypeId: widget.vehicleTypeId,
      );
      
      _searchController.stop();
      
      setState(() {
        _isSearching = false;
        _searchCompleted = true;
        _searchResults = response.body;
        _currentSearchRadius = response.body?['search_radius']?.toString() ?? '0';
        _drivers = List<Map<String, dynamic>>.from(
          response.body?['data']?['drivers'] ?? []
        );
      });
      
      if (response.allGood && _drivers.isNotEmpty) {
        _showDriverFoundDialog();
      } else {
        _showNoDriverDialog();
      }
      
    } catch (e) {
      _searchController.stop();
      setState(() {
        _isSearching = false;
        _searchCompleted = true;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showDriverFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            "Driver Found!".text.bold.xl.make(),
          ],
        ),
        content: VStack([
          "Found ${_drivers.length} driver(s) within ${_currentSearchRadius}km".text.make(),
          SizedBox(height: 16),
          "Nearest driver: ${_drivers.first['name'] ?? 'Unknown'}".text.bold.make(),
          SizedBox(height: 8),
          "Rating: ${_drivers.first['rating'] ?? 'N/A'} ⭐".text.make(),
          SizedBox(height: 8),
          "Estimated arrival: ${_drivers.first['eta'] ?? '5-10 minutes'}".text.make(),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: "Cancel".text.color(Colors.grey).make(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedToBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: "Book Now".text.bold.make(),
          ),
        ],
      ),
    );
  }

  void _showNoDriverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            "No Drivers Available".text.bold.xl.make(),
          ],
        ),
        content: VStack([
          "No drivers found within 5km radius".text.make(),
          SizedBox(height: 16),
          "Try again in a few minutes or expand your search area".text.gray600.make(),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: "Cancel".text.color(Colors.grey).make(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startDriverSearch(); // Retry search
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: "Try Again".text.bold.make(),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: "Search Error".text.bold.xl.make(),
        content: "Failed to search for drivers: $error".text.make(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: "OK".text.color(AppColor.primaryColor).make(),
          ),
        ],
      ),
    );
  }

  void _proceedToBooking() {
    // Navigate to booking confirmation or driver connection page
    Navigator.of(context).pushReplacementNamed('/driver-connection', arguments: {
      'pickup': widget.pickup,
      'destination': widget.destination,
      'serviceType': widget.serviceType,
      'driver': _drivers.first,
      'searchRadius': _currentSearchRadius,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: "Finding Driver".text.bold.make(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Search Animation
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSearching) ...[
                        AnimatedBuilder(
                          animation: _searchAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.primaryColor.withOpacity(
                                  0.3 * (1 - _searchAnimation.value),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  widget.serviceType == 'boda' 
                                      ? Icons.motorcycle 
                                      : Icons.local_taxi,
                                  size: 40,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        "Searching for drivers...".text.xl.make(),
                        SizedBox(height: 10),
                        "Checking within 100m, 500m, 1km, 2km, 3km, 5km".text.gray600.make(),
                      ] else if (_searchCompleted) ...[
                        Icon(
                          _drivers.isNotEmpty ? Icons.check_circle : Icons.location_off,
                          size: 80,
                          color: _drivers.isNotEmpty ? Colors.green : Colors.orange,
                        ),
                        SizedBox(height: 20),
                        if (_drivers.isNotEmpty) ...[
                          "Driver Found!".text.xl2.bold.green600.make(),
                          SizedBox(height: 10),
                          "Within ${_currentSearchRadius}km".text.gray600.make(),
                        ] else ...[
                          "No Drivers Available".text.xl2.bold.orange600.make(),
                          SizedBox(height: 10),
                          "Within 5km radius".text.gray600.make(),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              
              // Search Details
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: VStack([
                    "Trip Details".text.bold.xl.make(),
                    SizedBox(height: 16),
                    HStack([
                      Icon(Icons.location_on, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: widget.pickup.text.make()),
                    ]),
                    SizedBox(height: 8),
                    HStack([
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: widget.destination.text.make()),
                    ]),
                    SizedBox(height: 8),
                    HStack([
                      Icon(
                        widget.serviceType == 'boda' 
                            ? Icons.motorcycle 
                            : Icons.local_taxi,
                        color: AppColor.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      "${widget.serviceType.toUpperCase()} Service".text.make(),
                    ]),
                    if (_searchCompleted && _drivers.isNotEmpty) ...[
                      SizedBox(height: 16),
                      HStack([
                        Icon(Icons.person, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        "Driver: ${_drivers.first['name'] ?? 'Unknown'}".text.make(),
                      ]),
                      SizedBox(height: 8),
                      HStack([
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        "Rating: ${_drivers.first['rating'] ?? 'N/A'}".text.make(),
                      ]),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
