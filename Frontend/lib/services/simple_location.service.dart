import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:Classy/models/address.dart';
import 'package:Classy/models/coordinates.dart';

/// Simple location service using only Google APIs
/// No backend dependencies, no complex over-engineering
class SimpleLocationService {
  static Position? _currentPosition;
  static Address? _currentAddress;
  static StreamSubscription<Position>? _positionStream;

  /// Get current location with simple Google APIs
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      return _currentPosition;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get address from coordinates using Google Geocoding API
  static Future<Address?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Use Google's geocoding service directly
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        return Address(
          addressLine: _buildAddressLine(place),
          coordinates: Coordinates(lat, lng),
          featureName: place.locality ?? place.subAdministrativeArea ?? 'Unknown City',
          adminArea: place.administrativeArea ?? 'Unknown State',
          countryName: place.country ?? 'Unknown Country',
        );
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    
    return null;
  }

  /// Get current address (location + geocoding)
  static Future<Address?> getCurrentAddress() async {
    try {
      Position? position = await getCurrentLocation();
      if (position != null) {
        return await getAddressFromCoordinates(position.latitude, position.longitude);
      }
    } catch (e) {
      print('Error getting current address: $e');
    }
    
    return null;
  }

  /// Start listening to location changes
  static void startLocationUpdates(Function(Address) onLocationUpdate) {
    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) async {
        _currentPosition = position;
        
        // Get address for new position
        Address? address = await getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (address != null) {
          _currentAddress = address;
          onLocationUpdate(address);
        }
      });
    } catch (e) {
      print('Error starting location updates: $e');
    }
  }

  /// Stop location updates
  static void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  /// Get current position
  static Position? get currentPosition => _currentPosition;
  
  /// Get current address
  static Address? get currentAddress => _currentAddress;

  /// Build address line from placemark
  static String _buildAddressLine(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }
    
    return addressParts.join(', ');
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }
}
