import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/models/order.dart';
import 'package:Classy/services/enhanced_google_maps.service.dart';
import 'package:Classy/services/firebase_data.service.dart';

class BookingNavigationService {
  static final BookingNavigationService _instance = BookingNavigationService._internal();
  factory BookingNavigationService() => _instance;
  BookingNavigationService._internal();

  final EnhancedGoogleMapsService _mapsService = EnhancedGoogleMapsService();
  final FirebaseDataService _firebaseService = FirebaseDataService();
  
  // Navigation state
  bool _isNavigating = false;
  Order? _currentOrder;
  Timer? _locationUpdateTimer;
  StreamSubscription? _orderUpdateSubscription;
  
  // Callbacks
  Function(Order)? onOrderUpdate;
  Function(String)? onNavigationStatus;
  Function(LatLng)? onDriverLocationUpdate;
  Function(double)? onDistanceUpdate;
  Function(Duration)? onTimeUpdate;

  // Getters
  bool get isNavigating => _isNavigating;
  Order? get currentOrder => _currentOrder;

  /// Start navigation for a booking
  Future<void> startNavigationForBooking(Order order) async {
    if (_isNavigating) {
      await stopNavigation();
    }

    _currentOrder = order;
    _isNavigating = true;

    // Set up route if pickup and destination are available
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

    // Start location tracking
    _startLocationTracking();
    
    // Start order status monitoring
    _startOrderMonitoring();

    onNavigationStatus?.call('Navigation started for order ${order.id}');
  }

  /// Stop navigation
  Future<void> stopNavigation() async {
    _isNavigating = false;
    _locationUpdateTimer?.cancel();
    _orderUpdateSubscription?.cancel();
    _mapsService.stopNavigation();
    _currentOrder = null;
    
    onNavigationStatus?.call('Navigation stopped');
  }

