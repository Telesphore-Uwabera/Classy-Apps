import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
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
          "TERMS AND CONDITIONS FOR CLASSY UG".text.xl2.bold.color(AppColor.primaryColor).make(),
          UiSpacer.verticalSpace(space: 8),
          "Last Updated: July 21, 2025".text.sm.gray600.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // 1. Introduction
          _buildSection(
            "1. Introduction",
            "Welcome to CLASSY UG, a digital platform operated by Classic Net Uganda Limited (\"we,\" \"our,\" \"us\"), offering ride-hailing (car and boda), food and agro-supply delivery, and domestic flight booking services in Uganda. These Terms and Conditions (\"Terms\") govern your access and use of our mobile application, website (https://classyug.com), and any associated services provided via the CLASSY UG platform (collectively, the \"Service\"). By accessing or using the Service, you confirm that you have read, understood, and agreed to be bound by these Terms and our Privacy Policy.\n\nIf you do not agree with these Terms, do not access or use the Service.",
          ),
          
          // 2. Acceptance of Terms
          _buildSection(
            "2. Acceptance of Terms",
            "By creating an account, accessing the application, or using any CLASSY UG services, you confirm your acceptance of these Terms. This constitutes a binding legal agreement between you and Classic Net Uganda Limited.",
          ),
          
          // 3. Definitions
          _buildSection(
            "3. Definitions",
            null,
            bullets: [
              "\"User\" means any individual using the CLASSY UG platform.",
              "\"Driver\" refers to a person approved to offer ride services via the app.",
              "\"Courier\" means a delivery agent providing food/agro deliveries.",
              "\"Partner\" refers to third-party vendors and merchants.",
              "\"Wallet\" is the in-app balance linked to your account.",
              "\"Mobile Money\" includes Airtel Money and MTN Mobile Money.",
            ],
          ),
          
          // 4. About CLASSY UG
          _buildSection(
            "4. About CLASSY UG",
            "CLASSY UG is a mobile-first super-app developed by Classic Net Uganda Limited, offering four core services:",
            subSections: [
              "1. Car taxi rides",
              "2. Boda boda rides", 
              "3. Food delivery & agro supplies",
              "4. Domestic flight bookings",
            ],
            footer: "It is registered under the laws of Uganda (Registration No. 80034979723390), with headquarters in Kyanja, Kampala, Uganda.",
          ),
          
          // 5. User Eligibility
          _buildSection(
            "5. User Eligibility",
            "You must be at least 18 years old and legally capable of entering into contracts under Ugandan law. If using the app on behalf of another individual or company, you confirm you are authorized to do so.",
          ),
          
          // 6. User Accounts and Registration
          _buildSection(
            "6. User Accounts and Registration",
            "To access services, you must register an account using a valid phone number and verify it via SMS. Users agree to provide accurate, current, and complete information. You are responsible for all activity under your account. CLASSY UG reserves the right to suspend or terminate accounts that violate these Terms or are suspected of fraudulent activity.",
          ),
          
          // 7. Services Provided
          _buildSection(
            "7. Services Provided",
            "CLASSY UG facilitates connections between Users and independent service providers (Drivers, Couriers, Vendors, Airlines). We do not provide transportation or delivery ourselves; we act as an intermediary platform.",
          ),
          
          // 8. Ride-Hailing Services
          _buildSection(
            "8. Ride-Hailing Services (Car and Boda)",
            "Users may request rides from licensed drivers via the app. Drivers are independent contractors, not employees of CLASSY UG. Ride fares are calculated based on distance, time, and surge pricing where applicable. Users must verify the driver and vehicle before boarding.",
          ),
          
          // 9. Food and Agro-Supplies Delivery
          _buildSection(
            "9. Food and Agro-Supplies Delivery",
            "Users may browse and order from registered vendors. All menu items, agro-products, pricing, and availability are managed by vendors. CLASSY UG is not responsible for quality, preparation, or delays. Upon placing an order, the nearest available courier is assigned. Delivery times are estimated and not guaranteed.",
          ),
          
          // 10. Domestic Flight Bookings
          _buildSection(
            "10. Domestic Flight Bookings",
            "CLASSY UG provides a flight aggregation service, allowing users to search, compare, and book local flights. All ticketing, rescheduling, and cancellation policies are governed by the individual airlines. CLASSY UG only acts as a facilitator and does not operate any airline.",
          ),
          
          // 11. Payment Terms
          _buildSection(
            "11. Payment Terms",
            "Payments may be made using Mobile Money (MTN, Airtel), wallet balance, or promotional coupons. Upon confirmation of a ride or order, the corresponding fare is automatically deducted or reserved. All payments are final unless otherwise stated in our refund policy.",
          ),
          
          // 12. Wallet and Mobile Money Use
          _buildSection(
            "12. Wallet and Mobile Money Use",
            "Users can top up their CLASSY UG Wallet via Mobile Money. This balance can be used across all services. Refunds to Mobile Money accounts are at our sole discretion. Fraudulent wallet top-ups may result in account termination.",
          ),
          
          // 13. Promotions, Offers & Rebates
          _buildSection(
            "13. Promotions, Offers & Rebates",
            "CLASSY UG may offer promotional discounts, referral rewards, and rebates. Rebates of up to 5% of service fees are credited back to Wallets where applicable. CLASSY UG reserves the right to modify or revoke promotional offers without prior notice.",
          ),
          
          // 14. Use of the Application
          _buildSection(
            "14. Use of the Application",
            "The app is licensed to you, not sold. Users may not copy, reverse-engineer, distribute, or interfere with the app's operation. We grant you a limited, non-exclusive, non-transferable license to use the Service on your personal mobile device.",
          ),
          
          // 15. User Responsibilities
          _buildSection(
            "15. User Responsibilities",
            "Users agree to:",
            bullets: [
              "Use the Service only for lawful purposes",
              "Treat Drivers, Couriers, and Vendors respectfully",
              "Not share account credentials with others",
              "Immediately report suspicious activity to support@classyug.com",
            ],
          ),
          
          // 16. Prohibited Conduct
          _buildSection(
            "16. Prohibited Conduct",
            "You may not use the Service to:",
            bullets: [
              "Violate any applicable law or regulation",
              "Harass, abuse, or harm another person",
              "Impersonate another individual or falsify information",
              "Upload malware or harmful software",
              "Interfere with the platform's integrity or servers",
            ],
          ),
          
          // 17. Intellectual Property
          _buildSection(
            "17. Intellectual Property",
            "All content on the platform, including logos, software, branding, and graphics, is the property of Classic Net Uganda Limited or its licensors. Unauthorized use, reproduction, or redistribution is strictly prohibited.",
          ),
          
          // 18. Privacy and Data Protection
          _buildSection(
            "18. Privacy and Data Protection",
            "Your use of the Service is governed by our Privacy Policy. We collect and process your data in accordance with Uganda's Data Protection and Privacy Act, 2019. This includes location data, payment information, and service history to enhance app functionality.",
          ),
          
          // 19. Third-Party Services
          _buildSection(
            "19. Third-Party Services",
            "CLASSY UG integrates with third-party tools, such as payment processors, airlines, and map providers. While we strive for secure integrations, we do not control external providers and are not liable for their actions or content.",
          ),
          
          // 20. Limitation of Liability
          _buildSection(
            "20. Limitation of Liability",
            "To the fullest extent permitted by law, CLASSY UG is not liable for:",
            bullets: [
              "Damages or injuries resulting from third-party actions",
              "Missed flights, delays, or miscommunications",
              "Food allergies, poor product quality, or vendor negligence",
              "Losses from unauthorized account access",
            ],
          ),
          
          // 21. Indemnification
          _buildSection(
            "21. Indemnification",
            "You agree to indemnify and hold harmless Classic Net Uganda Limited, its officers, agents, employees, and affiliates from any claims, liabilities, damages, and expenses arising from your misuse of the Service or breach of these Terms.",
          ),
          
          // 22. Disclaimers
          _buildSection(
            "22. Disclaimers",
            "The Service is provided \"as is\" and \"as available\" without warranties of any kind. CLASSY UG disclaims all warranties, express or implied, including fitness for a particular purpose, accuracy, or non-infringement.",
          ),
          
          // 23. Suspension and Termination
          _buildSection(
            "23. Suspension and Termination",
            "We may suspend or terminate access to your account at any time, with or without notice, for conduct that we believe violates these Terms or harms other users. Users may delete their accounts at any time via the app or by contacting support.",
          ),
          
          // 24. Governing Law
          _buildSection(
            "24. Governing Law",
            "These Terms are governed by the laws of the Republic of Uganda. Any disputes shall be resolved in Ugandan courts, without regard to conflict of law principles.",
          ),
          
          // 25. Dispute Resolution
          _buildSection(
            "25. Dispute Resolution",
            "In the event of a dispute, parties agree to attempt informal resolution by contacting support@classyug.com. If unresolved, disputes will be submitted to arbitration under the Uganda Arbitration and Conciliation Act.",
          ),
          
          // 26. Changes to the Terms
          _buildSection(
            "26. Changes to the Terms",
            "We reserve the right to update these Terms at any time. Changes will be posted within the app or on the website. Continued use of the Service after any modifications constitutes your acceptance of the revised Terms.",
          ),
          
          // 27. Contact Information
          _buildSection(
            "27. Contact Information",
            "If you have any questions about these Terms, reach us at:",
            contactInfo: [
              "Email: support@classyug.com",
              "Phone: +256 762 992 378",
              "Address: Kyanja, Kampala, Uganda, P.O. Box 200550",
            ],
          ),
          
          // 28. Entire Agreement
          _buildSection(
            "28. Entire Agreement",
            "These Terms, together with the Privacy Policy and other legal notices published by CLASSY UG, constitute the entire agreement between you and Classic Net Uganda Limited regarding the Service.",
          ),
          
          // 29. Severability
          _buildSection(
            "29. Severability",
            "If any provision of these Terms is found to be unlawful, void, or unenforceable, that provision will be deemed severable and will not affect the validity and enforceability of the remaining provisions.",
          ),
          
          // 30. Force Majeure
          _buildSection(
            "30. Force Majeure",
            "CLASSY UG shall not be liable for delays or failure in performance resulting from acts beyond our reasonable control, including but not limited to natural disasters, internet outages, war, or changes in laws.",
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
              "THANK YOU FOR USING CLASSY UG".text.lg.bold.color(AppColor.primaryColor).make(),
              UiSpacer.verticalSpace(space: 8),
              "Live Future. Drive Forward.".text.italic.color(AppColor.primaryColor).make(),
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
