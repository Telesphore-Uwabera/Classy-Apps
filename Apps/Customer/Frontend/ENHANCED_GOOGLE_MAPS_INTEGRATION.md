# Enhanced Google Maps Integration Guide

This guide explains how to integrate the enhanced Google Maps functionality that works like the screenshot you shared, with full navigation capabilities and booking system integration.

## 🗺️ Overview

The enhanced Google Maps system provides:
- **Real-time navigation** with turn-by-turn directions
- **Route planning** with multiple waypoints
- **Live location tracking** for drivers and customers
- **Seamless booking integration** with all services
- **Google Maps-like UI** with search, navigation controls, and status panels

## 📁 New Files Created

### Core Services
- `lib/services/enhanced_google_maps.service.dart` - Main Google Maps service
- `lib/services/booking_navigation.service.dart` - Booking system integration
- `lib/services/enhanced_navigation_integration.service.dart` - Unified integration service

### UI Components
- `lib/widgets/enhanced_google_map.widget.dart` - Enhanced map widget
- `lib/views/pages/taxi/enhanced_taxi_booking.page.dart` - Taxi booking with maps
- `lib/views/pages/parcel/enhanced_parcel_delivery.page.dart` - Parcel delivery with maps

## 🚀 Quick Start

### 1. Basic Map Integration

```dart
import 'package:Classy/widgets/enhanced_google_map.widget.dart';

class MyMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EnhancedGoogleMapWidget(
        initialPosition: LatLng(0.3476, 32.5825), // Kampala
        showSearchBar: true,
        showNavigationControls: true,
        enableNavigation: true,
        onLocationSelected: (location) {
          print('Location selected: ${location.address}');
        },
        onRouteSet: (pickup, destination) {
          print('Route set from $pickup to $destination');
        },
      ),
    );
  }
}
```

### 2. Booking Integration

```dart
import 'package:Classy/services/enhanced_navigation_integration.service.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final EnhancedNavigationIntegrationService _navService = 
      EnhancedNavigationIntegrationService();

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  void _setupNavigation() {
    _navService.onStatusUpdate = (status) {
      setState(() {
        // Update UI with navigation status
      });
    };

    _navService.onLocationUpdate = (location) {
      // Handle location updates
    };

    _navService.onDistanceUpdate = (distance) {
      // Update distance display
    };

    _navService.onTimeUpdate = (time) {
      // Update time estimate
    };
  }

  Future<void> _createBooking() async {
    final booking = await _navService.createBookingWithRoute(
      customerId: 'user123',
      pickupLocation: DeliveryAddress(
        address: 'Kampala Central',
        latitude: 0.3476,
        longitude: 32.5825,
      ),
      destinationLocation: DeliveryAddress(
        address: 'Entebbe Airport',
        latitude: 0.0474,
        longitude: 32.4605,
      ),
      serviceType: 'taxi',
      serviceOptions: {
        'vehicle_type': 'standard',
        'payment_method': 'cash',
      },
    );
  }
}
```

## 🎯 Key Features

### 1. Google Maps-like Navigation
- **Route Planning**: Automatic route calculation between pickup and destination
- **Turn-by-turn Directions**: Real-time navigation instructions
- **Live Tracking**: Real-time location updates for drivers and customers
- **Traffic Awareness**: Route optimization based on traffic conditions

### 2. Enhanced Search
- **Place Search**: Search for addresses, businesses, and landmarks
- **Auto-complete**: Smart suggestions as you type
- **Location Picker**: Interactive map for precise location selection
- **Recent Locations**: Quick access to frequently used addresses

### 3. Booking Integration
- **Real-time Booking**: Instant booking with live driver matching
- **Route Estimation**: Accurate distance, time, and fare calculations
- **Status Tracking**: Live order status updates
- **Driver Communication**: Built-in chat and calling features

## 🔧 Configuration

### 1. Google Maps API Key
Ensure your `AppStrings.googleMapApiKey` is properly configured:

```dart
// In lib/constants/app_strings.dart
class AppStrings {
  static const String googleMapApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
}
```

### 2. Firebase Configuration
The system uses Firebase for real-time data:

```dart
// Collections used:
// - orders: Booking and order management
// - driver_locations: Real-time driver tracking
// - notifications: Push notifications
// - users: User profiles and preferences
```

### 3. Permissions
Add required permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

## 📱 Usage Examples

### 1. Taxi Booking with Navigation

```dart
class TaxiBookingPage extends StatefulWidget {
  @override
  _TaxiBookingPageState createState() => _TaxiBookingPageState();
}

class _TaxiBookingPageState extends State<TaxiBookingPage> {
  final EnhancedNavigationIntegrationService _navService = 
      EnhancedNavigationIntegrationService();
  
  DeliveryAddress? _pickupLocation;
  DeliveryAddress? _destinationLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Location selection
          EnhancedLocationSearch(
            label: 'Pickup Location',
            onLocationSelected: (address, coordinates) {
              setState(() {
                _pickupLocation = DeliveryAddress(
                  address: address,
                  latitude: coordinates.latitude,
                  longitude: coordinates.longitude,
                );
              });
            },
          ),
          
          // Enhanced map
          Expanded(
            child: EnhancedGoogleMapWidget(
              pickupLocation: _pickupLocation,
              destinationLocation: _destinationLocation,
              onRouteSet: (pickup, destination) {
                _calculateFare();
              },
            ),
          ),
          
          // Booking controls
          if (_pickupLocation != null && _destinationLocation != null)
            _buildBookingControls(),
        ],
      ),
    );
  }

  Widget _buildBookingControls() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Route summary
          _buildRouteSummary(),
          
          // Vehicle selection
          _buildVehicleSelection(),
          
          // Book button
          ElevatedButton(
            onPressed: _bookRide,
            child: Text('Book Ride'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookRide() async {
    final booking = await _navService.createBookingWithRoute(
      customerId: 'current_user_id',
      pickupLocation: _pickupLocation!,
      destinationLocation: _destinationLocation!,
      serviceType: 'taxi',
    );
    
    // Start navigation
    await _navService.startNavigationForOrder(Order.fromJson(booking));
  }
}
```

