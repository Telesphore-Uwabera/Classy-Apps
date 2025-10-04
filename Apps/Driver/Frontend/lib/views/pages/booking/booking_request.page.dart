import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/base.page.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../models/booking.dart' as booking_model;
import '../../../utils/ui_spacer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingRequestDetailsPage extends StatefulWidget {
  final booking_model.BookingRequest bookingRequest;

  const BookingRequestDetailsPage({
    Key? key,
    required this.bookingRequest,
  }) : super(key: key);

  @override
  _BookingRequestDetailsPageState createState() => _BookingRequestDetailsPageState();
}

class _BookingRequestDetailsPageState extends State<BookingRequestDetailsPage> {
  bool _isLoading = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMapMarkers();
  }

  void _setupMapMarkers() {
    setState(() {
      _markers = {
        // Pickup location marker
        Marker(
          markerId: MarkerId('pickup'),
          position: LatLng(
            widget.bookingRequest.pickupLatitude,
            widget.bookingRequest.pickupLongitude,
          ),
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: widget.bookingRequest.pickupAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        // Destination marker
        Marker(
          markerId: MarkerId('destination'),
          position: LatLng(
            widget.bookingRequest.destinationLatitude,
            widget.bookingRequest.destinationLongitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: widget.bookingRequest.destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  Future<void> _acceptBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement booking acceptance API call
      await Future.delayed(Duration(seconds: 2)); // Simulate API call
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to trip tracking page
      Navigator.of(context).pop(true);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _declineBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement booking decline API call
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking declined'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Navigate back
      Navigator.of(context).pop(false);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to decline booking: $e'),
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
    return BasePage(
      appBar: AppBar(
        title: Text("New Booking Request"),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: VStack([
          UiSpacer.verticalSpace(space: 20),
          
          // Booking Request Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
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
                // Header
                HStack([
                  Icon(Icons.local_taxi, color: AppColor.primaryColor, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: VStack([
                      "New Booking Request".text.bold.xl.make(),
                      "Tap to accept or decline".text.gray600.make(),
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: "NEW".text.color(Colors.orange).bold.sm.make(),
                  ),
                ]),
                
                UiSpacer.verticalSpace(space: 20),
                
                // Customer Info
                _buildInfoSection(
                  title: "Customer Information",
                  icon: Icons.person,
                  items: [
                    _buildInfoItem("Name", widget.bookingRequest.customerName),
                    _buildInfoItem("Phone", widget.bookingRequest.customerPhone),
                    _buildInfoItem("Rating", "${widget.bookingRequest.customerRating}/5.0"),
                  ],
                ),
                
                UiSpacer.verticalSpace(space: 16),
                
                // Trip Details
                _buildInfoSection(
                  title: "Trip Details",
                  icon: Icons.route,
                  items: [
                    _buildInfoItem("Service", widget.bookingRequest.serviceType.toUpperCase()),
                    _buildInfoItem("Distance", "${widget.bookingRequest.distance} km"),
                    _buildInfoItem("Duration", "${widget.bookingRequest.estimatedDuration} min"),
                    _buildInfoItem("Fare", "UGX ${widget.bookingRequest.estimatedFare}"),
                  ],
                ),
                
                UiSpacer.verticalSpace(space: 16),
                
                // Location Details
                _buildInfoSection(
                  title: "Location Details",
                  icon: Icons.location_on,
                  items: [
                    _buildInfoItem("Pickup", widget.bookingRequest.pickupAddress),
                    _buildInfoItem("Destination", widget.bookingRequest.destinationAddress),
                  ],
                ),
              ]),
            ),
          ),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Map Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 300,
            decoration: BoxDecoration(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.bookingRequest.pickupLatitude,
                    widget.bookingRequest.pickupLongitude,
                  ),
                  zoom: 13,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          
          UiSpacer.verticalSpace(space: 30),
          
          // Action Buttons
          VStack([
            // Accept Button
            CustomButton(
              title: "Accept Booking",
              color: Colors.green,
              onPressed: _acceptBooking,
              loading: _isLoading,
            ).wFull(context).px20(),
            
            UiSpacer.verticalSpace(space: 12),
            
            // Decline Button
            CustomButton(
              title: "Decline",
              color: Colors.red,
              onPressed: _declineBooking,
              loading: _isLoading,
            ).wFull(context).px20(),
          ]),
          
          UiSpacer.verticalSpace(space: 20),
        ]),
      ),
    );
  }
  
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: VStack([
        HStack([
          Icon(icon, color: AppColor.primaryColor, size: 20),
          SizedBox(width: 8),
          title.text.bold.lg.color(AppColor.primaryColor).make(),
        ]),
        UiSpacer.verticalSpace(space: 12),
        ...items,
      ]),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: HStack([
        Expanded(
          flex: 2,
          child: label.text.gray600.sm.make(),
        ),
        Expanded(
          flex: 3,
          child: value.text.bold.make(),
        ),
      ]),
    );
  }
}

// Booking Request Model
class BookingRequest {
  final String id;
  final String customerName;
  final String customerPhone;
  final double customerRating;
  final String serviceType;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final double distance;
  final int estimatedDuration;
  final int estimatedFare;
  final DateTime requestTime;

  BookingRequest({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerRating,
    required this.serviceType,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.distance,
    required this.estimatedDuration,
    required this.estimatedFare,
    required this.requestTime,
  });
}
