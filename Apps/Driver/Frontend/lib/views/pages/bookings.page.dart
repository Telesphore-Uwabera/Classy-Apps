import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: "Bookings",
      body: VStack(
        [
          // Tab Bar
          Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabButton(
                  index: 0,
                  label: "Active",
                  isSelected: _selectedTabIndex == 0,
                ),
                _buildTabButton(
                  index: 1,
                  label: "Completed",
                  isSelected: _selectedTabIndex == 1,
                ),
                _buildTabButton(
                  index: 2,
                  label: "Cancelled",
                  isSelected: _selectedTabIndex == 2,
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.classyPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColor.textWhite : AppColor.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildActiveBookings();
      case 1:
        return _buildCompletedBookings();
      case 2:
        return _buildCancelledBookings();
      default:
        return _buildActiveBookings();
    }
  }

  Widget _buildActiveBookings() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: VStack(
        [
          // Ongoing Service Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: VStack(
              [
                // Header
                HStack(
                  [
                    Text(
                      "Ongoing Service",
                      style: TextStyle(
                        color: AppColor.classyPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColor.classyPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "En Route to Pickup",
                        style: TextStyle(
                          color: AppColor.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).py8(),
                
                // Map Placeholder
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColor.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.map,
                      color: AppColor.textLight,
                      size: 60,
                    ),
                  ),
                ).py16(),
                
                // Trip Details
                VStack(
                  [
                    _buildTripDetail(Icons.person, "John Doe"),
                    _buildTripDetail(Icons.location_on, "Destination: Garden City Mall"),
                    _buildTripDetail(Icons.directions_car, "Toyota Premio, UBA 123X"),
                    _buildTripDetail(Icons.access_time, "ETA: 6 min"),
                  ],
                ).py16(),
                
                // Action Buttons
                HStack(
                  [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Handle navigate
                        },
                        icon: Icon(Icons.navigation, color: AppColor.textWhite),
                        label: Text("Navigate"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.classyPrimary,
                          foregroundColor: AppColor.textWhite,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Handle contact
                        },
                        icon: Icon(Icons.phone, color: AppColor.classySuccess),
                        label: Text("Contact"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.classySuccess,
                          side: BorderSide(color: AppColor.classySuccess),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).py8(),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle end trip
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.classyPrimary,
                      foregroundColor: AppColor.textWhite,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("End Trip"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBookings() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: VStack(
          [
            Icon(
              Icons.check_circle,
              color: AppColor.textLight,
              size: 80,
            ).py16(),
            Text(
              "No Completed Bookings",
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).py8(),
            Text(
              "Your completed rides will appear here",
              style: TextStyle(
                color: AppColor.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledBookings() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: VStack(
          [
            Icon(
              Icons.cancel,
              color: AppColor.textLight,
              size: 80,
            ).py16(),
            Text(
              "No Cancelled Bookings",
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).py8(),
            Text(
              "Your cancelled rides will appear here",
              style: TextStyle(
                color: AppColor.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(IconData icon, String text) {
    return HStack(
      [
        Icon(
          icon,
          color: AppColor.classyPrimary,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColor.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ).py4();
  }
}
