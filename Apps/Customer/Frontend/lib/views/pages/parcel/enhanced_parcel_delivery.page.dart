import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/widgets/enhanced_google_map.widget.dart';
import 'package:Classy/widgets/enhanced_location_search.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class EnhancedParcelDeliveryPage extends StatefulWidget {
  const EnhancedParcelDeliveryPage({Key? key}) : super(key: key);

  @override
  State<EnhancedParcelDeliveryPage> createState() => _EnhancedParcelDeliveryPageState();
}

class _EnhancedParcelDeliveryPageState extends State<EnhancedParcelDeliveryPage> {
  final GlobalKey<EnhancedGoogleMapWidgetState> _mapKey = GlobalKey();
  
  DeliveryAddress? _pickupLocation;
  DeliveryAddress? _destinationLocation;
  String _packageType = 'Document';
  String _packageWeight = 'Light';
  String _deliveryType = 'Standard';
  bool _isBooking = false;
  String _estimatedCost = '';
  String _estimatedTime = '';
  double _estimatedDistance = 0;

  final List<String> _packageTypes = ['Document', 'Package', 'Fragile', 'Electronics'];
  final List<String> _packageWeights = ['Light (< 1kg)', 'Medium (1-5kg)', 'Heavy (5-10kg)', 'Extra Heavy (> 10kg)'];
  final List<String> _deliveryTypes = ['Standard (1-2 days)', 'Express (Same day)', 'Overnight'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Package'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Package Details Panel
          _buildPackageDetailsPanel(),
          
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
          
          // Booking Panel
          if (_pickupLocation != null && _destinationLocation != null)
            _buildBookingPanel(),
        ],
      ),
    );
  }

  Widget _buildPackageDetailsPanel() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Package Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Package Type
          _buildDropdown(
            label: 'Package Type',
            value: _packageType,
            items: _packageTypes,
            onChanged: (value) {
              setState(() {
                _packageType = value!;
              });
              _calculateCost();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Package Weight
          _buildDropdown(
            label: 'Weight',
            value: _packageWeight,
            items: _packageWeights,
            onChanged: (value) {
              setState(() {
                _packageWeight = value!;
              });
              _calculateCost();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Delivery Type
          _buildDropdown(
            label: 'Delivery Type',
            value: _deliveryType,
            items: _deliveryTypes,
            onChanged: (value) {
              setState(() {
                _deliveryType = value!;
              });
              _calculateCost();
            },
          ),
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
            hintText: 'Where should we pick up the package?',
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
            label: 'Delivery Address',
            initialValue: _destinationLocation?.address,
            hintText: 'Where should we deliver the package?',
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
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
          // Delivery Summary
          _buildDeliverySummary(),
          
          const SizedBox(height: 16),
          
          // Book Button
          _buildBookButton(),
        ],
      ),
    );
  }

  Widget _buildDeliverySummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, color: Colors.blue),
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
                      'Estimated delivery: $_estimatedTime',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (_estimatedCost.isNotEmpty)
                Text(
                  _estimatedCost,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Package: $_packageType',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Weight: $_packageWeight',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Delivery: $_deliveryType',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !_isBooking ? _bookDelivery : null,
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
            : const Text('Book Delivery'),
      ),
    );
  }

  void _onLocationSelected(DeliveryAddress location) {
    setState(() {});
  }

  void _onRouteSet(LatLng pickup, LatLng destination) {
    _calculateRouteStats();
  }

  void _onNavigationUpdate(String status) {
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
      final distance = _calculateDistance(
        _pickupLocation!.latitude!,
        _pickupLocation!.longitude!,
        _destinationLocation!.latitude!,
        _destinationLocation!.longitude!,
      );
      
      _estimatedDistance = distance;
      
      // Calculate estimated time based on delivery type
      int hours = _deliveryType.contains('Same day') ? 2 : 
                  _deliveryType.contains('Overnight') ? 12 : 24;
      _estimatedTime = '${hours}h';
      
      _calculateCost();
    }
  }

  void _calculateCost() {
    if (_estimatedDistance > 0) {
      double baseCost = 5.0; // Base delivery cost
      
      // Add cost based on distance
      baseCost += _estimatedDistance * 1.5;
      
      // Add cost based on package type
      switch (_packageType) {
        case 'Fragile':
          baseCost += 5.0;
          break;
        case 'Electronics':
          baseCost += 3.0;
          break;
        case 'Package':
          baseCost += 2.0;
          break;
      }
      
      // Add cost based on weight
      if (_packageWeight.contains('Medium')) {
        baseCost += 2.0;
      } else if (_packageWeight.contains('Heavy')) {
        baseCost += 5.0;
      } else if (_packageWeight.contains('Extra Heavy')) {
        baseCost += 10.0;
      }
      
      // Add cost based on delivery type
      if (_deliveryType.contains('Express')) {
        baseCost *= 1.5;
      } else if (_deliveryType.contains('Overnight')) {
        baseCost *= 1.2;
      }
      
      _estimatedCost = '\$${baseCost.toStringAsFixed(2)}';
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371;
    
    final double dLat = (lat2 - lat1) * (3.14159265359 / 180);
    final double dLng = (lng2 - lng1) * (3.14159265359 / 180);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        (lat1 * (3.14159265359 / 180)).cos() * (lat2 * (3.14159265359 / 180)).cos() *
        (dLng / 2).sin() * (dLng / 2).sin();
    
    final double c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    
    return earthRadius * c;
  }

  void _bookDelivery() async {
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
          title: const Text('Delivery Booked!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text('Your package delivery has been scheduled!'),
              const SizedBox(height: 8),
              Text('Estimated delivery: $_estimatedTime'),
              const SizedBox(height: 8),
              Text('Cost: $_estimatedCost'),
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
          content: Text('Failed to book delivery: $e'),
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
