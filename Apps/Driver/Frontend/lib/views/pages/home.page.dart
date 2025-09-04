import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isOnline = false;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: SafeArea(
        child: VStack(
          [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              child: HStack(
                [
                  // App Title
                  Text(
                    AppStrings.companyName,
                    style: TextStyle(
                      color: AppColor.classyPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Online/Offline Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.backgroundCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Offline State
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.transparent : AppColor.textLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Offline",
                            style: TextStyle(
                              color: isOnline ? AppColor.textSecondary : AppColor.textWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        // Online State
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isOnline ? AppColor.classySuccess : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Online",
                            style: TextStyle(
                              color: isOnline ? AppColor.textWhite : AppColor.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: VStack(
                  [
                    // Status Message
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isOnline ? AppColor.classySuccess.withOpacity(0.1) : AppColor.textLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOnline ? AppColor.classySuccess.withOpacity(0.3) : AppColor.textLight.withOpacity(0.3),
                        ),
                      ),
                      child: HStack(
                        [
                          Icon(
                            isOnline ? Icons.check_circle : Icons.info,
                            color: isOnline ? AppColor.classySuccess : AppColor.textSecondary,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isOnline 
                                  ? "You are online and ready to receive ride requests"
                                  : "Go online to start receiving ride requests",
                              style: TextStyle(
                                color: isOnline ? AppColor.classySuccess : AppColor.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).py16(),
                    
                    // Ride Request Card (when online)
                    if (isOnline) _buildRideRequestCard(),
                    
                    // Offline Message (when offline)
                    if (!isOnline) _buildOfflineMessage(),
                    
                    Spacer(),
                    
                    // Toggle Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() => isOnline = !isOnline),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOnline ? AppColor.classyError : AppColor.classySuccess,
                          foregroundColor: AppColor.textWhite,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isOnline ? "Go Offline" : "Go Online",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).py16(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideRequestCard() {
    return Container(
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
          // Ride Type Header
          HStack(
            [
              Icon(
                Icons.directions_car,
                color: AppColor.classyPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Car Ride",
                style: TextStyle(
                  color: AppColor.classyPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.classyPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Now",
                  style: TextStyle(
                    color: AppColor.classyPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ).py8(),
          
          Divider(color: AppColor.textLight.withOpacity(0.3)),
          
          // Customer Info
          VStack(
            [
              Text(
                "John Doe",
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ).py8(),
              
              HStack(
                [
                  Icon(
                    Icons.location_on,
                    color: AppColor.classyPrimary,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pickup: Acacia Mall",
                      style: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ).py4(),
              
              HStack(
                [
                  Icon(
                    Icons.location_on,
                    color: AppColor.classyError,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Drop: Garden City",
                      style: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ).py4(),
            ],
          ).py16(),
          
          // Action Buttons
          HStack(
            [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Handle reject
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColor.classyPrimary),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Reject",
                    style: TextStyle(
                      color: AppColor.classyPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle accept
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.classyPrimary,
                    foregroundColor: AppColor.textWhite,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Accept",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).py16();
  }

  Widget _buildOfflineMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40),
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
          Icon(
            Icons.offline_bolt,
            color: AppColor.textLight,
            size: 60,
          ).py16(),
          
          Text(
            "You're Currently Offline",
            style: TextStyle(
              color: AppColor.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).py8(),
          
          Text(
            "Go online to start receiving ride requests and earning money",
            style: TextStyle(
              color: AppColor.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).py16();
  }
}
