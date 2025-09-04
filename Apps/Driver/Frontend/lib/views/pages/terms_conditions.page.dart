import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/ui_spacer.dart';
import '../../widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Terms & Conditions".tr(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: VStack([
          // Header
          "TERMS AND CONDITIONS FOR CLASSY UG DRIVERS".text.xl2.bold.color(AppColor.primaryColor).make(),
          UiSpacer.verticalSpace(space: 8),
          "Last Updated: July 21, 2025".text.sm.gray600.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // 1. Introduction
          _buildSection(
            "1. Introduction",
            "Welcome to CLASSY UG Driver Platform, operated by Classic Net Uganda Limited (\"we,\" \"our,\" \"us\"), offering ride-hailing and delivery services in Uganda. These Terms and Conditions (\"Terms\") govern your access and use of our driver mobile application, driver portal, and any associated services provided via the CLASSY UG platform (collectively, the \"Service\"). By accessing or using the Service, you confirm that you have read, understood, and agreed to be bound by these Terms and our Privacy Policy.\n\nIf you do not agree with these Terms, do not access or use the Service.",
          ),
          
          // 2. Acceptance of Terms
          _buildSection(
            "2. Acceptance of Terms",
            "By creating a driver account, accessing the application, or using any CLASSY UG driver services, you confirm your acceptance of these Terms. This constitutes a binding legal agreement between you and Classic Net Uganda Limited.",
          ),
          
          // 3. Definitions
          _buildSection(
            "3. Definitions",
            null,
            bullets: [
              "\"Driver\" means any individual approved to provide ride-hailing or delivery services via the CLASSY UG platform.",
              "\"Customer\" refers to end-users who request rides or deliveries through the app.",
              "\"Ride\" means transportation services provided by drivers to customers.",
              "\"Delivery\" means courier services for food, packages, or other items.",
              "\"Platform\" is the CLASSY UG mobile application and driver portal.",
              "\"Commission\" is the percentage fee charged by CLASSY UG on each transaction.",
            ],
          ),
          
          // 4. About CLASSY UG Driver Platform
          _buildSection(
            "4. About CLASSY UG Driver Platform",
            "CLASSY UG Driver Platform is a service provider platform developed by Classic Net Uganda Limited, offering:",
            subSections: [
              "1. Car taxi services",
              "2. Boda boda transportation",
              "3. Food and package delivery",
              "4. Real-time location tracking",
              "5. Payment processing",
              "6. Earnings management",
            ],
            footer: "It is registered under the laws of Uganda (Registration No. 80034979723390), with headquarters in Kyanja, Kampala, Uganda.",
          ),
          
          // 5. Driver Eligibility
          _buildSection(
            "5. Driver Eligibility",
            "To become a CLASSY UG driver, you must:",
            bullets: [
              "Be at least 18 years old and legally capable of entering into contracts",
              "Have a valid driver's license for the vehicle type you operate",
              "Own or have access to a registered and insured vehicle",
              "Provide accurate personal information and documentation",
              "Pass background checks and verification processes",
              "Comply with all applicable Ugandan laws and regulations",
            ],
          ),
          
          // 6. Driver Registration and Onboarding
          _buildSection(
            "6. Driver Registration and Onboarding",
            "Driver registration involves:",
            bullets: [
              "Complete application form with personal and vehicle details",
              "Document verification (driver's license, vehicle registration)",
              "Vehicle inspection and safety checks",
              "Background check and criminal record verification",
              "Training on platform usage and safety protocols",
              "App installation and account activation",
            ],
            footer: "CLASSY UG reserves the right to approve or reject driver applications based on compliance with our standards.",
          ),
          
          // 7. Driver Responsibilities
          _buildSection(
            "7. Driver Responsibilities",
            "As a CLASSY UG driver, you agree to:",
            bullets: [
              "Maintain a safe and clean vehicle",
              "Follow all traffic laws and safety regulations",
              "Provide professional and courteous service",
              "Maintain accurate vehicle and personal information",
              "Respond promptly to service requests",
              "Handle customer complaints professionally",
              "Maintain proper insurance coverage",
            ],
          ),
          
          // 8. Vehicle and Safety Standards
          _buildSection(
            "8. Vehicle and Safety Standards",
            "All vehicles must meet:",
            bullets: [
              "Ugandan road safety standards",
              "Valid registration and insurance",
              "Regular maintenance and safety checks",
              "Clean and presentable condition",
              "Proper safety equipment (seatbelts, helmets for boda)",
              "Compliance with emission standards",
            ],
          ),
          
          // 9. Service Standards
          _buildSection(
            "9. Service Standards",
            "Drivers must provide:",
            bullets: [
              "Safe and comfortable transportation",
              "Accurate arrival time estimates",
              "Professional appearance and behavior",
              "Clear communication with customers",
              "Assistance with luggage or packages",
              "Emergency response capabilities",
            ],
          ),
          
          // 10. Commission and Payment Terms
          _buildSection(
            "10. Commission and Payment Terms",
            "CLASSY UG charges a commission on each transaction:",
            bullets: [
              "Car rides: 20-25% commission (varies by service type)",
              "Boda rides: 15-20% commission",
              "Delivery services: 15-25% commission",
              "Commission is calculated on the total fare",
              "Settlements are processed weekly or monthly",
              "Payment methods: Mobile Money, Bank Transfer",
              "Minimum settlement amount: UGX 25,000",
            ],
          ),
          
          // 11. Earnings and Incentives
          _buildSection(
            "11. Earnings and Incentives",
            "Drivers can earn through:",
            bullets: [
              "Base fare for each completed trip",
              "Distance-based charges",
              "Time-based charges for waiting",
              "Surge pricing during peak hours",
              "Tips from satisfied customers",
              "Performance bonuses and incentives",
              "Referral rewards for new drivers",
            ],
          ),
          
          // 12. Working Hours and Availability
          _buildSection(
            "12. Working Hours and Availability",
            "Drivers have flexibility to:",
            bullets: [
              "Set their own working hours",
              "Choose service areas and zones",
              "Accept or decline service requests",
              "Take breaks as needed",
              "Go offline temporarily",
              "Set availability preferences",
            ],
            footer: "However, maintaining consistent availability improves earnings and customer satisfaction.",
          ),
          
          // 13. Customer Service
          _buildSection(
            "13. Customer Service",
            "Drivers must provide:",
            bullets: [
              "Professional and courteous service",
              "Quick response to customer requests",
              "Resolution of issues promptly",
              "Clear communication about delays",
              "Assistance with special needs",
              "Emergency support when required",
            ],
          ),
          
          // 14. Safety and Security
          _buildSection(
            "14. Safety and Security",
            "CLASSY UG prioritizes safety through:",
            bullets: [
              "Real-time GPS tracking of all trips",
              "Emergency SOS button in the driver app",
              "Customer and driver verification systems",
              "24/7 support and monitoring",
              "Insurance coverage for drivers and passengers",
              "Background checks for all users",
            ],
          ),
          
          // 15. Data and Privacy
          _buildSection(
            "15. Data and Privacy",
            "Drivers must comply with:",
            bullets: [
              "Uganda's Data Protection and Privacy Act, 2019",
              "Secure handling of customer information",
              "Confidentiality of trip details",
              "Proper data retention policies",
              "Customer consent for communications",
              "Secure payment processing",
            ],
          ),
          
          // 16. Termination and Suspension
          _buildSection(
            "16. Termination and Suspension",
            "CLASSY UG may suspend or terminate driver accounts for:",
            bullets: [
              "Violation of these Terms",
              "Poor customer service ratings",
              "Safety violations or accidents",
              "Fraudulent activities",
              "Non-compliance with regulations",
              "Repeated customer complaints",
            ],
          ),
          
          // 17. Dispute Resolution
          _buildSection(
            "17. Dispute Resolution",
            "In case of disputes:",
            bullets: [
              "Parties agree to attempt informal resolution",
              "Contact support@classyug.com for mediation",
              "If unresolved, disputes go to arbitration",
              "Arbitration under Uganda Arbitration Act",
              "Decisions are binding on both parties",
              "Legal costs are borne by the losing party",
            ],
          ),
          
          // 18. Changes to Terms
          _buildSection(
            "18. Changes to Terms",
            "CLASSY UG reserves the right to update these Terms at any time. Changes will be posted within the driver portal and communicated via email. Continued use of the Service after any modifications constitutes your acceptance of the revised Terms.",
          ),
          
          // 19. Contact Information
          _buildSection(
            "19. Contact Information",
            "For driver support and inquiries:",
            contactInfo: [
              "Email: drivers@classyug.com",
              "Phone: +256 762 992 378",
              "Address: Kyanja, Kampala, Uganda, P.O. Box 200550",
              "Driver Support Hours: 24/7 (Emergency), 8:00 AM - 8:00 PM (General)",
            ],
          ),
          
          // Footer
          UiSpacer.verticalSpace(space: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: VStack([
              "THANK YOU FOR BEING A CLASSY UG DRIVER".text.lg.bold.color(AppColor.primaryColor).make(),
              UiSpacer.verticalSpace(space: 8),
              "Drive safely, earn smartly.".text.italic.color(AppColor.primaryColor).make(),
            ]),
          ),
          
          UiSpacer.verticalSpace(space: 40),
        ]),
      ),
    );
  }
  
  Widget _buildSection(
    String title,
    String? content, {
    List<String>? bullets,
    List<String>? subSections,
    List<String>? contactInfo,
    String? footer,
  }) {
    return VStack([
      // Section title
      title.text.lg.bold.color(AppColor.primaryColor).make(),
      UiSpacer.verticalSpace(space: 8),
      
      // Main content
      if (content != null) ...[
        content.text.make(),
        UiSpacer.verticalSpace(space: 8),
      ],
      
      // Bullet points
      if (bullets != null) ...bullets.map((bullet) => 
        HStack([
          "• ".text.color(AppColor.primaryColor).make(),
          bullet.text.make().expand(),
        ]).py2(),
      ),
      
      // Sub-sections
      if (subSections != null) ...subSections.map((section) => 
        Padding(
          padding: EdgeInsets.only(left: 16, top: 8),
          child: section.text.make(),
        ),
      ),
      
      // Contact info
      if (contactInfo != null) ...contactInfo.map((info) => 
        Padding(
          padding: EdgeInsets.only(left: 16, top: 4),
          child: info.text.make(),
        ),
      ),
      
      // Footer
      if (footer != null) ...[
        UiSpacer.verticalSpace(space: 8),
        footer.text.gray600.make(),
      ],
      
      UiSpacer.verticalSpace(space: 20),
    ]);
  }
}
