import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/services/geocoder.service.dart';

class EnhancedGoogleMapsService {
  static final EnhancedGoogleMapsService _instance = EnhancedGoogleMapsService._internal();
  factory EnhancedGoogleMapsService() => _instance;
  EnhancedGoogleMapsService._internal();

  final PolylinePoints _polylinePoints = PolylinePoints();
  final GeocoderService _geocoderService = GeocoderService();
  
  // Map controller and state
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _locationSubscription;
  
  // Route and navigation data
  List<LatLng> _routePoints = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  
  // Current location tracking
  LatLng? _currentLocation;
  LatLng? _destination;
  LatLng? _pickupLocation;
  
  // Navigation state
  bool _isNavigating = false;
  int _currentRouteIndex = 0;
  Timer? _navigationTimer;
  
  // Callbacks
  Function(LatLng)? onLocationUpdate;
  Function(String)? onRouteUpdate;
  Function(double)? onDistanceUpdate;
  Function(Duration)? onTimeUpdate;
  Function(String)? onNavigationInstruction;

  // Getters
  GoogleMapController? get mapController => _mapController;
  List<LatLng> get routePoints => _routePoints;
  Set<Polyline> get polylines => _polylines;
  Set<Marker> get markers => _markers;
  LatLng? get currentLocation => _currentLocation;
  LatLng? get destination => _destination;
  LatLng? get pickupLocation => _pickupLocation;
  bool get isNavigating => _isNavigating;

  /// Initialize the map controller
  void initializeMap(GoogleMapController controller) {
    _mapController = controller;
    _startLocationTracking();
  }

  /// Start tracking user's current location
  void _startLocationTracking() async {
    try {
      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Start location updates
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        onLocationUpdate?.call(_currentLocation!);
        
        if (_isNavigating) {
          _updateNavigation();
        }
      });
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  /// Set pickup and destination locations
  Future<void> setRoute({
    required LatLng pickup,
    required LatLng destination,
    String? pickupAddress,
    String? destinationAddress,
  }) async {
    _pickupLocation = pickup;
    _destination = destination;
    
    // Clear existing route
    _clearRoute();
    
    // Get route between points
    await _getRouteBetweenPoints(pickup, destination);
    
    // Add markers
    _addRouteMarkers(pickup, destination, pickupAddress, destinationAddress);
    
    // Update map camera to show entire route
    await _fitRouteInView();
  }

