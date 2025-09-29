import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/widgets/enhanced_google_map.widget.dart';
import 'package:Classy/services/enhanced_navigation_integration.service.dart';
import 'package:Classy/models/order.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class EnhancedDriverNavigationPage extends StatefulWidget {
  final Order? currentOrder;
  final LatLng? initialPosition;
  
  const EnhancedDriverNavigationPage({
    Key? key,
    this.currentOrder,
    this.initialPosition,
  }) : super(key: key);

  @override
  State<EnhancedDriverNavigationPage> createState() => _EnhancedDriverNavigationPageState();
}

class _EnhancedDriverNavigationPageState extends State<EnhancedDriverNavigationPage> {
  final EnhancedNavigationIntegrationService _navService = EnhancedNavigationIntegrationService();
  final GlobalKey<EnhancedGoogleMapWidgetState> _mapKey = GlobalKey();
  
  Order? _currentOrder;
  String _navigationStatus = 'Ready to navigate';
  String _navigationInstruction = '';
  double _remainingDistance = 0;
  Duration _remainingTime = Duration.zero;
  bool _isNavigating = false;
  String _driverStatus = 'offline';

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.currentOrder;
    _setupNavigation();
  }

  void _setupNavigation() {
    _navService.onStatusUpdate = (status) {
      setState(() {
        _navigationStatus = status;
      });
    };

    _navService.onOrderUpdate = (order) {
      setState(() {
        _currentOrder = order;
      });
    };

    _navService.onLocationUpdate = (location) {
      // Update driver location
      _updateDriverLocation(location);
    };

    _navService.onDistanceUpdate = (distance) {
      setState(() {
        _remainingDistance = distance;
      });
    };

    _navService.onTimeUpdate = (time) {
      setState(() {
        _remainingTime = time;
      });
    };

    _navService.onNavigationInstruction = (instruction) {
      setState(() {
        _navigationInstruction = instruction;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Navigation'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Driver status toggle
          IconButton(
            icon: Icon(_driverStatus == 'online' ? Icons.wifi : Icons.wifi_off),
            onPressed: _toggleDriverStatus,
          ),
        ],
      ),
      body: Column(
        children: [
          // Order Information Panel
          if (_currentOrder != null) _buildOrderInfo(),
          
          // Enhanced Google Map
          Expanded(
            child: EnhancedGoogleMapWidget(
              key: _mapKey,
              initialPosition: widget.initialPosition ?? const LatLng(0.3476, 32.5825),
              showSearchBar: false,
              showNavigationControls: true,
              enableNavigation: _isNavigating,
              onLocationSelected: _onLocationSelected,
              onRouteSet: _onRouteSet,
              onNavigationUpdate: _onNavigationUpdate,
            ),
          ),
          
          // Navigation Controls Panel
          _buildNavigationControls(),
          
          // Navigation Status Panel
          if (_isNavigating) _buildNavigationStatus(),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    if (_currentOrder == null) return const SizedBox.shrink();
    
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
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Order #${_currentOrder!.id.substring(0, 8)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(_currentOrder!.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentOrder!.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_currentOrder!.pickupLocation != null)
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pickup: ${_currentOrder!.pickupLocation!.address}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          if (_currentOrder!.destinationLocation != null)
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Destination: ${_currentOrder!.destinationLocation!.address}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
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
        children: [
          // Driver Status
          _buildDriverStatus(),
          
          const SizedBox(height: 16),
          
          // Navigation Controls
          Row(
            children: [
              // Start Navigation Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _currentOrder != null && !_isNavigating
                      ? _startNavigation
                      : null,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Start Navigation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Stop Navigation Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isNavigating ? _stopNavigation : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Navigation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Order Actions
          if (_currentOrder != null) _buildOrderActions(),
        ],
      ),
    );
  }

  Widget _buildDriverStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _driverStatus == 'online' ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _driverStatus == 'online' ? Colors.green : Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _driverStatus == 'online' ? Icons.wifi : Icons.wifi_off,
            color: _driverStatus == 'online' ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            _driverStatus == 'online' ? 'Online - Available for orders' : 'Offline',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _driverStatus == 'online' ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions() {
    return Row(
      children: [
        // Accept Order
        if (_currentOrder!.status == 'pending')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _acceptOrder,
              icon: const Icon(Icons.check),
              label: const Text('Accept Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        
        if (_currentOrder!.status == 'pending') const SizedBox(width: 8),
        
        // Pickup Order
        if (_currentOrder!.status == 'accepted')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _pickupOrder,
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Pickup Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        
        if (_currentOrder!.status == 'picked_up') const SizedBox(width: 8),
        
        // Complete Order
        if (_currentOrder!.status == 'picked_up')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _completeOrder,
              icon: const Icon(Icons.check_circle),
              label: const Text('Complete Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationStatus() {
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
        children: [
          // Navigation Instruction
          Row(
            children: [
              const Icon(Icons.navigation, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _navigationInstruction,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Distance and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_remainingDistance.toStringAsFixed(1)} km remaining',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${_remainingTime.inMinutes} min',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onLocationSelected(dynamic location) {
    // Handle location selection
  }

  void _onRouteSet(LatLng pickup, LatLng destination) {
    // Handle route setting
  }

  void _onNavigationUpdate(String status) {
    setState(() {
      _navigationStatus = status;
    });
  }

  void _toggleDriverStatus() {
    setState(() {
      _driverStatus = _driverStatus == 'online' ? 'offline' : 'online';
    });
  }

  void _startNavigation() async {
    if (_currentOrder == null) return;

    setState(() {
      _isNavigating = true;
    });

    await _navService.startNavigationForOrder(_currentOrder!);
  }

  void _stopNavigation() async {
    setState(() {
      _isNavigating = false;
    });

    await _navService.stopNavigation();
  }

  void _acceptOrder() async {
    if (_currentOrder == null) return;

    try {
      await _navService.updateBookingStatus(
        bookingId: _currentOrder!.id,
        status: 'accepted',
        additionalData: {
          'accepted_at': DateTime.now().toIso8601String(),
          'driver_id': 'current_driver_id',
        },
      );
      
      setState(() {
        _currentOrder!.status = 'accepted';
      });
    } catch (e) {
      _showError('Failed to accept order: $e');
    }
  }

  void _pickupOrder() async {
    if (_currentOrder == null) return;

    try {
      await _navService.updateBookingStatus(
        bookingId: _currentOrder!.id,
        status: 'picked_up',
        additionalData: {
          'picked_up_at': DateTime.now().toIso8601String(),
        },
      );
      
      setState(() {
        _currentOrder!.status = 'picked_up';
      });
    } catch (e) {
      _showError('Failed to pickup order: $e');
    }
  }

  void _completeOrder() async {
    if (_currentOrder == null) return;

    try {
      await _navService.updateBookingStatus(
        bookingId: _currentOrder!.id,
        status: 'delivered',
        additionalData: {
          'delivered_at': DateTime.now().toIso8601String(),
        },
      );
      
      setState(() {
        _currentOrder!.status = 'delivered';
        _isNavigating = false;
      });
    } catch (e) {
      _showError('Failed to complete order: $e');
    }
  }

  void _updateDriverLocation(LatLng location) {
    // Update driver location in Firebase
    // This is handled by the navigation service
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _navService.dispose();
    super.dispose();
  }
}
