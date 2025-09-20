import 'package:Classy/constants/app_map_settings.dart';
import 'package:Classy/models/address.dart';
import 'package:Classy/models/coordinates.dart';
import 'package:Classy/services/http.service.dart';
import 'package:singleton/singleton.dart';

export 'package:Classy/models/address.dart';
export 'package:Classy/models/coordinates.dart';

class GeocoderService extends HttpService {
//
  /// Factory method that reuse same instance automatically
  factory GeocoderService() => Singleton.lazy(() => GeocoderService._());

  /// Private constructor
  GeocoderService._() {}

  Future<List<Address>> findAddressesFromCoordinates(
    Coordinates coordinates, {
    int limit = 5,
  }) async {
    // For Firebase-only mode, use local geocoding or return mock data
    try {
      // Try to use local geocoding first
      if (AppMapSettings.useGoogleOnApp) {
        // Use Google's geocoding service directly
        return await _useGoogleGeocoding(coordinates, limit);
      } else {
        // For Firebase-only mode, return mock address data
        return await _getMockAddressData(coordinates);
      }
    } catch (e) {
      print("Geocoding error: $e");
      // Fallback to mock data
      return await _getMockAddressData(coordinates);
    }
  }

  /// Use Google's geocoding service directly (for when Google Maps is enabled)
  Future<List<Address>> _useGoogleGeocoding(Coordinates coordinates, int limit) async {
    // This would use Google's geocoding API directly
    // For now, return mock data
    return await _getMockAddressData(coordinates);
  }

  /// Get mock address data for Firebase-only mode
  Future<List<Address>> _getMockAddressData(Coordinates coordinates) async {
    return [
      Address(
        coordinates: coordinates,
        featureName: "Current Location",
        addressLine: "Lat: ${coordinates.latitude.toStringAsFixed(4)}, Lng: ${coordinates.longitude.toStringAsFixed(4)}",
        countryName: "Rwanda",
        countryCode: "RW",
        locality: "Kigali",
        subLocality: "City Center",
        postalCode: "00000",
        adminArea: "Kigali",
        subAdminArea: "Nyarugenge",
      )
    ];
  }

  Future<List<Address>> findAddressesFromQuery(String address) async {
    // For Firebase-only mode, return mock search results
    try {
      return await _getMockSearchResults(address);
    } catch (e) {
      print("Address search error: $e");
      return [];
    }
  }

  /// Get mock search results for Firebase-only mode
  Future<List<Address>> _getMockSearchResults(String query) async {
    // Return mock addresses based on the search query
    final mockAddresses = [
      Address(
        coordinates: Coordinates(-1.9441, 30.0619), // Kigali coordinates
        featureName: "$query - Kigali",
        addressLine: "$query, Kigali, Rwanda",
        countryName: "Rwanda",
        countryCode: "RW",
        locality: "Kigali",
        subLocality: "City Center",
        postalCode: "00000",
        adminArea: "Kigali",
        subAdminArea: "Nyarugenge",
      )..gMapPlaceId = "mock_place_id_${query.hashCode}",
      Address(
        coordinates: Coordinates(-1.9500, 30.0700),
        featureName: "$query - Nyarugenge",
        addressLine: "$query, Nyarugenge, Kigali, Rwanda",
        countryName: "Rwanda",
        countryCode: "RW",
        locality: "Kigali",
        subLocality: "Nyarugenge",
        postalCode: "00000",
        adminArea: "Kigali",
        subAdminArea: "Nyarugenge",
      )..gMapPlaceId = "mock_place_id_${query.hashCode}_2",
    ];

    // Filter results based on query (simple text matching)
    return mockAddresses.where((addr) => 
      addr.featureName!.toLowerCase().contains(query.toLowerCase()) ||
      addr.addressLine!.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Fetch place details (simplified for Firebase-only mode)
  Future<Address> fecthPlaceDetails(Address address) async {
    // For Firebase-only mode, return the address as-is
    return address;
  }
}