  /// Get route between two points using Google Directions API
  Future<void> _getRouteBetweenPoints(LatLng origin, LatLng destination) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        AppStrings.googleMapApiKey,
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        _routePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // Create polyline
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: _routePoints,
          color: Colors.blue,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        );

        _polylines = {polyline};
        
        // Calculate route statistics
        _calculateRouteStats();
      }
    } catch (e) {
      print('Error getting route: $e');
    }
  }

  /// Add markers for pickup and destination
  void _addRouteMarkers(
    LatLng pickup,
    LatLng destination,
    String? pickupAddress,
    String? destinationAddress,
  ) {
    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup Location',
          snippet: pickupAddress ?? 'Pickup point',
        ),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: destinationAddress ?? 'Destination point',
        ),
      ),
    };
  }

  /// Calculate route statistics (distance, time, etc.)
  void _calculateRouteStats() {
    if (_routePoints.isEmpty) return;

    // Calculate total distance
    double totalDistance = 0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        _routePoints[i],
        _routePoints[i + 1],
      );
    }

    // Estimate travel time (assuming average speed of 50 km/h)
    final estimatedTime = Duration(
      minutes: (totalDistance / 50 * 60).round(),
    );

    onDistanceUpdate?.call(totalDistance);
    onTimeUpdate?.call(estimatedTime);
  }

  /// Calculate distance between two points in kilometers
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double lat1Rad = point1.latitude * (math.pi / 180);
    final double lat2Rad = point2.latitude * (math.pi / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (math.pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (math.pi / 180);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Start navigation
  void startNavigation() {
    if (_routePoints.isEmpty) return;
    
    _isNavigating = true;
    _currentRouteIndex = 0;
    
    // Start navigation timer for updates
    _navigationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateNavigation();
    });
    
    _updateNavigation();
  }

  /// Stop navigation
  void stopNavigation() {
    _isNavigating = false;
    _navigationTimer?.cancel();
    _navigationTimer = null;
  }

  /// Update navigation status
  void _updateNavigation() {
    if (!_isNavigating || _currentLocation == null || _routePoints.isEmpty) return;

    // Find closest point on route
    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < _routePoints.length; i++) {
      final distance = _calculateDistance(_currentLocation!, _routePoints[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    _currentRouteIndex = closestIndex;

    // Calculate remaining distance and time
    double remainingDistance = 0;
    for (int i = closestIndex; i < _routePoints.length - 1; i++) {
      remainingDistance += _calculateDistance(
        _routePoints[i],
        _routePoints[i + 1],
      );
    }

    final remainingTime = Duration(
      minutes: (remainingDistance / 50 * 60).round(),
    );

    onRouteUpdate?.call('${remainingDistance.toStringAsFixed(1)} km remaining');
    onDistanceUpdate?.call(remainingDistance);
    onTimeUpdate?.call(remainingTime);

    // Generate navigation instruction
    _generateNavigationInstruction(closestIndex);
  }

  /// Generate navigation instruction based on current position
  void _generateNavigationInstruction(int routeIndex) {
    if (routeIndex >= _routePoints.length - 1) {
      onNavigationInstruction?.call('You have arrived at your destination');
      return;
    }

    // Simple instruction based on direction
    final current = _routePoints[routeIndex];
    final next = _routePoints[routeIndex + 1];
    
    final bearing = _calculateBearing(current, next);
    String instruction = _getDirectionInstruction(bearing);
    
    onNavigationInstruction?.call(instruction);
  }

  /// Calculate bearing between two points
  double _calculateBearing(LatLng from, LatLng to) {
    final double lat1 = from.latitude * (math.pi / 180);
    final double lat2 = to.latitude * (math.pi / 180);
    final double deltaLng = (to.longitude - from.longitude) * (math.pi / 180);

    final double y = math.sin(deltaLng) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    double bearing = math.atan2(y, x) * (180 / math.pi);
    return (bearing + 360) % 360;
  }

  /// Get direction instruction based on bearing
  String _getDirectionInstruction(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) {
      return 'Continue straight';
    } else if (bearing >= 22.5 && bearing < 67.5) {
      return 'Turn slightly right';
    } else if (bearing >= 67.5 && bearing < 112.5) {
      return 'Turn right';
    } else if (bearing >= 112.5 && bearing < 157.5) {
      return 'Turn sharp right';
    } else if (bearing >= 157.5 && bearing < 202.5) {
      return 'Turn around';
    } else if (bearing >= 202.5 && bearing < 247.5) {
      return 'Turn sharp left';
    } else if (bearing >= 247.5 && bearing < 292.5) {
      return 'Turn left';
    } else if (bearing >= 292.5 && bearing < 337.5) {
      return 'Turn slightly left';
    }
    return 'Continue straight';
  }

  /// Fit route in map view
  Future<void> _fitRouteInView() async {
    if (_routePoints.isEmpty || _mapController == null) return;

    final bounds = _calculateBounds(_routePoints);
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  /// Calculate bounds for a list of points
  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Clear current route
  void _clearRoute() {
    _routePoints.clear();
    _polylines.clear();
    _markers.clear();
    _currentRouteIndex = 0;
  }

  /// Search for places
  Future<List<DeliveryAddress>> searchPlaces(String query) async {
    try {
      final addresses = await _geocoderService.findAddressesFromQuery(query);
      return addresses.map((address) => DeliveryAddress(
        address: address.addressLine,
        latitude: address.coordinates?.latitude,
        longitude: address.coordinates?.longitude,
        city: address.locality,
        state: address.adminArea,
        country: address.countryName,
      )).toList();
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  /// Get current location address
  Future<DeliveryAddress?> getCurrentLocationAddress() async {
    if (_currentLocation == null) return null;

    try {
      final addresses = await _geocoderService.findAddressesFromCoordinates(
        Coordinates(_currentLocation!.latitude, _currentLocation!.longitude),
      );

      if (addresses.isNotEmpty) {
        final address = addresses.first;
        return DeliveryAddress(
          address: address.addressLine,
          latitude: address.coordinates?.latitude,
          longitude: address.coordinates?.longitude,
          city: address.locality,
          state: address.adminArea,
          country: address.countryName,
        );
      }
    } catch (e) {
      print('Error getting current location address: $e');
    }

    return null;
  }

  /// Dispose resources
  void dispose() {
    _locationSubscription?.cancel();
    _navigationTimer?.cancel();
    _mapController = null;
  }
}
