import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

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
      // Show a simple dialog for location input
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _LocationSearchDialog(
          hintText: widget.hintText ?? "Search for a place...",
          initialValue: _selectedAddress,
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
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _openLocationSearch,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 20,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Loading...",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          )
                        : Text(
                            _selectedAddress.isEmpty 
                                ? (widget.hintText ?? "Tap to select location")
                                : _selectedAddress,
                            style: TextStyle(
                              color: _selectedAddress.isEmpty 
                                  ? Colors.grey[600] 
                                  : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_selectedCoordinates != null) ...[
            SizedBox(height: 4),
            Text(
              'Lat: ${_selectedCoordinates!.latitude.toStringAsFixed(6)}, '
              'Lng: ${_selectedCoordinates!.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationSearchDialog extends StatefulWidget {
  final String hintText;
  final String initialValue;

  const _LocationSearchDialog({
    required this.hintText,
    required this.initialValue,
  });

  @override
  _LocationSearchDialogState createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<_LocationSearchDialog> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.initialValue;
    // Default to Kampala coordinates
    _latController.text = '0.3476';
    _lngController.text = '32.5825';
  }

  @override
  void dispose() {
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Location'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: widget.hintText,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final address = _addressController.text.trim();
            final lat = double.tryParse(_latController.text.trim());
            final lng = double.tryParse(_lngController.text.trim());
            
            if (address.isNotEmpty && lat != null && lng != null) {
              Navigator.of(context).pop({
                'address': address,
                'coordinates': LatLng(lat, lng),
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter valid address and coordinates'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text('Select'),
        ),
      ],
    );
  }
}
