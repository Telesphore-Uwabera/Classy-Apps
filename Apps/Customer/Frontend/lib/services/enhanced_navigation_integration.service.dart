import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/services/enhanced_google_maps.service.dart';
import 'package:Classy/services/booking_navigation.service.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/models/order.dart';

/// Enhanced Navigation Integration Service
/// 
/// This service provides Google Maps-like navigation functionality
/// with full integration to the booking system, similar to the screenshot
/// showing route planning, real-time navigation, and booking management.
class EnhancedNavigationIntegrationService {
  static final EnhancedNavigationIntegrationService _instance = 
      EnhancedNavigationIntegrationService._internal();
  factory EnhancedNavigationIntegrationService() => _instance;
  EnhancedNavigationIntegrationService._internal();

  final EnhancedGoogleMapsService _mapsService = EnhancedGoogleMapsService();
  final BookingNavigationService _bookingService = BookingNavigationService();

  // Navigation state
  bool _isInitialized = false;
  Order? _activeOrder;
  String _currentNavigationStatus = '';

  // Callbacks for UI updates
  Function(String)? onStatusUpdate;
  Function(Order)? onOrderUpdate;
  Function(LatLng)? onLocationUpdate;
  Function(double)? onDistanceUpdate;
  Function(Duration)? onTimeUpdate;
  Function(String)? onNavigationInstruction;

  /// Initialize the enhanced navigation system
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set up maps service callbacks
    _mapsService.onLocationUpdate = (location) {
      onLocationUpdate?.call(location);
      _updateOrderLocation(location);
    };

    _mapsService.onRouteUpdate = (status) {
      _currentNavigationStatus = status;
      onStatusUpdate?.call(status);
    };

    _mapsService.onDistanceUpdate = (distance) {
      onDistanceUpdate?.call(distance);
    };

    _mapsService.onTimeUpdate = (time) {
      onTimeUpdate?.call(time);
    };

    _mapsService.onNavigationInstruction = (instruction) {
      onNavigationInstruction?.call(instruction);
    };

    // Set up booking service callbacks
    _bookingService.onOrderUpdate = (order) {
      _activeOrder = order;
      onOrderUpdate?.call(order);
    };

    _bookingService.onNavigationStatus = (status) {
      _currentNavigationStatus = status;
      onStatusUpdate?.call(status);
    };

    _bookingService.onDriverLocationUpdate = (location) {
      onLocationUpdate?.call(location);
    };

    _bookingService.onDistanceUpdate = (distance) {
      onDistanceUpdate?.call(distance);
    };

    _bookingService.onTimeUpdate = (time) {
      onTimeUpdate?.call(time);
    };