  /// Start location tracking
  void _startLocationTracking() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateLocationAndOrder();
    });

    // Set up maps service callbacks
    _mapsService.onLocationUpdate = (location) {
      _updateDriverLocation(location);
    };

    _mapsService.onDistanceUpdate = (distance) {
      onDistanceUpdate?.call(distance);
    };

    _mapsService.onTimeUpdate = (time) {
      onTimeUpdate?.call(time);
    };
  }

  /// Start monitoring order status changes
  void _startOrderMonitoring() {
    if (_currentOrder == null) return;

    // Listen to order updates from Firebase
    _orderUpdateSubscription = _firebaseService
        .listenToDocument('orders', _currentOrder!.id)
        .listen((orderData) {
      if (orderData.isNotEmpty) {
        final updatedOrder = Order.fromJson(orderData);
        _currentOrder = updatedOrder;
        onOrderUpdate?.call(updatedOrder);
        
        // Handle order status changes
        _handleOrderStatusChange(updatedOrder.status);
      }
    });
  }

  /// Handle order status changes
  void _handleOrderStatusChange(String status) {
    switch (status) {
      case 'accepted':
        onNavigationStatus?.call('Order accepted by driver');
        break;
      case 'picked_up':
        onNavigationStatus?.call('Package picked up, heading to destination');
        break;
      case 'in_transit':
        onNavigationStatus?.call('Package in transit');
        break;
      case 'delivered':
        onNavigationStatus?.call('Package delivered successfully');
        stopNavigation();
        break;
      case 'cancelled':
        onNavigationStatus?.call('Order cancelled');
        stopNavigation();
        break;
    }
  }

  /// Update driver location and order
  Future<void> _updateLocationAndOrder() async {
    if (_currentOrder == null || !_isNavigating) return;

    try {
      // Update driver location in Firebase
      await _firebaseService.updateDriverLocation(
        _currentOrder!.driverId ?? '',
        {
          'latitude': _mapsService.currentLocation?.latitude,
          'longitude': _mapsService.currentLocation?.longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'order_id': _currentOrder!.id,
        },
      );

      // Update order with current location
      await _firebaseService.updateOrderStatus(
        _currentOrder!.id,
        'in_transit',
        additionalData: {
          'current_latitude': _mapsService.currentLocation?.latitude,
          'current_longitude': _mapsService.currentLocation?.longitude,
          'last_updated': DateTime.now().toIso8601String(),
        },
      );

    } catch (e) {
      print('Error updating location: $e');
    }
  }

  /// Update driver location
  void _updateDriverLocation(LatLng location) {
    onDriverLocationUpdate?.call(location);
  }

  /// Get nearby drivers for booking
  Future<List<Map<String, dynamic>>> getNearbyDrivers({
    required LatLng location,
    double radius = 10.0,
    int limit = 20,
  }) async {
    try {
      return await _firebaseService.getNearbyDrivers(
        location.latitude,
        location.longitude,
        radius: radius,
        limit: limit,
      );
    } catch (e) {
      print('Error getting nearby drivers: $e');
      return [];
    }
  }

  /// Create a new booking
  Future<Map<String, dynamic>> createBooking({
    required String customerId,
    required DeliveryAddress pickupLocation,
    required DeliveryAddress destinationLocation,
    required String serviceType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final bookingData = {
        'customer_id': customerId,
        'pickup_location': {
          'address': pickupLocation.address,
          'latitude': pickupLocation.latitude,
          'longitude': pickupLocation.longitude,
          'city': pickupLocation.city,
          'state': pickupLocation.state,
          'country': pickupLocation.country,
        },
        'destination_location': {
          'address': destinationLocation.address,
          'latitude': destinationLocation.latitude,
          'longitude': destinationLocation.longitude,
          'city': destinationLocation.city,
          'state': destinationLocation.state,
          'country': destinationLocation.country,
        },
        'service_type': serviceType,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      return await _firebaseService.createOrder(bookingData);
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  /// Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firebaseService.updateOrderStatus(
        bookingId,
        status,
        additionalData: additionalData,
      );
    } catch (e) {
      print('Error updating booking status: $e');
      rethrow;
    }
  }

  /// Get booking details
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      return await _firebaseService.getOrderById(bookingId);
    } catch (e) {
      print('Error getting booking details: $e');
      return null;
    }
  }

  /// Get user bookings
  Stream<List<Map<String, dynamic>>> getUserBookings(String userId, String userType) {
    return _firebaseService.getUserOrdersStream(userId, userType);
  }

  /// Calculate estimated fare
  double calculateFare({
    required double distance,
    required String serviceType,
    Map<String, dynamic>? pricingData,
  }) {
    double baseFare = 5.0;
    double perKmRate = 2.0;

    // Adjust pricing based on service type
    switch (serviceType.toLowerCase()) {
      case 'taxi':
        baseFare = 3.0;
        perKmRate = 1.5;
        break;
      case 'parcel':
        baseFare = 4.0;
        perKmRate = 1.0;
        break;
      case 'food':
        baseFare = 2.0;
        perKmRate = 0.8;
        break;
    }

    // Apply custom pricing if provided
    if (pricingData != null) {
      baseFare = pricingData['base_fare'] ?? baseFare;
      perKmRate = pricingData['per_km_rate'] ?? perKmRate;
    }

    return baseFare + (distance * perKmRate);
  }

  /// Calculate estimated time
  Duration calculateEstimatedTime({
    required double distance,
    required String serviceType,
    String trafficCondition = 'normal',
  }) {
    double averageSpeed = 30.0; // km/h

    // Adjust speed based on service type
    switch (serviceType.toLowerCase()) {
      case 'taxi':
        averageSpeed = 25.0;
        break;
      case 'parcel':
        averageSpeed = 35.0;
        break;
      case 'food':
        averageSpeed = 20.0;
        break;
    }

    // Adjust for traffic conditions
    switch (trafficCondition.toLowerCase()) {
      case 'heavy':
        averageSpeed *= 0.6;
        break;
      case 'light':
        averageSpeed *= 1.2;
        break;
    }

    final hours = distance / averageSpeed;
    return Duration(minutes: (hours * 60).round());
  }

  /// Send notification to driver
  Future<void> notifyDriver({
    required String driverId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firebaseService.createNotification({
        'user_id': driverId,
        'title': title,
        'message': message,
        'type': 'booking_request',
        'data': data ?? {},
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopNavigation();
    _mapsService.dispose();
  }
}
