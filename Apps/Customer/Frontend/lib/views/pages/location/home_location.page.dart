import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/location_preferences.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:Classy/services/location.service.dart';
import 'package:Classy/services/web_location.service.dart';
import 'package:Classy/widgets/location_permission_helper.dart';

class HomeLocationPage extends StatefulWidget {
  const HomeLocationPage({super.key});

  @override
  _HomeLocationPageState createState() => _HomeLocationPageState();
}

class _HomeLocationPageState extends State<HomeLocationPage> {
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _currentHomeAddress;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentHomeAddress();
  }

  @override
  void dispose() {
    _homeAddressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadCurrentHomeAddress() async {
    final address = await LocationPreferencesService().getFormattedHomeAddress();
    setState(() {
      _currentHomeAddress = address;
    });
  }

  void _saveHomeAddress() async {
    if (_homeAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Please enter a home address".text.white.make(),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await LocationPreferencesService().setHomeAddress(_homeAddressController.text.trim());
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "Home address saved successfully!".text.white.make(),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "Failed to save home address".text.white.make(),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Error saving home address: $e".text.white.make(),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectOnMap() async {
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlacePicker(
            apiKey: "AIzaSyDUZsmIAdmseLvCaQhyZlGHr6YU6HGITJk",
            onPlacePicked: (result) {
              _homeAddressController.text = result.formattedAddress ?? "Selected Address";
              Navigator.of(context).pop();
            },
            initialPosition: LatLng(0.3476, 32.5825), // Kampala coordinates
            useCurrentLocation: true,
            resizeToAvoidBottomInset: true,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Error opening map: $e".text.white.make(),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _useCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For web, use improved web location service
      if (kIsWeb) {
        // First check if location service is enabled
        final isEnabled = await WebLocationService.isLocationServiceEnabled();
        if (!isEnabled) {
          throw Exception('Location services are disabled. Please enable location services in your browser.');
        }

        // Request permission if needed
        final hasPermission = await WebLocationService.requestLocationPermission();
        if (!hasPermission) {
          throw Exception('Location permission denied. Please allow location access in your browser settings.');
        }

        // Get current address with better error handling
        final address = await WebLocationService.getCurrentAddress(
          timeout: Duration(seconds: 15),
        );
        
        if (address != null && address.isNotEmpty) {
          _homeAddressController.text = address;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: "Location detected successfully!".text.white.make(),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Unable to get address from current location');
        }
      } else {
        // For mobile, use the existing location service
        await LocationService.prepareLocationListener(true);
        await Future.delayed(Duration(seconds: 2));
        
        final currentAddress = LocationService.currenctAddress;
        if (currentAddress != null) {
          final addressText = currentAddress.addressLine ?? currentAddress.featureName ?? "Current Location";
          _homeAddressController.text = addressText;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: "Location detected successfully!".text.white.make(),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Unable to detect current location');
        }
      }
    } catch (e) {
      print('Location error: $e');
      
      if (e.toString().contains('permission')) {
        LocationPermissionHelper.showLocationPermissionDialog(
          context,
          onRetry: () => _useCurrentLocation(),
          onUseMap: () => _selectOnMap(),
        );
      } else if (e.toString().contains('disabled')) {
        LocationPermissionHelper.showLocationDisabledDialog(
          context,
          onUseMap: () => _selectOnMap(),
        );
      } else if (e.toString().contains('timeout')) {
        LocationPermissionHelper.showLocationTimeoutDialog(
          context,
          onRetry: () => _useCurrentLocation(),
          onUseMap: () => _selectOnMap(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "Location detection failed. Please use 'Select on Map' instead.".text.white.make(),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Home Address",
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: VStack([
          // Current Address Display
          if (_currentHomeAddress != null && _currentHomeAddress != "Not set") ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: VStack([
                HStack([
                  Icon(Icons.home, color: Colors.green.shade600, size: 20),
                  UiSpacer.horizontalSpace(space: 8),
                  "Current Home Address".text.bold.color(Colors.green.shade700).make(),
                ]),
                UiSpacer.verticalSpace(space: 8),
                _currentHomeAddress!.text.color(Colors.green.shade600).make(),
              ]),
            ),
            UiSpacer.verticalSpace(space: 20),
          ],

          // Address Input Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: VStack([
              // Title
              "Set Your Home Address".text.bold.xl2.color(AppColor.primaryColor).make(),
              UiSpacer.verticalSpace(space: 8),
              "This will be used as your default home address for deliveries and rides.".text.gray600.make(),
              
              UiSpacer.verticalSpace(space: 24),
              
              // Address Input Field
              TextField(
                controller: _homeAddressController,
                decoration: InputDecoration(
                  labelText: "Home Address",
                  hintText: "Enter your home address",
                  prefixIcon: Icon(Icons.home, color: AppColor.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
                  ),
                ),
                maxLines: 2,
              ),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Action Buttons
              VStack([
                // Use Current Location Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _useCurrentLocation,
                    icon: _isLoading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.my_location, color: Colors.white),
                    label: Text(_isLoading ? "Detecting..." : "Use Current Location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                UiSpacer.verticalSpace(space: 12),
                
                // Select on Map Button
                Container(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _selectOnMap,
                    icon: Icon(Icons.map, color: AppColor.primaryColor),
                    label: Text("Select on Map"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primaryColor,
                      side: BorderSide(color: AppColor.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ]),
              
              UiSpacer.verticalSpace(space: 24),
              
              // Save Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveHomeAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            UiSpacer.horizontalSpace(space: 12),
                            "Saving...".text.white.bold.make(),
                          ],
                        )
                      : "Save Home Address".text.white.bold.make(),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
