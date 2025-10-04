import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/services/simple_location.service.dart';
import 'package:Classy/models/address.dart';

class MapLocationPickerPage extends StatefulWidget {
  final String? initialAddress;
  final LatLng? initialPosition;
  final String title;
  final String hintText;

  const MapLocationPickerPage({
    Key? key,
    this.initialAddress,
    this.initialPosition,
    this.title = "Select Location",
    this.hintText = "Search for a place...",
  }) : super(key: key);

  @override
  _MapLocationPickerPageState createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String? _selectedAddress;
  bool _isLoading = false;
  Set<Marker> _markers = {};
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _selectedAddress = widget.initialAddress;
    _searchController.text = _selectedAddress ?? '';
    _updateMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateMarkers() {
    setState(() {
      _markers = _selectedPosition != null
          ? {
              Marker(
                markerId: MarkerId('selected_location'),
                position: _selectedPosition!,
                infoWindow: InfoWindow(
                  title: _selectedAddress ?? 'Selected Location',
                  snippet: 'Tap to confirm this location',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            }
          : {};
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _updateMarkers();
    _getAddressFromCoordinates(position);
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final address = await SimpleLocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (address != null) {
        setState(() {
          _selectedAddress = address.addressLine ?? 'Unknown Address';
          _searchController.text = _selectedAddress!;
        });
        _updateMarkers();
      }
    } catch (e) {
      print('Error getting address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get address for this location'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await SimpleLocationService.getCurrentLocation();
      if (position != null) {
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _selectedPosition = latLng;
        });
        _updateMarkers();
        _getAddressFromCoordinates(latLng);
        
        // Move camera to current location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 15),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get current location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get current location'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openPlacePicker() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlacePicker(
            apiKey: AppStrings.googleMapApiKey,
            autocompleteLanguage: translator.activeLocale?.languageCode ?? "en",
            region: "UG", // Uganda
            onPlacePicked: (result) {
              Navigator.of(context).pop(result);
            },
            initialPosition: _selectedPosition ?? LatLng(0.3476, 32.5825), // Kampala
            useCurrentLocation: true,
            resizeToAvoidBottomInset: true,
          ),
        ),
      );

      if (result != null) {
        setState(() {
          _selectedPosition = result.geometry?.location;
          _selectedAddress = result.formattedAddress;
          _searchController.text = _selectedAddress ?? '';
        });
        _updateMarkers();
        
        // Move camera to selected location
        if (_selectedPosition != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedPosition!, 15),
          );
        }
      }
    } catch (e) {
      print('Error with place picker: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open place picker'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmLocation() {
    if (_selectedPosition != null && _selectedAddress != null) {
      Navigator.of(context).pop({
        'address': _selectedAddress,
        'coordinates': _selectedPosition,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: widget.title,
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: Icon(Icons.search, color: AppColor.primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(Icons.my_location, color: AppColor.primaryColor),
                  onPressed: _getCurrentLocation,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onTap: _openPlacePicker,
              readOnly: true,
            ),
          ),

          // Map
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedPosition ?? LatLng(0.3476, 32.5825), // Kampala
                    zoom: 15,
                  ),
                  onTap: _onMapTap,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
          ),

          // Selected Location Info
          if (_selectedAddress != null) ...[
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColor.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _selectedAddress!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        if (_selectedPosition != null) ...[
                          SizedBox(height: 4),
                          Text(
                            'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, '
                            'Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: "Cancel",
                    color: Colors.grey,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    title: "Confirm Location",
                    color: AppColor.primaryColor,
                    onPressed: _confirmLocation,
                    loading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
