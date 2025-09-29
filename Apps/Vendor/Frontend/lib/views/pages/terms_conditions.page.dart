import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/widgets/base.page.dart';
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
          "TERMS AND CONDITIONS FOR CLASSY UG VENDORS".text.xl2.bold.color(AppColor.primaryColor).make(),
          UiSpacer.verticalSpace(space: 8),
          "Last Updated: July 21, 2025".text.sm.gray600.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // 1. Introduction
          _buildSection(
            "1. Introduction",
            "Welcome to CLASSY UG Vendor Platform, operated by Classic Net Uganda Limited (\"we,\" \"our,\" \"us\"), offering food and agro-supply delivery services in Uganda. These Terms and Conditions (\"Terms\") govern your access and use of our vendor mobile application, vendor portal, and any associated services provided via the CLASSY UG platform (collectively, the \"Service\"). By accessing or using the Service, you confirm that you have read, understood, and agreed to be bound by these Terms and our Privacy Policy.\n\nIf you do not agree with these Terms, do not access or use the Service.",
          ),
          
          // 2. Acceptance of Terms
          _buildSection(
            "2. Acceptance of Terms",
            "By creating a vendor account, accessing the application, or using any CLASSY UG vendor services, you confirm your acceptance of these Terms. This constitutes a binding legal agreement between you and Classic Net Uganda Limited.",
          ),
          
          // 3. Definitions
          _buildSection(
            "3. Definitions",
            null,
            bullets: [
              "\"Vendor\" means any business entity or individual approved to sell products/services via the CLASSY UG platform.",
              "\"Customer\" refers to end-users who purchase products/services through the app.",
              "\"Courier\" means a delivery agent providing delivery services for vendor orders.",
              "\"Platform\" is the CLASSY UG mobile application and web portal.",
              "\"Commission\" is the percentage fee charged by CLASSY UG on each transaction.",
              "\"Settlement\" refers to the payment process for vendor earnings.",
            ],
          ),
          
          // 4. About CLASSY UG Vendor Platform
          _buildSection(
            "4. About CLASSY UG Vendor Platform",
            "CLASSY UG Vendor Platform is a business-to-consumer marketplace developed by Classic Net Uganda Limited, offering:",
            subSections: [
              "1. Food delivery services",
              "2. Agro-supplies delivery",
              "3. Product catalog management",
              "4. Order management system",
              "5. Payment processing",
              "6. Analytics and reporting",
            ],
            footer: "It is registered under the laws of Uganda (Registration No. 80034979723390), with headquarters in Kyanja, Kampala, Uganda.",
          ),
          
          // 5. Vendor Eligibility
          _buildSection(
            "5. Vendor Eligibility",
            "To become a CLASSY UG vendor, you must:",
            bullets: [
              "Be at least 18 years old and legally capable of entering into contracts",
              "Have a valid business registration or trading license",
              "Provide accurate business information and documentation",
              "Comply with all applicable Ugandan laws and regulations",
              "Maintain food safety standards (for food vendors)",
              "Have a physical business location or kitchen facility",
            ],
          ),
          
          // 6. Vendor Registration and Onboarding
          _buildSection(
            "6. Vendor Registration and Onboarding",
            "Vendor registration involves:",
            bullets: [
              "Complete application form with business details",
              "Document verification (business license, tax registration)",
              "Food safety certification (for food vendors)",
              "Menu/product catalog setup",
              "Pricing and delivery zone configuration",
              "Training on platform usage and policies",
            ],
            footer: "CLASSY UG reserves the right to approve or reject vendor applications based on compliance with our standards.",
          ),
          
          // 7. Vendor Responsibilities
          _buildSection(
            "7. Vendor Responsibilities",
            "As a CLASSY UG vendor, you agree to:",
            bullets: [
              "Maintain accurate product information and pricing",
              "Ensure food safety and quality standards",
              "Process orders within specified timeframes",
              "Provide excellent customer service",
              "Comply with all health and safety regulations",
              "Maintain proper business records",
              "Pay applicable taxes and fees",
            ],
          ),
          
          // 8. Product and Service Standards
          _buildSection(
            "8. Product and Service Standards",
            "All products and services must meet:",
            bullets: [
              "Ugandan food safety standards",
              "Accurate product descriptions and images",
              "Fair and transparent pricing",
              "Quality consistency across all orders",
              "Proper packaging and labeling requirements",
              "Allergen information (for food items)",
            ],
          ),
          
          // 9. Order Management
          _buildSection(
            "9. Order Management",
            "Vendors must:",
            bullets: [
              "Accept or reject orders within 5 minutes",
              "Prepare orders according to specified timeframes",
              "Update order status in real-time",
              "Communicate any delays or issues promptly",
              "Ensure order accuracy and completeness",
              "Handle customer complaints professionally",
            ],
          ),
          
          // 10. Commission and Payment Terms
          _buildSection(
            "10. Commission and Payment Terms",
            "CLASSY UG charges a commission on each transaction:",
            bullets: [
              "Food delivery: 15-25% commission (varies by category)",
              "Agro-supplies: 10-20% commission",
              "Commission is calculated on the total order value",
              "Settlements are processed weekly or monthly",
              "Payment methods: Mobile Money, Bank Transfer",
              "Minimum settlement amount: UGX 50,000",
            ],
          ),
          
          // 11. Delivery and Logistics
          _buildSection(
            "11. Delivery and Logistics",
            "Delivery services are managed by CLASSY UG:",
            bullets: [
              "CLASSY UG assigns couriers to orders",
              "Delivery fees are set by the platform",
              "Delivery zones are predefined and configurable",
              "Real-time tracking is available to customers",
              "Delivery time estimates are provided upfront",
              "Couriers are trained and insured",
            ],
          ),
          
          // 12. Customer Service
          _buildSection(
            "12. Customer Service",
            "Vendors must provide:",
            bullets: [
              "Professional and courteous service",
              "Quick response to customer inquiries",
              "Resolution of complaints within 24 hours",
              "Refund processing for valid claims",
              "Clear communication about policies",
              "Support during business hours",
            ],
          ),
          
          // 13. Quality Control
          _buildSection(
            "13. Quality Control",
            "CLASSY UG maintains quality through:",
            bullets: [
              "Regular vendor performance reviews",
              "Customer feedback and ratings",
              "Mystery shopping and quality audits",
              "Food safety inspections",
              "Performance metrics tracking",
              "Continuous improvement programs",
            ],
          ),
          
          // 14. Marketing and Promotions
          _buildSection(
            "14. Marketing and Promotions",
            "Vendors can participate in:",
            bullets: [
              "Platform-wide promotional campaigns",
              "Featured vendor opportunities",
              "Discount and coupon programs",
              "Social media marketing support",
              "Local area marketing initiatives",
              "Seasonal promotional events",
            ],
          ),
          
          // 15. Data and Privacy
          _buildSection(
            "15. Data and Privacy",
            "Vendors must comply with:",
            bullets: [
              "Uganda's Data Protection and Privacy Act, 2019",
              "Secure handling of customer information",
              "Confidentiality of business data",
              "Proper data retention policies",
              "Customer consent for marketing",
              "Secure payment processing",
            ],
          ),
          
          // 16. Termination and Suspension
          _buildSection(
            "16. Termination and Suspension",
            "CLASSY UG may suspend or terminate vendor accounts for:",
            bullets: [
              "Violation of these Terms",
              "Poor customer service ratings",
              "Food safety violations",
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
            "CLASSY UG reserves the right to update these Terms at any time. Changes will be posted within the vendor portal and communicated via email. Continued use of the Service after any modifications constitutes your acceptance of the revised Terms.",
          ),
          
          // 19. Contact Information
          _buildSection(
            "19. Contact Information",
            "For vendor support and inquiries:",
            contactInfo: [
              "Email: vendors@classyug.com",
              "Phone: +256 762 992 378",
              "Address: Kyanja, Kampala, Uganda, P.O. Box 200550",
              "Vendor Support Hours: 8:00 AM - 8:00 PM (EAT)",
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
              "THANK YOU FOR BEING A CLASSY UG VENDOR".text.lg.bold.color(AppColor.primaryColor).make(),
              UiSpacer.verticalSpace(space: 8),
              "Together we deliver excellence.".text.italic.color(AppColor.primaryColor).make(),
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
