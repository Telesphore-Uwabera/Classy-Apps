import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/views/pages/location/map_location_picker.page.dart';

class EnhancedLocationSearch extends StatefulWidget {
  final String label;
  final String? initialValue;
  final Function(String address, LatLng coordinates) onLocationSelected;
  final String? hintText;

  const EnhancedLocationSearch({
    Key? key,
    required this.label,
    this.initialValue,
    required this.onLocationSelected,
    this.hintText,
  }) : super(key: key);

  @override
  _EnhancedLocationSearchState createState() => _EnhancedLocationSearchState();
}

class _EnhancedLocationSearchState extends State<EnhancedLocationSearch> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedAddress = '';
  LatLng? _selectedCoordinates;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialValue ?? '';
    _searchController.text = _selectedAddress;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openLocationSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Open the enhanced map location picker
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => MapLocationPickerPage(
            initialAddress: _selectedAddress,
            initialPosition: _selectedCoordinates,
            title: "Select ${widget.label}",
            hintText: widget.hintText ?? "Search for a place...",
          ),
        ),
      );

      if (result != null) {
        setState(() {
          _selectedAddress = result['address'] ?? '';
          _selectedCoordinates = result['coordinates'];
          _searchController.text = _selectedAddress;
        });
        
        if (_selectedCoordinates != null) {
          widget.onLocationSelected(_selectedAddress, _selectedCoordinates!);
        }
      }
    } catch (e) {
      print('Error opening location search: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open location search: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _openLocationSearch,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedAddress.isEmpty 
                      ? Colors.grey.shade300 
                      : AppColor.primaryColor.withOpacity(0.3),
                  width: _selectedAddress.isEmpty ? 1 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColor.primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _isLoading
                        ? Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Loading...",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedAddress.isEmpty 
                                    ? (widget.hintText ?? "Tap to select location")
                                    : _selectedAddress,
                                style: TextStyle(
                                  color: _selectedAddress.isEmpty 
                                      ? Colors.grey[600] 
                                      : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: _selectedAddress.isEmpty 
                                      ? FontWeight.normal 
                                      : FontWeight.w500,
                                ),
                              ),
                              if (_selectedAddress.isNotEmpty) ...[
                                SizedBox(height: 4),
                                Text(
                                  "Tap to change location",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.map,
                      color: AppColor.primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedCoordinates != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gps_fixed,
                    color: AppColor.primaryColor,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Lat: ${_selectedCoordinates!.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_selectedCoordinates!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: AppColor.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

