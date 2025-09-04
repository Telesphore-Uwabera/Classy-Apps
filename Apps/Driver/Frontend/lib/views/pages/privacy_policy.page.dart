import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/ui_spacer.dart';
import '../../widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Privacy Policy".tr(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: VStack([
          // Header
          "Privacy Policy – CLASSY UG Driver Platform".text.xl2.bold.color(AppColor.primaryColor).make(),
          UiSpacer.verticalSpace(space: 8),
          "Last Updated: July 21, 2025".text.sm.gray600.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // Introduction paragraph
          "This Privacy Policy describes how CLASSY UG (\"we,\" \"our,\" \"us\") collects, uses, shares, and protects information about our drivers (\"you,\" \"your\") through our driver mobile application, driver portal, and related services (collectively, the \"Platform\"). This Policy complies with the Data Protection and Privacy Act, 2019 of Uganda and other relevant legal frameworks."
              .text.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // 1. INTRODUCTION
          _buildSection(
            "1. INTRODUCTION",
            "CLASSY UG is committed to protecting your privacy and ensuring that your personal and professional information is handled in a secure, lawful, and transparent manner. This Privacy Policy explains how we collect, use, and safeguard your data when you interact with our driver services, including ride-hailing, delivery services, and driver management tools. Your use of our Platform confirms your consent to this Policy.",
          ),
          
          // 2. DEFINITIONS
          _buildSection(
            "2. DEFINITIONS",
            null,
            bullets: [
              "\"Driver Data\" means any information relating to your driving services and operations.",
              "\"Processing\" means any operation or set of operations which is performed on driver data.",
              "\"Controller\" means CLASSY UG, who determines the purposes and means of the processing of driver data.",
              "\"Data Subject\" means any driver whose data is collected.",
              "\"Third Party\" means any natural or legal person, authority, or agency other than the driver, controller, or processor.",
            ],
          ),
          
          // 3. INFORMATION WE COLLECT
          _buildSection(
            "3. INFORMATION WE COLLECT",
            "We collect the following categories of driver data:",
            subSections: [
              "a) Personal Identity Data\n• Full name, date of birth, national ID\n• Profile photo and identification documents\n• Emergency contact information",
              "b) Vehicle Data\n• Vehicle registration and insurance details\n• Vehicle type, model, and specifications\n• Vehicle inspection and maintenance records",
              "c) License and Certification Data\n• Driver's license number and validity\n• Vehicle permits and certifications\n• Background check and verification results",
              "d) Location and Tracking Data\n• Real-time GPS coordinates during trips\n• Trip history and route information\n• Service area preferences and boundaries",
              "e) Financial Data\n• Bank account details for settlements\n• Earnings and commission calculations\n• Payment and transaction records",
              "f) Performance Data\n• Customer ratings and feedback\n• Trip completion rates and statistics\n• Service quality metrics",
              "g) Technical Data\n• Device information and app usage logs\n• IP address and network data\n• Cookies and tracking pixels",
            ],
            footer: "We only collect data that is necessary for providing driver services and platform management.",
          ),
          
          // 4. HOW WE COLLECT DATA
          _buildSection(
            "4. HOW WE COLLECT DATA",
            "We collect your data through:",
            bullets: [
              "Direct input during driver registration and onboarding",
              "Use of the driver app and portal features",
              "GPS tracking during active service periods",
              "Customer feedback and ratings",
              "Third-party verification services",
              "Automated tracking and analytics",
              "Background checks and document verification",
            ],
          ),
          
          // 5. LEGAL BASIS FOR PROCESSING
          _buildSection(
            "5. LEGAL BASIS FOR PROCESSING",
            "We process your data on the following grounds:",
            bullets: [
              "Contractual necessity – to provide driver services as agreed",
              "Legal obligation – compliance with URA, UCC, and traffic regulations",
              "Legitimate interest – platform management and service improvement",
              "Consent – for marketing and promotional communications",
              "Public safety – ensuring safe transportation services",
            ],
          ),
          
          // 6. HOW WE USE YOUR DATA
          _buildSection(
            "6. HOW WE USE YOUR DATA",
            "Your driver data is used to:",
            bullets: [
              "Facilitate and manage driver services on the platform",
              "Process ride requests and manage customer interactions",
              "Calculate earnings and process settlements",
              "Provide real-time location tracking for safety",
              "Ensure compliance with platform policies and regulations",
              "Improve driver experience and service offerings",
              "Handle customer support and dispute resolution",
              "Monitor service quality and performance",
            ],
            footer: "We may use data analytics to enhance platform efficiency and driver success.",
          ),
          
          // 7. DATA SHARING & THIRD PARTIES
          _buildSection(
            "7. DATA SHARING & THIRD PARTIES",
            "We only share driver data with:",
            bullets: [
              "Customers – limited driver information (name, photo, vehicle, rating)",
              "Payment processors – settlement and financial information",
              "Insurance providers – coverage verification and claims",
              "Legal authorities – if required under law or court order",
              "Data storage and hosting providers – under strict confidentiality terms",
              "Emergency services – in case of accidents or safety incidents",
            ],
            footer: "All third parties must follow data protection policies aligned with Uganda's law.",
          ),
          
          // 8. LOCATION AND TRACKING
          _buildSection(
            "8. LOCATION AND TRACKING",
            "Location tracking is essential for our services:",
            bullets: [
              "GPS tracking is active only during service periods",
              "Location data is used for trip routing and safety",
              "Historical location data is retained for service improvement",
              "Drivers can disable location when not providing services",
              "Location data is encrypted and securely stored",
              "Real-time tracking is visible to customers during active trips",
            ],
            footer: "Location tracking is essential for customer safety and service quality.",
          ),
          
          // 9. INTERNATIONAL TRANSFERS
          _buildSection(
            "9. INTERNATIONAL TRANSFERS",
            "Although our primary servers are in Uganda, some data may be processed abroad (e.g., backup or third-party APIs). We ensure:",
            bullets: [
              "Adequate data protection laws in destination countries",
              "Standard contractual clauses with foreign partners",
              "Data encryption during transmission",
              "Limited data transfer to essential services only",
            ],
            footer: "We do not transfer your driver data outside Uganda unless necessary and secured.",
          ),
          
          // 10. YOUR RIGHTS
          _buildSection(
            "10. YOUR RIGHTS UNDER THE UGANDA DATA PROTECTION AND PRIVACY ACT, 2019",
            "As a driver, you have the right to:",
            bullets: [
              "Access your personal and professional data held by CLASSY UG",
              "Rectify inaccurate or outdated information",
              "Delete your data when no longer needed",
              "Restrict processing in certain circumstances",
              "Object to processing for direct marketing",
              "Withdraw consent at any time",
              "Lodge a complaint with the Personal Data Protection Office (PDPO)",
              "Request data portability in machine-readable format",
            ],
            footer: "You can exercise your rights by contacting:\n📩 drivers@classyug.com",
          ),
          
          // 11. DATA RETENTION
          _buildSection(
            "11. DATA RETENTION",
            "We retain your driver data for:",
            bullets: [
              "As long as your driver account is active",
              "6 years after the last transaction (for legal compliance)",
              "Longer if required by URA, UCC, or in ongoing legal matters",
              "Business analytics and platform improvement purposes",
              "Safety and security monitoring requirements",
            ],
            footer: "We securely delete or anonymize data when retention is no longer needed.",
          ),
          
          // 12. COOKIES & TRACKING
          _buildSection(
            "12. COOKIES & TRACKING",
            "CLASSY UG uses cookies to:",
            bullets: [
              "Store driver session information",
              "Remember preferences and settings",
              "Track app usage for analytics and improvement",
              "Ensure secure platform access",
              "Optimize app performance",
            ],
            footer: "You can disable cookies in browser settings, but it may affect platform functionality.",
          ),
          
          // 13. SECURITY MEASURES
          _buildSection(
            "13. SECURITY MEASURES",
            "We implement industry-grade safeguards:",
            bullets: [
              "End-to-end encryption for all data transmission",
              "Secure authentication and access controls",
              "Regular security audits and vulnerability assessments",
              "Data backup and disaster recovery procedures",
              "Employee training on data protection",
              "Incident response and breach notification protocols",
              "24/7 security monitoring and threat detection",
            ],
          ),
          
          // 14. DRIVER SAFETY AND SECURITY
          _buildSection(
            "14. DRIVER SAFETY AND SECURITY",
            "We protect driver safety through:",
            bullets: [
              "Real-time GPS tracking during active trips",
              "Emergency SOS button with immediate response",
              "Customer verification and rating systems",
              "24/7 support and emergency assistance",
              "Insurance coverage for drivers and passengers",
              "Background checks for all customers",
              "Incident reporting and response protocols",
            ],
          ),
          
          // 15. AUTOMATED DECISION-MAKING
          _buildSection(
            "15. AUTOMATED DECISION-MAKING",
            "We may use algorithms to:",
            bullets: [
              "Calculate trip fares and commission rates",
              "Assign optimal routes and service areas",
              "Analyze driver performance and ratings",
              "Detect fraudulent activities or policy violations",
              "Optimize driver-customer matching",
            ],
            footer: "These decisions are regularly reviewed by human supervisors and can be appealed.",
          ),
          
          // 16. MARKETING & PROMOTIONS
          _buildSection(
            "16. MARKETING & PROMOTIONS",
            "You may receive business-related communications about:",
            bullets: [
              "Platform updates and new features",
              "Promotional opportunities and campaigns",
              "Earnings optimization tips",
              "Training and safety resources",
              "Driver community events",
            ],
            footer: "You can opt-out anytime via your driver portal settings or by emailing drivers@classyug.com.",
          ),
          
          // 17. THIRD-PARTY LINKS
          _buildSection(
            "17. THIRD-PARTY LINKS",
            "Our driver portal may contain links to other platforms (e.g., payment processors or business tools). We are not responsible for their privacy practices.",
          ),
          
          // 18. CHANGES TO THIS POLICY
          _buildSection(
            "18. CHANGES TO THIS POLICY",
            "We may update this Policy as laws or services change. All updates will be posted in the driver portal and communicated via email. Material changes will be notified directly.",
          ),
          
          // 19. CONTACT US
          _buildSection(
            "19. CONTACT US",
            "If you have any questions or complaints regarding privacy:",
            contactInfo: [
              "CLASSY UG – Driver Privacy Team",
              "📩 Email: drivers@classyug.com",
              "📩 Address: Classic Net Uganda Limited\nP.O. Box 200550, Kyanja, Kampala, Uganda",
              "📩 Tel: +256 762 992 376",
              "📩 Website: https://classyug.com",
              "📩 Driver Support Hours: 24/7 (Emergency), 8:00 AM - 8:00 PM (General)",
            ],
          ),
          
          // 20. LEGAL COMPLIANCE
          _buildSection(
            "20. ANNEX: LEGAL COMPLIANCE",
            "This Privacy Policy complies with:",
            bullets: [
              "The Constitution of the Republic of Uganda (1995)",
              "The Data Protection and Privacy Act, 2019",
              "The Computer Misuse Act, 2011",
              "The Electronic Transactions Act, 2011",
              "Uganda Communications Act, 2013",
              "Anti-Money Laundering Act, 2013",
              "Traffic and Road Safety Act, 1998",
              "Motor Vehicle Insurance Act, 2014",
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
            child: "📩 CLASSY UG values your trust as a service provider. We ensure your personal and professional data is protected through stringent protocols. Our compliance with the Data Protection and Privacy Act (2019) means your rights are safeguarded, including your right to access, rectify, and erase your data. Our privacy practices reflect international best standards, guaranteeing security, transparency, and accountability in all transportation services."
                .text.color(AppColor.primaryColor).make(),
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
