import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/services/enhanced_google_maps.service.dart';
import 'package:Classy/models/delivery_address.dart';
import 'package:Classy/widgets/enhanced_location_search.dart';
import 'package:velocity_x/velocity_x.dart';

class EnhancedGoogleMapWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final double initialZoom;
  final bool showSearchBar;
  final bool showNavigationControls;
  final Function(DeliveryAddress)? onLocationSelected;
  final Function(LatLng, LatLng)? onRouteSet;
  final Function(String)? onNavigationUpdate;
  final bool enableNavigation;
  final DeliveryAddress? pickupLocation;
  final DeliveryAddress? destinationLocation;

  const EnhancedGoogleMapWidget({
    Key? key,
    this.initialPosition,
    this.initialZoom = 15.0,
    this.showSearchBar = true,
    this.showNavigationControls = true,
    this.onLocationSelected,
    this.onRouteSet,
    this.onNavigationUpdate,
    this.enableNavigation = false,
    this.pickupLocation,
    this.destinationLocation,
  }) : super(key: key);

  @override
  State<EnhancedGoogleMapWidget> createState() => _EnhancedGoogleMapWidgetState();
}

class _EnhancedGoogleMapWidgetState extends State<EnhancedGoogleMapWidget> {
  final EnhancedGoogleMapsService _mapsService = EnhancedGoogleMapsService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isSearching = false;
  List<DeliveryAddress> _searchResults = [];
  String _navigationStatus = '';
  String _navigationInstruction = '';
  double _remainingDistance = 0;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupMapsService();
  }

  void _setupMapsService() {
    _mapsService.onLocationUpdate = (location) {
      setState(() {});
    };

    _mapsService.onRouteUpdate = (status) {
      setState(() {
        _navigationStatus = status;
      });
    };

    _mapsService.onDistanceUpdate = (distance) {
      setState(() {
        _remainingDistance = distance;
      });
    };

    _mapsService.onTimeUpdate = (time) {
      setState(() {
        _remainingTime = time;
      });
    };

    _mapsService.onNavigationInstruction = (instruction) {
      setState(() {
        _navigationInstruction = instruction;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition ?? const LatLng(0.0, 0.0),
            zoom: widget.initialZoom,
          ),
          onMapCreated: _mapsService.initializeMap,
          markers: _mapsService.markers,
          polylines: _mapsService.polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          onTap: _onMapTapped,
        ),

        // Search Bar
        if (widget.showSearchBar)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

        // Navigation Controls
        if (widget.showNavigationControls && widget.enableNavigation)
          Positioned(
            bottom: 100,
            right: 16,
            child: _buildNavigationControls(),
          ),

        // Navigation Status Panel
        if (_mapsService.isNavigating)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildNavigationPanel(),
          ),

        // Route Summary Panel
        if (_mapsService.routePoints.isNotEmpty && !_mapsService.isNavigating)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildRouteSummaryPanel(),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for places...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults.clear();
                    });
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: 'start_navigation',
          onPressed: _mapsService.routePoints.isNotEmpty && !_mapsService.isNavigating
              ? _startNavigation
              : null,
          child: const Icon(Icons.navigation),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'stop_navigation',
          onPressed: _mapsService.isNavigating ? _stopNavigation : null,
          backgroundColor: Colors.red,
          child: const Icon(Icons.stop),
        ),
      ],
    );
  }

  Widget _buildNavigationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_remainingDistance.toStringAsFixed(1)} km',
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

  Widget _buildRouteSummaryPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.route, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Route Ready',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _startNavigation,
                child: const Text('Start Navigation'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_remainingDistance.toStringAsFixed(1)} km',
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

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _mapsService.searchPlaces(query);
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _onMapTapped(LatLng position) {
    // Handle map tap for location selection
    if (widget.onLocationSelected != null) {
      _selectLocationAtPosition(position);
    }
  }

  Future<void> _selectLocationAtPosition(LatLng position) async {
    final address = await _mapsService.getCurrentLocationAddress();
    if (address != null && widget.onLocationSelected != null) {
      widget.onLocationSelected!(address);
    }
  }

  void _startNavigation() {
    _mapsService.startNavigation();
    setState(() {});
  }

  void _stopNavigation() {
    _mapsService.stopNavigation();
    setState(() {});
  }

  // Public methods for external control
  void setRoute({
    required LatLng pickup,
    required LatLng destination,
    String? pickupAddress,
    String? destinationAddress,
  }) {
    _mapsService.setRoute(
      pickup: pickup,
      destination: destination,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
    );
    setState(() {});
  }

  void clearRoute() {
    _mapsService._clearRoute();
    setState(() {});
  }

  @override
  void dispose() {
    _mapsService.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
