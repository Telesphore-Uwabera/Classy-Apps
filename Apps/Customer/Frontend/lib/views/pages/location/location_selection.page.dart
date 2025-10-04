import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/enhanced_location_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/utils/ui_spacer.dart';

class LocationSelectionPage extends StatefulWidget {
  final String? initialFromAddress;
  final String? initialToAddress;
  final LatLng? initialFromPosition;
  final LatLng? initialToPosition;

  const LocationSelectionPage({
    Key? key,
    this.initialFromAddress,
    this.initialToAddress,
    this.initialFromPosition,
    this.initialToPosition,
  }) : super(key: key);

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  String? _fromAddress;
  String? _toAddress;
  LatLng? _fromPosition;
  LatLng? _toPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fromAddress = widget.initialFromAddress;
    _toAddress = widget.initialToAddress;
    _fromPosition = widget.initialFromPosition;
    _toPosition = widget.initialToPosition;
  }

  void _onFromLocationSelected(String address, LatLng coordinates) {
    setState(() {
      _fromAddress = address;
      _fromPosition = coordinates;
    });
  }

  void _onToLocationSelected(String address, LatLng coordinates) {
    setState(() {
      _toAddress = address;
      _toPosition = coordinates;
    });
  }

  void _swapLocations() {
    setState(() {
      final tempAddress = _fromAddress;
      final tempPosition = _fromPosition;
      
      _fromAddress = _toAddress;
      _fromPosition = _toPosition;
      
      _toAddress = tempAddress;
      _toPosition = tempPosition;
    });
  }

  void _confirmLocations() {
    if (_fromAddress != null && _toAddress != null && 
        _fromPosition != null && _toPosition != null) {
      Navigator.of(context).pop({
        'from': {
          'address': _fromAddress,
          'coordinates': _fromPosition,
        },
        'to': {
          'address': _toAddress,
          'coordinates': _toPosition,
        },
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both pickup and destination locations'),
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
      title: "Select Locations",
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: VStack([
          UiSpacer.verticalSpace(space: 20),
          
          // Header
          VStack([
            "Where would you like to go?".tr().text.bold.xl2.make().centered(),
            UiSpacer.verticalSpace(space: 8),
            "Select your pickup and destination locations".tr().text.gray600.make().centered(),
          ]).px20(),
          
          UiSpacer.verticalSpace(space: 30),
          
          // Location Selection Cards
          VStack([
            // From Location
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
              child: EnhancedLocationSearch(
                label: "Pickup Location",
                initialValue: _fromAddress,
                hintText: "Where should we pick you up?",
                onLocationSelected: _onFromLocationSelected,
              ),
            ),
            
            // Swap Button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: HStack([
                Spacer(),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_vert,
                    color: AppColor.primaryColor,
                    size: 24,
                  ),
                ).onTap(_swapLocations),
                Spacer(),
              ]),
            ),
            
            // To Location
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
              child: EnhancedLocationSearch(
                label: "Destination",
                initialValue: _toAddress,
                hintText: "Where are you going?",
                onLocationSelected: _onToLocationSelected,
              ),
            ),
          ]),
          
          UiSpacer.verticalSpace(space: 40),
          
          // Quick Options
          VStack([
            "Quick Options".tr().text.bold.lg.make().px20(),
            UiSpacer.verticalSpace(space: 16),
            
            // Home
            if (_fromAddress != null) ...[
              _buildQuickOption(
                icon: Icons.home,
                title: "Home",
                subtitle: "Set as pickup location",
                onTap: () {
                  setState(() {
                    _fromAddress = "Home";
                    // You can set actual home coordinates here
                  });
                },
              ),
            ],
            
            // Work
            if (_toAddress != null) ...[
              _buildQuickOption(
                icon: Icons.work,
                title: "Work",
                subtitle: "Set as destination",
                onTap: () {
                  setState(() {
                    _toAddress = "Work";
                    // You can set actual work coordinates here
                  });
                },
              ),
            ],
            
            // Current Location
            _buildQuickOption(
              icon: Icons.my_location,
              title: "Current Location",
              subtitle: "Use GPS location",
              onTap: () {
                // Implement GPS location fetching
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Getting current location...'),
                    backgroundColor: AppColor.primaryColor,
                  ),
                );
              },
            ),
          ]),
          
          UiSpacer.verticalSpace(space: 40),
          
          // Action Buttons
          VStack([
            // Cancel Button
            CustomButton(
              title: "Cancel",
              color: Colors.grey,
              onPressed: () => Navigator.of(context).pop(),
            ).wFull(context).px20(),
            
            UiSpacer.verticalSpace(space: 12),
            
            // Confirm Button
            CustomButton(
              title: "Confirm Locations",
              color: AppColor.primaryColor,
              onPressed: _confirmLocations,
              loading: _isLoading,
            ).wFull(context).px20(),
          ]),
          
          UiSpacer.verticalSpace(space: 20),
        ]),
      ),
    );
  }
  
  Widget _buildQuickOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
