import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/widgets/enhanced_google_map.widget.dart';
import 'package:Classy/services/enhanced_navigation_integration.service.dart';
import 'package:Classy/models/order.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class EnhancedDeliveryTrackingPage extends StatefulWidget {
  final Order? order;
  
  const EnhancedDeliveryTrackingPage({
    Key? key,
    this.order,
  }) : super(key: key);

  @override
  State<EnhancedDeliveryTrackingPage> createState() => _EnhancedDeliveryTrackingPageState();
}

class _EnhancedDeliveryTrackingPageState extends State<EnhancedDeliveryTrackingPage> {
  final EnhancedNavigationIntegrationService _navService = EnhancedNavigationIntegrationService();
  final GlobalKey<EnhancedGoogleMapWidgetState> _mapKey = GlobalKey();
  
  Order? _currentOrder;
  String _trackingStatus = 'Tracking order delivery';
  String _driverLocation = '';
  double _distanceToCustomer = 0;
  Duration _estimatedDeliveryTime = Duration.zero;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _setupTracking();
  }

  void _setupTracking() {
    _navService.onStatusUpdate = (status) {
      setState(() {
        _trackingStatus = status;
      });
    };

    _navService.onOrderUpdate = (order) {
      setState(() {
        _currentOrder = order;
      });
    };

    _navService.onLocationUpdate = (location) {
      setState(() {
        _driverLocation = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      });
    };

    _navService.onDistanceUpdate = (distance) {
      setState(() {
        _distanceToCustomer = distance;
      });
    };

    _navService.onTimeUpdate = (time) {
      setState(() {
        _estimatedDeliveryTime = time;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTracking,
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
              initialPosition: const LatLng(0.3476, 32.5825), // Kampala
              showSearchBar: false,
              showNavigationControls: false,
              enableNavigation: false,
              onLocationSelected: _onLocationSelected,
              onRouteSet: _onRouteSet,
              onNavigationUpdate: _onNavigationUpdate,
            ),
          ),
          
          // Tracking Status Panel
          _buildTrackingStatus(),
          
          // Customer Information
          if (_currentOrder != null) _buildCustomerInfo(),
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
              const Icon(Icons.shopping_bag, color: Colors.blue),
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
          Text(
            'Order Value: \$${_currentOrder!.total?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStatus() {
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
          // Tracking Status
          Row(
            children: [
              const Icon(Icons.local_shipping, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _trackingStatus,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Delivery Information
          Row(
            children: [
              // Distance
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${_distanceToCustomer.toStringAsFixed(1)} km',
                  color: Colors.blue,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Estimated Time
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.access_time,
                  label: 'ETA',
                  value: '${_estimatedDeliveryTime.inMinutes} min',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Driver Location
          if (_driverLocation.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Driver Location: $_driverLocation',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    if (_currentOrder == null || _currentOrder!.destinationLocation == null) {
      return const SizedBox.shrink();
    }
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentOrder!.destinationLocation!.address ?? 'Address not available',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Contact Customer Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _contactCustomer,
              icon: const Icon(Icons.phone),
              label: const Text('Contact Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
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
      _trackingStatus = status;
    });
  }

  void _refreshTracking() {
    // Refresh tracking data
    setState(() {
      _isTracking = !_isTracking;
    });
  }

  void _contactCustomer() {
    // Show contact options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contact Customer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Customer'),
              onTap: () {
                Navigator.pop(context);
                // Implement call functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                // Implement messaging functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.orange),
              title: const Text('Send Email'),
              onTap: () {
                Navigator.pop(context);
                // Implement email functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.cyan;
      case 'picked_up':
        return Colors.indigo;
      case 'in_transit':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _navService.dispose();
    super.dispose();
  }
}
