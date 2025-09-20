import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Mobile-safe implementation that mirrors the WebLocationService API
/// so existing imports/usages still compile on Android/iOS.
class WebLocationService {
  static Future<Position?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (kIsWeb) {
      throw Exception('This mobile implementation should not run on web');
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );
      return position;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[];
        if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
        if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
          parts.add(p.administrativeArea!);
        }
        if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);
        return parts.isNotEmpty ? parts.join(', ') : null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getCurrentAddress({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final position = await getCurrentPosition(timeout: timeout);
    if (position == null) return null;
    return await getAddressFromPosition(position);
  }

  static Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }
}