    _isInitialized = true;
  }

  /// Create a new booking with route planning
  Future<Map<String, dynamic>> createBookingWithRoute({
    required String customerId,
    required DeliveryAddress pickupLocation,
    required DeliveryAddress destinationLocation,
    required String serviceType,
    Map<String, dynamic>? serviceOptions,
  }) async {
    try {
      // Calculate route and get estimates
      await _mapsService.setRoute(
        pickup: LatLng(pickupLocation.latitude!, pickupLocation.longitude!),
        destination: LatLng(destinationLocation.latitude!, destinationLocation.longitude!),
        pickupAddress: pickupLocation.address,
        destinationAddress: destinationLocation.address,
      );

      // Get route statistics
      final distance = _mapsService.routePoints.isNotEmpty ? 
          _calculateRouteDistance(_mapsService.routePoints) : 0.0;
      final estimatedTime = _bookingService.calculateEstimatedTime(
        distance: distance,
        serviceType: serviceType,
      );
      final estimatedFare = _bookingService.calculateFare(
        distance: distance,
        serviceType: serviceType,
        pricingData: serviceOptions,
      );

      // Create booking with route data
      final bookingData = {
        'customer_id': customerId,
        'pickup_location': pickupLocation.toJson(),
        'destination_location': destinationLocation.toJson(),
        'service_type': serviceType,
        'estimated_distance': distance,
        'estimated_time': estimatedTime.inMinutes,
        'estimated_fare': estimatedFare,
        'route_points': _mapsService.routePoints.map((point) => {
          'latitude': point.latitude,
          'longitude': point.longitude,
        }).toList(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...?serviceOptions,
      };

      final booking = await _bookingService.createBooking(
        customerId: customerId,
        pickupLocation: pickupLocation,
        destinationLocation: destinationLocation,
        serviceType: serviceType,
        additionalData: bookingData,
      );

      return booking;
    } catch (e) {
      print('Error creating booking with route: $e');
      rethrow;
    }
  }

  /// Start navigation for an active order
  Future<void> startNavigationForOrder(Order order) async {
    if (!_isInitialized) {
      await initialize();
    }

    _activeOrder = order;
    
    // Set up route if not already set
    if (order.pickupLocation != null && order.destinationLocation != null) {
      await _mapsService.setRoute(
        pickup: LatLng(
          order.pickupLocation!.latitude!,
          order.pickupLocation!.longitude!,
        ),
        destination: LatLng(
          order.destinationLocation!.latitude!,
          order.destinationLocation!.longitude!,
        ),
        pickupAddress: order.pickupLocation!.address,
        destinationAddress: order.destinationLocation!.address,
      );
    }

    // Start navigation
    _mapsService.startNavigation();
    await _bookingService.startNavigationForBooking(order);
    
    onStatusUpdate?.call('Navigation started');
  }

  /// Stop navigation
  Future<void> stopNavigation() async {
    _mapsService.stopNavigation();
    await _bookingService.stopNavigation();
    _activeOrder = null;
    onStatusUpdate?.call('Navigation stopped');
  }

  /// Update order location
  void _updateOrderLocation(LatLng location) {
    if (_activeOrder != null) {
      // Update order with current location
      _bookingService.updateBookingStatus(
        bookingId: _activeOrder!.id,
        status: 'in_transit',
        additionalData: {
          'current_latitude': location.latitude,
          'current_longitude': location.longitude,
          'last_updated': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  /// Calculate route distance
  double _calculateRouteDistance(List<LatLng> routePoints) {
    if (routePoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        routePoints[i],
        routePoints[i + 1],
      );
    }
    return totalDistance;
  }

  /// Calculate distance between two points
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double lat1Rad = point1.latitude * (3.14159265359 / 180);
    final double lat2Rad = point2.latitude * (3.14159265359 / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (3.14159265359 / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (3.14159265359 / 180);

    final double a = (deltaLatRad / 2).sin() * (deltaLatRad / 2).sin() +
        lat1Rad.cos() * lat2Rad.cos() *
        (deltaLngRad / 2).sin() * (deltaLngRad / 2).sin();
    
    final double c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    
    return earthRadius * c;
  }

  /// Get nearby drivers for booking
  Future<List<Map<String, dynamic>>> getNearbyDrivers({
    required LatLng location,
    double radius = 10.0,
    int limit = 20,
  }) async {
    return await _bookingService.getNearbyDrivers(
      location: location,
      radius: radius,
      limit: limit,
    );
  }

  /// Search for places
  Future<List<DeliveryAddress>> searchPlaces(String query) async {
    return await _mapsService.searchPlaces(query);
  }

  /// Get current location address
  Future<DeliveryAddress?> getCurrentLocationAddress() async {
    return await _mapsService.getCurrentLocationAddress();
  }

  /// Get route information
  Map<String, dynamic> getRouteInfo() {
    return {
      'route_points': _mapsService.routePoints,
      'polylines': _mapsService.polylines,
      'markers': _mapsService.markers,
      'is_navigating': _mapsService.isNavigating,
      'current_location': _mapsService.currentLocation,
      'destination': _mapsService.destination,
      'pickup_location': _mapsService.pickupLocation,
    };
  }

  /// Get navigation status
  Map<String, dynamic> getNavigationStatus() {
    return {
      'is_navigating': _mapsService.isNavigating,
      'active_order': _activeOrder?.toJson(),
      'status': _currentNavigationStatus,
      'current_location': _mapsService.currentLocation,
    };
  }

  /// Dispose resources
  void dispose() {
    _mapsService.dispose();
    _bookingService.dispose();
    _isInitialized = false;
  }
}
