import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceTypeSelectionPage extends StatefulWidget {
  const ServiceTypeSelectionPage({Key? key}) : super(key: key);

  @override
  State<ServiceTypeSelectionPage> createState() => _ServiceTypeSelectionPageState();
}

class _ServiceTypeSelectionPageState extends State<ServiceTypeSelectionPage> {
  String? selectedServiceType;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.backgroundSecondary,
              AppColor.backgroundPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: VStack(
            [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: VStack(
                  [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
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
                      child: Center(
                                                 child: Icon(
                           Icons.auto_awesome,
                           size: 40,
                           color: AppColor.classyPrimary,
                         ),
                      ),
                    ).py16(),
                    
                    // Title
                    Text(
                      "Create Account",
                      style: TextStyle(
                        color: AppColor.classyPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ).py8(),
                    
                    // Subtitle
                    Text(
                      "Register as a service provider",
                      style: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Service Type Selection
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: VStack(
                    [
                      Text(
                        "Choose Your Service Type",
                        style: TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ).py16(),
                      
                      // Service Type Cards
                      HStack(
                        [
                          _buildServiceTypeCard(
                            type: "car",
                            title: "Car Driver",
                            subtitle: "Driver",
                            icon: Icons.directions_car,
                            iconColor: AppColor.classyInfo,
                            isSelected: selectedServiceType == "car",
                            onTap: () => setState(() => selectedServiceType = "car"),
                          ),
                          SizedBox(width: 12),
                          _buildServiceTypeCard(
                            type: "boda",
                            title: "Boda Rider",
                            subtitle: "Rider",
                            icon: Icons.motorcycle,
                            iconColor: AppColor.classySuccess,
                            isSelected: selectedServiceType == "boda",
                            onTap: () => setState(() => selectedServiceType = "boda"),
                          ),
                        ],
                      ).py16(),
                      
                      _buildServiceTypeCard(
                        type: "food",
                        title: "Food Vendor",
                        subtitle: "Vendor",
                        icon: Icons.restaurant,
                        iconColor: AppColor.classyWarning,
                        isSelected: selectedServiceType == "food",
                        onTap: () => setState(() => selectedServiceType = "food"),
                      ).py16(),
                      
                      Spacer(),
                      
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedServiceType != null ? _onContinuePressed : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedServiceType != null 
                                ? AppColor.classyPrimary 
                                : AppColor.textLight,
                            foregroundColor: AppColor.textWhite,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Continue",
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
      ),
    );
  }

  Widget _buildServiceTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.classyPrimary.withOpacity(0.1) : AppColor.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColor.classyPrimary : AppColor.textLight.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: VStack(
            [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ).py8(),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ).py4(),
              
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? AppColor.classyPrimary : AppColor.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinuePressed() {
    if (selectedServiceType != null) {
      // Navigate to registration page with selected service type
      Navigator.pushNamed(
        context, 
        AppRoutes.registerRoute,
        arguments: {'serviceType': selectedServiceType},
      );
    }
  }
}
