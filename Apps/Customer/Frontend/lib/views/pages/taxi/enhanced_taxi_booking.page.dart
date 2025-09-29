import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/widgets/enhanced_google_map.widget.dart';
import 'package:Classy/widgets/enhanced_location_search.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/models/vehicle_type.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class EnhancedTaxiBookingPage extends StatefulWidget {
  const EnhancedTaxiBookingPage({Key? key}) : super(key: key);

  @override
  State<EnhancedTaxiBookingPage> createState() => _EnhancedTaxiBookingPageState();
}

class _EnhancedTaxiBookingPageState extends State<EnhancedTaxiBookingPage> {
  final GlobalKey<EnhancedGoogleMapWidgetState> _mapKey = GlobalKey();
  
  DeliveryAddress? _pickupLocation;
  DeliveryAddress? _destinationLocation;
  VehicleType? _selectedVehicleType;
  bool _isBooking = false;
  String _estimatedFare = '';
  String _estimatedTime = '';
  double _estimatedDistance = 0;

  // Mock vehicle types
  final List<VehicleType> _vehicleTypes = [
    VehicleType(
      id: '1',
      name: 'Standard',
      description: 'Comfortable ride for everyday travel',
      icon: '🚗',
      baseFare: 5.0,
      perKmRate: 2.0,
      estimatedTime: '5-10 min',
    ),
    VehicleType(
      id: '2',
      name: 'Premium',
      description: 'Luxury vehicle with premium features',
      icon: '🚙',
      baseFare: 8.0,
      perKmRate: 3.0,
      estimatedTime: '5-10 min',
    ),
    VehicleType(
      id: '3',
      name: 'Motorcycle',
      description: 'Quick and affordable motorcycle ride',
      icon: '🏍️',
      baseFare: 3.0,
      perKmRate: 1.5,
      estimatedTime: '3-7 min',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ride'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Location Selection Panel
          _buildLocationPanel(),
          
          // Enhanced Google Map
          Expanded(
            child: EnhancedGoogleMapWidget(
              key: _mapKey,
              initialPosition: const LatLng(0.3476, 32.5825), // Kampala coordinates
              showSearchBar: true,
              showNavigationControls: true,
              enableNavigation: _pickupLocation != null && _destinationLocation != null,
              pickupLocation: _pickupLocation,
              destinationLocation: _destinationLocation,
              onLocationSelected: _onLocationSelected,
              onRouteSet: _onRouteSet,
              onNavigationUpdate: _onNavigationUpdate,
            ),
          ),
          
          // Vehicle Selection and Booking Panel
          if (_pickupLocation != null && _destinationLocation != null)
            _buildBookingPanel(),
        ],
      ),
    );
  }

  Widget _buildLocationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pickup Location
          EnhancedLocationSearch(
            label: 'Pickup Location',
            initialValue: _pickupLocation?.address,
            hintText: 'Where are you now?',
            onLocationSelected: (address, coordinates) {
              setState(() {
                _pickupLocation = DeliveryAddress(
                  address: address,
                  latitude: coordinates.latitude,
                  longitude: coordinates.longitude,
                );
              });
              _updateMapRoute();
            },
          ),
          
          // Destination Location
          EnhancedLocationSearch(
            label: 'Destination',
            initialValue: _destinationLocation?.address,
            hintText: 'Where do you want to go?',
            onLocationSelected: (address, coordinates) {
              setState(() {
                _destinationLocation = DeliveryAddress(
                  address: address,
                  latitude: coordinates.latitude,
                  longitude: coordinates.longitude,
                );
              });
              _updateMapRoute();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Route Summary
          _buildRouteSummary(),
          
          const SizedBox(height: 16),
          
          // Vehicle Selection
          _buildVehicleSelection(),
          
          const SizedBox(height: 16),
          
          // Book Button
          _buildBookButton(),
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.route, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_estimatedDistance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Estimated time: $_estimatedTime',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (_estimatedFare.isNotEmpty)
            Text(
              _estimatedFare,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Vehicle Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _vehicleTypes.length,
            itemBuilder: (context, index) {
              final vehicle = _vehicleTypes[index];
              final isSelected = _selectedVehicleType?.id == vehicle.id;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVehicleType = vehicle;
                  });
                  _calculateFare();
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColor.primaryColor : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vehicle.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.estimatedTime,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedVehicleType != null && !_isBooking
            ? _bookRide
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isBooking
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Booking...'),
                ],
              )
            : Text(
                _selectedVehicleType != null
                    ? 'Book ${_selectedVehicleType!.name}'
                    : 'Select Vehicle Type',
              ),
      ),
    );
  }

  void _onLocationSelected(DeliveryAddress location) {
    // Handle location selection
    setState(() {});
  }

  void _onRouteSet(LatLng pickup, LatLng destination) {
    // Handle route setting
    _calculateRouteStats();
  }

  void _onNavigationUpdate(String status) {
    // Handle navigation updates
    setState(() {});
  }

  void _updateMapRoute() {
    if (_pickupLocation != null && _destinationLocation != null) {
      _mapKey.currentState?.setRoute(
        pickup: LatLng(
          _pickupLocation!.latitude!,
          _pickupLocation!.longitude!,
        ),
        destination: LatLng(
          _destinationLocation!.latitude!,
          _destinationLocation!.longitude!,
        ),
        pickupAddress: _pickupLocation!.address,
        destinationAddress: _destinationLocation!.address,
      );
      _calculateRouteStats();
    }
  }

  void _calculateRouteStats() {
    if (_pickupLocation != null && _destinationLocation != null) {
      // Calculate distance (simplified calculation)
      final distance = _calculateDistance(
        _pickupLocation!.latitude!,
        _pickupLocation!.longitude!,
        _destinationLocation!.latitude!,
        _destinationLocation!.longitude!,
      );
      
      _estimatedDistance = distance;
      _estimatedTime = '${(distance * 2).round()} min'; // Rough estimate
      
      if (_selectedVehicleType != null) {
        _calculateFare();
      }
    }
  }

  void _calculateFare() {
    if (_selectedVehicleType != null && _estimatedDistance > 0) {
      final fare = _selectedVehicleType!.baseFare + 
                   (_selectedVehicleType!.perKmRate * _estimatedDistance);
      _estimatedFare = '\$${fare.toStringAsFixed(2)}';
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = (lat2 - lat1) * (3.14159265359 / 180);
    final double dLng = (lng2 - lng1) * (3.14159265359 / 180);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        (lat1 * (3.14159265359 / 180)).cos() * (lat2 * (3.14159265359 / 180)).cos() *
        (dLng / 2).sin() * (dLng / 2).sin();
    
    final double c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    
    return earthRadius * c;
  }

  void _bookRide() async {
    if (_selectedVehicleType == null) return;

    setState(() {
      _isBooking = true;
    });

    try {
      // Simulate booking process
      await Future.delayed(const Duration(seconds: 2));
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ride Booked!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('Your ${_selectedVehicleType!.name} is on the way!'),
              const SizedBox(height: 8),
              Text('Estimated arrival: $_estimatedTime'),
              const SizedBox(height: 8),
              Text('Fare: $_estimatedFare'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Failed'),
          content: Text('Failed to book ride: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }
}
