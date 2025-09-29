import 'package:flutter/material.dart';
import 'package:Classy/services/simple_location.service.dart';
import 'package:Classy/models/address.dart';

/// Simple location picker using only Google APIs
/// No backend dependencies, no complex over-engineering
class SimpleLocationPicker extends StatefulWidget {
  final Function(Address) onLocationSelected;
  final String? initialLocation;

  const SimpleLocationPicker({
    Key? key,
    required this.onLocationSelected,
    this.initialLocation,
  }) : super(key: key);

  @override
  _SimpleLocationPickerState createState() => _SimpleLocationPickerState();
}

class _SimpleLocationPickerState extends State<SimpleLocationPicker> {
  bool _isLoading = false;
  String _currentLocation = "Tap to get current location";
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _currentLocation = widget.initialLocation!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Location",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          
          // Current location display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentLocation,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Get current location button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: Icon(Icons.my_location),
              label: Text("Get Current Location"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          SizedBox(height: 12),
          
          // Manual location entry
          TextField(
            decoration: InputDecoration(
              labelText: "Or enter location manually",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _currentLocation = value;
              });
            },
          ),
          
          SizedBox(height: 20),
          
          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAddress != null ? _confirmLocation : null,
              child: Text("Confirm Location"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check permission first
      bool hasPermission = await SimpleLocationService.hasLocationPermission();
      if (!hasPermission) {
        hasPermission = await SimpleLocationService.requestLocationPermission();
        if (!hasPermission) {
          _showError("Location permission is required");
          return;
        }
      }

      // Get current address
      Address? address = await SimpleLocationService.getCurrentAddress();
      
      if (address != null) {
        setState(() {
          _currentLocation = address.addressLine ?? "Current Location";
          _selectedAddress = address;
        });
      } else {
        _showError("Could not get current location");
      }
    } catch (e) {
      _showError("Error getting location: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmLocation() {
    if (_selectedAddress != null) {
      widget.onLocationSelected(_selectedAddress!);
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
