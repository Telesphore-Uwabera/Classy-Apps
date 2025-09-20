import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geoflutterfire2/geoflutterfire2.dart'; // Unused for now
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:singleton/singleton.dart';
import '../models/delivery_address.dart';
import 'auth.service.dart';
import 'driver_firebase.service.dart';

class DriverLocationService {
  factory DriverLocationService() => Singleton.lazy(() => DriverLocationService._());
  DriverLocationService._() {}

  static DriverLocationService get instance => DriverLocationService();

  // final GeoFlutterFire _geoFlutterFire = GeoFlutterFire(); // Unused for now
  final DriverFirebaseService _driverFirebaseService = DriverFirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Location tracking state
  bool _isTracking = false;
  StreamSubscription<Position>? _locationSubscription;
  Position? _currentPosition;
  final BehaviorSubject<Position?> _positionSubject = BehaviorSubject<Position?>();
  final BehaviorSubject<bool> _isTrackingSubject = BehaviorSubject<bool>.seeded(false);

  // Location settings
  static const LocationAccuracy _defaultAccuracy = LocationAccuracy.high;
  static const double _distanceFilterMeters = 10.0; // Update every 10 meters

  // Getters
  bool get isTracking => _isTracking;
  Position? get currentPosition => _currentPosition;
  Stream<Position?> get positionStream => _positionSubject.stream;
  Stream<bool> get isTrackingStream => _isTrackingSubject.stream;

  // ========================================
  // LOCATION PERMISSIONS
  // ========================================

  /// Check if location permissions are granted
  Future<bool> hasLocationPermissions() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      print('Error checking location permissions: $e');
      return false;
    }
  }

  /// Request location permissions
  Future<bool> requestLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error requesting location permissions: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  // ========================================
  // LOCATION TRACKING
  // ========================================

  /// Start location tracking
  Future<bool> startLocationTracking() async {
    try {
      if (_isTracking) {
        print('Location tracking already started');
        return true;
      }

      // Check permissions
      if (!await hasLocationPermissions()) {
        final granted = await requestLocationPermissions();
        if (!granted) {
          print('Location permissions not granted');
          return false;
        }
      }

      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        print('Location services not enabled');
        return false;
      }

      // Start location stream
      _startLocationStream();
      return true;
    } catch (e) {
      print('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  void stopLocationTracking() {
    try {
      _locationSubscription?.cancel();
      _locationSubscription = null;
      _isTracking = false;
      _isTrackingSubject.add(false);
      print('Location tracking stopped');
    } catch (e) {
      print('Error stopping location tracking: $e');
    }
  }

  /// Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      if (!await hasLocationPermissions()) {
        await requestLocationPermissions();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: _defaultAccuracy,
        timeLimit: Duration(seconds: 10),
      );

      _updateCurrentPosition(position);
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get current location with timeout
  Future<Position?> getCurrentLocationWithTimeout({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      if (!await hasLocationPermissions()) {
        await requestLocationPermissions();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: _defaultAccuracy,
        timeLimit: timeout,
      );

      _updateCurrentPosition(position);
      return position;
    } catch (e) {
      print('Error getting current location with timeout: $e');
      return null;
    }
  }

  /// Start location stream
  void _startLocationStream() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: _defaultAccuracy,
        distanceFilter: _distanceFilterMeters.toInt(),
        timeLimit: Duration(seconds: 30),
      ),
    ).listen(
      _onLocationUpdate,
      onError: _onLocationError,
      onDone: _onLocationStreamDone,
      cancelOnError: false,
    );
    _isTrackingSubject.add(true);
  }

  /// Handle location updates
  void _onLocationUpdate(Position position) {
    _updateCurrentPosition(position);
  }

  /// Handle location errors
  void _onLocationError(dynamic error) {
    print('Location stream error: $error');
    // Don't stop tracking on error, let it retry
  }

  /// Handle location stream completion
  void _onLocationStreamDone() {
    print('Location stream completed');
    _isTracking = false;
    _isTrackingSubject.add(false);
  }

  /// Update current position and notify listeners
  void _updateCurrentPosition(Position position) {
    _currentPosition = position;
    _positionSubject.add(position);
    
    // Sync with Firebase
    _syncLocationWithFirebase(position);
  }

  /// Sync location with Firebase
  Future<void> _syncLocationWithFirebase(Position position) async {
    try {
      final user = await AuthServices.getCurrentUser();
      if (user != null) {
        await _driverFirebaseService.updateDriverLocation(
          user.id.toString(),
          position,
        );
      }
    } catch (e) {
      print('Error syncing location with Firebase: $e');
    }
  }

  // ========================================
  // DISTANCE CALCULATIONS
  // ========================================

  /// Calculate distance between two coordinates in meters
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Calculate bearing between two coordinates
  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _degreesToRadians(lon2 - lon1);
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);

    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) - 
              math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Convert radians to degrees
  double _radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }

  // ========================================
  // ADDRESS RESOLUTION
  // ========================================

  /// Get formatted address from coordinates
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // TODO: Implement proper geocoding with geocoding package
      // For now, return a placeholder address
      return "Address at $latitude, $longitude";
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      // TODO: Implement proper geocoding with geocoding package
      // For now, return null
      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  // ========================================
  // DELIVERY ADDRESS MANAGEMENT
  // ========================================

  /// Create delivery address from position
  Future<DeliveryAddress?> createDeliveryAddressFromPosition(Position position) async {
    try {
      final address = await getAddressFromCoordinates(position.latitude, position.longitude);
      if (address != null) {
        return DeliveryAddress(
          name: address,
          address: address,
          latitude: position.latitude,
          longitude: position.longitude,
          city: '',
          state: '',
          country: '',
        );
      }
      return null;
    } catch (e) {
      print('Error creating delivery address: $e');
      return null;
    }
  }

  // ========================================
  // CLEANUP
  // ========================================

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
    _positionSubject.close();
    _isTrackingSubject.close();
  }
}