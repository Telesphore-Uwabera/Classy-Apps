import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/views/pages/location/location_selection.page.dart';
import 'package:Classy/views/pages/taxi/taxi.page.dart';
import 'package:Classy/views/pages/boda/boda.page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/utils/ui_spacer.dart';

class BookingFlowDemoPage extends StatefulWidget {
  const BookingFlowDemoPage({Key? key}) : super(key: key);

  @override
  _BookingFlowDemoPageState createState() => _BookingFlowDemoPageState();
}

class _BookingFlowDemoPageState extends State<BookingFlowDemoPage> {
  String? _fromAddress;
  String? _toAddress;
  LatLng? _fromPosition;
  LatLng? _toPosition;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Taxi/Boda Booking Flow",
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: VStack([
          UiSpacer.verticalSpace(space: 20),
          
          // Header
          VStack([
            "How Taxi/Boda Booking Works".tr().text.bold.xl2.make().centered(),
            UiSpacer.verticalSpace(space: 8),
            "Complete booking flow with enhanced location picker".tr().text.gray600.make().centered(),
          ]).px20(),
          
          UiSpacer.verticalSpace(space: 30),
          
          // Booking Flow Steps
          VStack([
            "Booking Flow Steps".text.bold.lg.make().px20(),
            UiSpacer.verticalSpace(space: 16),
            
            _buildStep(
              stepNumber: 1,
              title: "Select Service Type",
              description: "Choose between Taxi, Boda Boda, or other services",
              icon: Icons.local_taxi,
              color: Colors.blue,
            ),
            
            _buildStep(
              stepNumber: 2,
              title: "Choose Locations",
              description: "Use interactive map to select pickup and destination",
              icon: Icons.map,
              color: Colors.green,
            ),
            
            _buildStep(
              stepNumber: 3,
              title: "Find Drivers",
              description: "System searches for available drivers nearby",
              icon: Icons.search,
              color: Colors.orange,
            ),
            
            _buildStep(
              stepNumber: 4,
              title: "Confirm Booking",
              description: "Review trip details and confirm booking",
              icon: Icons.check_circle,
              color: Colors.purple,
            ),
            
            _buildStep(
              stepNumber: 5,
              title: "Track Ride",
              description: "Real-time tracking of your driver and ride",
              icon: Icons.gps_fixed,
              color: Colors.red,
            ),
          ]),
          
          UiSpacer.verticalSpace(space: 40),
          
          // Demo Buttons
          VStack([
            "Try the Enhanced Booking Flow".text.bold.lg.make().px20(),
            UiSpacer.verticalSpace(space: 16),
            
            // Taxi Booking
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
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_taxi, color: Colors.blue, size: 24),
                ),
                title: Text(
                  "Taxi Booking",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text("Book a taxi with enhanced location picker"),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaxiPage(
                      VendorType(
                        id: 1,
                        name: 'Taxi',
                        description: 'Taxi & Ride Services',
                        slug: 'taxi',
                        color: '#E91E63',
                        isActive: 1,
                        logo: '',
                        hasBanners: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Boda Booking
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
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.motorcycle, color: Colors.green, size: 24),
                ),
                title: Text(
                  "Boda Boda Booking",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text("Book a motorcycle ride with map selection"),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BodaPage(
                      VendorType(
                        id: 3,
                        name: 'Boda Boda',
                        description: 'Motorcycle Ride Services',
                        slug: 'bodaboda',
                        color: '#E91E63',
                        isActive: 1,
                        logo: '',
                        hasBanners: false,
                      ),
                    ),
                  ),
                ),
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
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on, color: Colors.purple, size: 24),
                ),
                title: Text(
                  "Location Selection Demo",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text("Test the enhanced map-based location picker"),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationSelectionPage(
                      initialFromAddress: _fromAddress,
                      initialToAddress: _toAddress,
                      initialFromPosition: _fromPosition,
                      initialToPosition: _toPosition,
                    ),
                  ),
                ),
              ),
            ),
          ]),
          
          UiSpacer.verticalSpace(space: 40),
          
          // Features List
          VStack([
            "Enhanced Features".text.bold.lg.make().px20(),
            UiSpacer.verticalSpace(space: 16),
            
            _buildFeature(
              icon: Icons.map,
              title: "Interactive Map Selection",
              description: "Tap on map to select exact pickup and destination points",
            ),
            
            _buildFeature(
              icon: Icons.search,
              title: "Google Places Integration",
              description: "Search for places using Google Places API with autocomplete",
            ),
            
            _buildFeature(
              icon: Icons.gps_fixed,
              title: "GPS Location Detection",
              description: "Automatic current location detection and address resolution",
            ),
            
            _buildFeature(
              icon: Icons.swap_vert,
              title: "Location Swap",
              description: "Easy one-tap swap between pickup and destination",
            ),
            
            _buildFeature(
              icon: Icons.history,
              title: "Recent Locations",
              description: "Quick access to previously selected locations",
            ),
            
            _buildFeature(
              icon: Icons.favorite,
              title: "Saved Locations",
              description: "Save Home, Work, and other frequent destinations",
            ),
          ]),
          
          UiSpacer.verticalSpace(space: 40),
        ]),
      ),
    );
  }
  
  Widget _buildStep({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        child: Row(
          children: [
            // Step Number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  stepNumber.toString(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 16),
            
            // Icon
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            
            SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
