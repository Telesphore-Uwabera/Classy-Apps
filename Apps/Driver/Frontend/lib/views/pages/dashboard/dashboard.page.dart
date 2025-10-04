import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/base.page.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../booking/booking_request.page.dart';
import '../../../models/booking.dart' as booking_model;
import '../../../utils/ui_spacer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isOnline = false;
  List<booking_model.BookingRequest> _pendingBookings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingBookings();
  }

  Future<void> _loadPendingBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load real booking requests from API
      // For demo purposes, create sample booking requests
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _pendingBookings = [
          booking_model.BookingRequest(
            id: '1',
            customerName: 'John Doe',
            customerPhone: '+256700123456',
            customerRating: 4.8,
            serviceType: 'taxi',
            pickupAddress: 'Kampala Road, Kampala',
            pickupLatitude: 0.3476,
            pickupLongitude: 32.5825,
            destinationAddress: 'Entebbe Airport, Entebbe',
            destinationLatitude: 0.0474,
            destinationLongitude: 32.4600,
            distance: 42.5,
            estimatedDuration: 45,
            estimatedFare: 45000,
            requestTime: DateTime.now(),
          ),
          booking_model.BookingRequest(
            id: '2',
            customerName: 'Jane Smith',
            customerPhone: '+256700789012',
            customerRating: 4.9,
            serviceType: 'boda',
            pickupAddress: 'Makerere University, Kampala',
            pickupLatitude: 0.3384,
            pickupLongitude: 32.5674,
            destinationAddress: 'Garden City Mall, Kampala',
            destinationLatitude: 0.3163,
            destinationLongitude: 32.5822,
            distance: 8.2,
            estimatedDuration: 15,
            estimatedFare: 8000,
            requestTime: DateTime.now().subtract(Duration(minutes: 5)),
          ),
        ];
      });
    } catch (e) {
      print('Error loading bookings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'You are now online' : 'You are now offline'),
        backgroundColor: _isOnline ? Colors.green : Colors.orange,
      ),
    );
  }

  void _openBookingRequest(booking_model.BookingRequest booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingRequestDetailsPage(bookingRequest: booking),
      ),
    ).then((accepted) {
      if (accepted == true) {
        // Remove accepted booking from list
        setState(() {
          _pendingBookings.removeWhere((b) => b.id == booking.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: AppBar(
        title: Text("Driver Dashboard"),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: VStack([
          UiSpacer.verticalSpace(space: 20),
          
          // Status Card
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
                HStack([
                  Icon(
                    _isOnline ? Icons.circle : Icons.circle_outlined,
                    color: _isOnline ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: VStack([
                      "Driver Status".text.bold.lg.make(),
                      (_isOnline ? "Online - Ready for rides" : "Offline - Not accepting rides").text.gray600.make(),
                    ]),
                  ),
                  CustomButton(
                    title: _isOnline ? "Go Offline" : "Go Online",
                    color: _isOnline ? Colors.orange : Colors.green,
                    onPressed: _toggleOnlineStatus,
                  ),
                ]),
              ]),
            ),
          ),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Pending Bookings
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
                HStack([
                  Icon(Icons.pending_actions, color: AppColor.primaryColor, size: 24),
                  SizedBox(width: 12),
                  "Pending Bookings".text.bold.lg.make(),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: "${_pendingBookings.length}".text.color(AppColor.primaryColor).bold.make(),
                  ),
                ]),
                
                UiSpacer.verticalSpace(space: 16),
                
                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else if (_pendingBookings.isEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    child: VStack([
                      Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                      SizedBox(height: 12),
                      "No pending bookings".text.gray600.lg.make(),
                      "You'll see new requests here".text.gray500.make(),
                    ]),
                  )
                else
                  ..._pendingBookings.map((booking) => _buildBookingCard(booking)).toList(),
              ]),
            ),
          ),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Quick Stats
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
                "Today's Stats".text.bold.lg.make(),
                UiSpacer.verticalSpace(space: 16),
                HStack([
                  Expanded(
                    child: _buildStatCard(
                      title: "Completed",
                      value: "12",
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: "Earnings",
                      value: "UGX 180,000",
                      icon: Icons.attach_money,
                      color: Colors.blue,
                    ),
                  ),
                ]),
                UiSpacer.verticalSpace(space: 12),
                HStack([
                  Expanded(
                    child: _buildStatCard(
                      title: "Rating",
                      value: "4.8",
                      icon: Icons.star,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: "Online Time",
                      value: "6h 30m",
                      icon: Icons.access_time,
                      color: Colors.purple,
                    ),
                  ),
                ]),
              ]),
            ),
          ),
          
          UiSpacer.verticalSpace(space: 20),
        ]),
      ),
    );
  }
  
  Widget _buildBookingCard(booking_model.BookingRequest booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: VStack([
        HStack([
          Icon(
            booking.serviceType == 'taxi' ? Icons.local_taxi : Icons.motorcycle,
            color: AppColor.primaryColor,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: VStack([
              "${booking.customerName}".text.bold.make(),
              "${booking.pickupAddress}".text.gray600.sm.make(),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: "NEW".text.color(Colors.orange).bold.xs.make(),
          ),
        ]),
        UiSpacer.verticalSpace(space: 8),
        HStack([
          "Distance: ${booking.distance} km".text.gray600.sm.make(),
          Spacer(),
          "Fare: UGX ${booking.estimatedFare}".text.bold.sm.make(),
        ]),
        UiSpacer.verticalSpace(space: 8),
        CustomButton(
          title: "View Details",
          color: AppColor.primaryColor,
          onPressed: () => _openBookingRequest(booking),
        ).wFull(context),
      ]),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: VStack([
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        value.text.bold.lg.color(color).make(),
        title.text.gray600.sm.make(),
      ]),
    );
  }
}