### 2. Parcel Delivery with Tracking

```dart
class ParcelDeliveryPage extends StatefulWidget {
  @override
  _ParcelDeliveryPageState createState() => _ParcelDeliveryPageState();
}

class _ParcelDeliveryPageState extends State<ParcelDeliveryPage> {
  final EnhancedNavigationIntegrationService _navService = 
      EnhancedNavigationIntegrationService();
  
  String _packageType = 'Document';
  String _deliveryType = 'Standard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Package details
          _buildPackageDetails(),
          
          // Location selection
          _buildLocationSelection(),
          
          // Enhanced map
          Expanded(
            child: EnhancedGoogleMapWidget(
              onRouteSet: (pickup, destination) {
                _calculateDeliveryCost();
              },
            ),
          ),
          
          // Delivery controls
          _buildDeliveryControls(),
        ],
      ),
    );
  }

  Future<void> _bookDelivery() async {
    final booking = await _navService.createBookingWithRoute(
      customerId: 'current_user_id',
      pickupLocation: _pickupLocation!,
      destinationLocation: _destinationLocation!,
      serviceType: 'parcel',
      serviceOptions: {
        'package_type': _packageType,
        'delivery_type': _deliveryType,
        'weight': _packageWeight,
      },
    );
    
    // Start tracking
    await _navService.startNavigationForOrder(Order.fromJson(booking));
  }
}
```

## 🎨 UI Components

### 1. Enhanced Map Widget
```dart
EnhancedGoogleMapWidget(
  initialPosition: LatLng(0.3476, 32.5825),
  showSearchBar: true,
  showNavigationControls: true,
  enableNavigation: true,
  onLocationSelected: (location) => print('Selected: ${location.address}'),
  onRouteSet: (pickup, destination) => print('Route set'),
  onNavigationUpdate: (status) => print('Status: $status'),
)
```

### 2. Location Search Widget
```dart
EnhancedLocationSearch(
  label: 'Pickup Location',
  hintText: 'Where are you now?',
  onLocationSelected: (address, coordinates) {
    // Handle location selection
  },
)
```

## 🔄 Real-time Features

### 1. Live Location Tracking
```dart
_navService.onLocationUpdate = (location) {
  // Update driver location on map
  _updateDriverMarker(location);
};
```

### 2. Order Status Updates
```dart
_navService.onOrderUpdate = (order) {
  // Update order status in UI
  _updateOrderStatus(order.status);
};
```

### 3. Navigation Instructions
```dart
_navService.onNavigationInstruction = (instruction) {
  // Show turn-by-turn directions
  _showNavigationInstruction(instruction);
};
```

## 📊 Data Flow

1. **User selects locations** → Enhanced location search
2. **Route calculation** → Google Maps Directions API
3. **Booking creation** → Firebase database
4. **Driver matching** → Real-time driver search
5. **Navigation start** → Live tracking and updates
6. **Order completion** → Status updates and notifications

## 🚨 Error Handling

```dart
try {
  await _navService.createBookingWithRoute(...);
} catch (e) {
  if (e.toString().contains('network')) {
    _showError('Please check your internet connection');
  } else if (e.toString().contains('location')) {
    _showError('Location services are disabled');
  } else {
    _showError('Booking failed: $e');
  }
}
```

## 🔧 Customization

### 1. Map Styling
```dart
// Custom map style
_mapsService.setGoogleMapStyle(customMapStyle);
```

### 2. Navigation Options
```dart
// Custom navigation settings
_mapsService.setNavigationOptions({
  'voice_guidance': true,
  'traffic_aware': true,
  'avoid_tolls': false,
});
```

### 3. Booking Options
```dart
// Custom booking parameters
_navService.createBookingWithRoute(
  // ... other parameters
  serviceOptions: {
    'vehicle_type': 'premium',
    'payment_method': 'card',
    'scheduled_time': DateTime.now().add(Duration(hours: 1)),
  },
);
```

## 📱 Platform Support

- ✅ **Android**: Full support with native Google Maps
- ✅ **iOS**: Full support with native Google Maps  
- ✅ **Web**: Full support with Google Maps JavaScript API
- ✅ **Real-time**: Firebase integration for live updates

## 🎯 Benefits

1. **Google Maps-like Experience**: Familiar navigation interface
2. **Real-time Integration**: Live tracking and updates
3. **Seamless Booking**: Integrated booking system
4. **Cross-platform**: Works on all platforms
5. **Scalable**: Easy to extend with new features

This enhanced Google Maps integration provides a professional, Google Maps-like experience with full booking system integration, making your app competitive with major ride-sharing and delivery platforms! 🚀
