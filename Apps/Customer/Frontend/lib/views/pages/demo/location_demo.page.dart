import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/enhanced_location_search.dart';
import 'package:Classy/views/pages/location/location_selection.page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/utils/ui_spacer.dart';

class LocationDemoPage extends StatefulWidget {
  const LocationDemoPage({Key? key}) : super(key: key);

  @override
  _LocationDemoPageState createState() => _LocationDemoPageState();
}

class _LocationDemoPageState extends State<LocationDemoPage> {
  String? _fromAddress;
  String? _toAddress;
  LatLng? _fromPosition;
  LatLng? _toPosition;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Location Picker Demo",
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: VStack([
          UiSpacer.verticalSpace(space: 20),
          
          // Header
          VStack([
            "Enhanced Location Picker".tr().text.bold.xl2.make().centered(),
            UiSpacer.verticalSpace(space: 8),
            "Test the new map-based location selection".tr().text.gray600.make().centered(),
          ]).px20(),
          
          UiSpacer.verticalSpace(space: 30),
          
          // Demo Cards
          VStack([
            // Single Location Picker Demo
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: VStack([
                  "Single Location Picker".text.bold.lg.make(),
                  UiSpacer.verticalSpace(space: 8),
                  "Tap to select a location using the map".text.gray600.make(),
                  UiSpacer.verticalSpace(space: 16),
                  EnhancedLocationSearch(
                    label: "Pick a Location",
                    initialValue: _fromAddress,
                    hintText: "Tap to select location on map",
                    onLocationSelected: (address, coordinates) {
                      setState(() {
                        _fromAddress = address;
                        _fromPosition = coordinates;
                      });
                    },
                  ),
                ]),
              ),
            ),
            
            // Location Selection Demo
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: VStack([
                  "Full Location Selection".text.bold.lg.make(),
                  UiSpacer.verticalSpace(space: 8),
                  "Complete pickup and destination selection".text.gray600.make(),
                  UiSpacer.verticalSpace(space: 16),
                  CustomButton(
                    title: "Open Location Selection",
                    color: AppColor.primaryColor,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationSelectionPage(
                            initialFromAddress: _fromAddress,
                            initialToAddress: _toAddress,
                            initialFromPosition: _fromPosition,
                            initialToPosition: _toPosition,
                          ),
                        ),
                      );
                      
                      if (result != null) {
                        setState(() {
                          _fromAddress = result['from']['address'];
                          _fromPosition = result['from']['coordinates'];
                          _toAddress = result['to']['address'];
                          _toPosition = result['to']['coordinates'];
                        });
                      }
                    },
                  ),
                ]),
              ),
            ),
            
            // Results Display
            if (_fromAddress != null || _toAddress != null) ...[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: VStack([
                    "Selected Locations".text.bold.lg.color(Colors.green.shade700).make(),
                    UiSpacer.verticalSpace(space: 12),
                    
                    if (_fromAddress != null) ...[
                      HStack([
                        Icon(Icons.location_on, color: Colors.green.shade600, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: VStack([
                            "From: $_fromAddress".text.color(Colors.green.shade700).make(),
                            if (_fromPosition != null)
                              "Lat: ${_fromPosition!.latitude.toStringAsFixed(6)}, Lng: ${_fromPosition!.longitude.toStringAsFixed(6)}".text.gray600.sm.make(),
                          ]),
                        ),
                      ]),
                      UiSpacer.verticalSpace(space: 8),
                    ],
                    
                    if (_toAddress != null) ...[
                      HStack([
                        Icon(Icons.flag, color: Colors.green.shade600, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: VStack([
                            "To: $_toAddress".text.color(Colors.green.shade700).make(),
                            if (_toPosition != null)
                              "Lat: ${_toPosition!.latitude.toStringAsFixed(6)}, Lng: ${_toPosition!.longitude.toStringAsFixed(6)}".text.gray600.sm.make(),
                          ]),
                        ),
                      ]),
                    ],
                  ]),
                ),
              ),
            ],
          ]),
          
          UiSpacer.verticalSpace(space: 40),
          
          // Features List
          VStack([
            "New Features".text.bold.lg.make().px20(),
            UiSpacer.verticalSpace(space: 16),
            
            _buildFeature(
              icon: Icons.map,
              title: "Interactive Map",
              description: "Tap on the map to select exact locations",
            ),
            
            _buildFeature(
              icon: Icons.search,
              title: "Google Places Search",
              description: "Search for places using Google Places API",
            ),
            
            _buildFeature(
              icon: Icons.gps_fixed,
              title: "GPS Location",
              description: "Get your current location automatically",
            ),
            
            _buildFeature(
              icon: Icons.swap_vert,
              title: "Location Swap",
              description: "Easily swap pickup and destination",
            ),
            
            _buildFeature(
              icon: Icons.home,
              title: "Quick Options",
              description: "Save and use Home, Work, and other frequent locations",
            ),
          ]),
          
          UiSpacer.verticalSpace(space: 40),
        ]),
      ),
    );
  }
  
  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColor.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
