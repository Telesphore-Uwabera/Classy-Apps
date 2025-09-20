import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'utils/ui_spacer.dart';
import 'widgets/base.page.dart';
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
          "Privacy Policy – CLASSY UG Vendor Platform".text.xl2.bold.color(AppColor.primaryColor).make(),
          UiSpacer.verticalSpace(space: 8),
          "Last Updated: July 21, 2025".text.sm.gray600.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // Introduction paragraph
          "This Privacy Policy describes how CLASSY UG (\"we,\" \"our,\" \"us\") collects, uses, shares, and protects information about our vendors (\"you,\" \"your\") through our vendor mobile application, vendor portal, and related services (collectively, the \"Platform\"). This Policy complies with the Data Protection and Privacy Act, 2019 of Uganda and other relevant legal frameworks."
              .text.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // 1. INTRODUCTION
          _buildSection(
            "1. INTRODUCTION",
            "CLASSY UG is committed to protecting your privacy and ensuring that your business and personal information is handled in a secure, lawful, and transparent manner. This Privacy Policy explains how we collect, use, and safeguard your data when you interact with our vendor services, including food delivery, agro supply delivery, and business management tools. Your use of our Platform confirms your consent to this Policy.",
          ),
          
          // 2. DEFINITIONS
          _buildSection(
            "2. DEFINITIONS",
            null,
            bullets: [
              "\"Vendor Data\" means any information relating to your business operations and services.",
              "\"Processing\" means any operation or set of operations which is performed on vendor data.",
              "\"Controller\" means CLASSY UG, who determines the purposes and means of the processing of vendor data.",
              "\"Data Subject\" means any vendor whose data is collected.",
              "\"Third Party\" means any natural or legal person, authority, or agency other than the vendor, controller, or processor.",
            ],
          ),
          
          // 3. INFORMATION WE COLLECT
          _buildSection(
            "3. INFORMATION WE COLLECT",
            "We collect the following categories of vendor data:",
            subSections: [
              "a) Business Identity Data\n• Business name, registration number, tax ID\n• Business address and contact information\n• Business license and certification details",
              "b) Personal Data\n• Owner/manager name, phone number, email\n• Profile photo and identification documents\n• Emergency contact information",
              "c) Business Operations Data\n• Menu items, product catalogs, pricing\n• Business hours and service areas\n• Order history and performance metrics",
              "d) Financial Data\n• Bank account details for settlements\n• Transaction records and commission calculations\n• Tax and compliance documentation",
              "e) Technical Data\n• Device information and app usage logs\n• IP address and location data\n• Cookies and tracking pixels",
              "f) Communications\n• Customer support interactions\n• Business communications and updates",
            ],
            footer: "We only collect data that is necessary for providing vendor services and platform management.",
          ),
          
          // 4. HOW WE COLLECT DATA
          _buildSection(
            "4. HOW WE COLLECT DATA",
            "We collect your data through:",
            bullets: [
              "Direct input during vendor registration and onboarding",
              "Use of the vendor app and portal features",
              "Business operations and order processing",
              "Customer feedback and ratings",
              "Third-party verification services",
              "Automated tracking and analytics",
            ],
          ),
          
          // 5. LEGAL BASIS FOR PROCESSING
          _buildSection(
            "5. LEGAL BASIS FOR PROCESSING",
            "We process your data on the following grounds:",
            bullets: [
              "Contractual necessity – to provide vendor services as agreed",
              "Legal obligation – compliance with URA, UCC, and other regulations",
              "Legitimate interest – platform management and service improvement",
              "Consent – for marketing and promotional communications",
            ],
          ),
          
          // 6. HOW WE USE YOUR DATA
          _buildSection(
            "6. HOW WE USE YOUR DATA",
            "Your vendor data is used to:",
            bullets: [
              "Facilitate and manage vendor services on the platform",
              "Process orders and manage customer interactions",
              "Calculate commissions and process settlements",
              "Provide business analytics and performance insights",
              "Ensure compliance with platform policies and regulations",
              "Improve vendor experience and service offerings",
              "Handle customer support and dispute resolution",
            ],
            footer: "We may use data analytics to enhance platform efficiency and vendor success.",
          ),
          
          // 7. DATA SHARING & THIRD PARTIES
          _buildSection(
            "7. DATA SHARING & THIRD PARTIES",
            "We only share vendor data with:",
            bullets: [
              "Customers – limited business information (name, menu, ratings)",
              "Delivery partners – necessary order details for fulfillment",
              "Payment processors – settlement and financial information",
              "Legal authorities – if required under law or court order",
              "Data storage and hosting providers – under strict confidentiality terms",
            ],
            footer: "All third parties must follow data protection policies aligned with Uganda's law.",
          ),
          
          // 8. INTERNATIONAL TRANSFERS
          _buildSection(
            "8. INTERNATIONAL TRANSFERS",
            "Although our primary servers are in Uganda, some data may be processed abroad (e.g., backup or third-party APIs). We ensure:",
            bullets: [
              "Adequate data protection laws in destination countries",
              "Standard contractual clauses with foreign partners",
              "Data encryption during transmission",
            ],
            footer: "We do not transfer your vendor data outside Uganda unless necessary and secured.",
          ),
          
          // 9. YOUR RIGHTS
          _buildSection(
            "9. YOUR RIGHTS UNDER THE UGANDA DATA PROTECTION AND PRIVACY ACT, 2019",
            "As a vendor, you have the right to:",
            bullets: [
              "Access your business and personal data held by CLASSY UG",
              "Rectify inaccurate or outdated information",
              "Delete your data when no longer needed",
              "Restrict processing in certain circumstances",
              "Object to processing for direct marketing",
              "Withdraw consent at any time",
              "Lodge a complaint with the Personal Data Protection Office (PDPO)",
            ],
            footer: "You can exercise your rights by contacting:\n📩 vendors@classyug.com",
          ),
          
          // 10. DATA RETENTION
          _buildSection(
            "10. DATA RETENTION",
            "We retain your vendor data for:",
            bullets: [
              "As long as your vendor account is active",
              "6 years after the last transaction (for legal compliance)",
              "Longer if required by URA, UCC, or in ongoing legal matters",
              "Business analytics and platform improvement purposes",
            ],
            footer: "We securely delete or anonymize data when retention is no longer needed.",
          ),
          
          // 11. COOKIES & TRACKING
          _buildSection(
            "11. COOKIES & TRACKING",
            "CLASSY UG uses cookies to:",
            bullets: [
              "Store vendor session information",
              "Remember business preferences and settings",
              "Track app usage for analytics and improvement",
              "Ensure secure platform access",
            ],
            footer: "You can disable cookies in browser settings, but it may affect platform functionality.",
          ),
          
          // 12. SECURITY MEASURES
          _buildSection(
            "12. SECURITY MEASURES",
            "We implement industry-grade safeguards:",
            bullets: [
              "End-to-end encryption for all data transmission",
              "Secure authentication and access controls",
              "Regular security audits and vulnerability assessments",
              "Data backup and disaster recovery procedures",
              "Employee training on data protection",
              "Incident response and breach notification protocols",
            ],
          ),
          
          // 13. BUSINESS DATA PROTECTION
          _buildSection(
            "13. BUSINESS DATA PROTECTION",
            "We protect your business information through:",
            bullets: [
              "Confidentiality agreements with all staff",
              "Secure data centers with physical security",
              "Regular penetration testing and security reviews",
              "Compliance with international security standards",
              "24/7 monitoring and threat detection",
            ],
          ),
          
          // 14. AUTOMATED DECISION-MAKING
          _buildSection(
            "14. AUTOMATED DECISION-MAKING",
            "We may use algorithms to:",
            bullets: [
              "Calculate delivery fees and commission rates",
              "Assign orders to optimal delivery partners",
              "Analyze vendor performance and ratings",
              "Detect fraudulent activities or policy violations",
            ],
            footer: "These decisions are regularly reviewed by human supervisors and can be appealed.",
          ),
          
          // 15. MARKETING & PROMOTIONS
          _buildSection(
            "15. MARKETING & PROMOTIONS",
            "You may receive business-related communications about:",
            bullets: [
              "Platform updates and new features",
              "Promotional opportunities and campaigns",
              "Business insights and market trends",
              "Training and support resources",
            ],
            footer: "You can opt-out anytime via your vendor portal settings or by emailing vendors@classyug.com.",
          ),
          
          // 16. THIRD-PARTY LINKS
          _buildSection(
            "16. THIRD-PARTY LINKS",
            "Our vendor portal may contain links to other platforms (e.g., payment processors or business tools). We are not responsible for their privacy practices.",
          ),
          
          // 17. CHANGES TO THIS POLICY
          _buildSection(
            "17. CHANGES TO THIS POLICY",
            "We may update this Policy as laws or services change. All updates will be posted in the vendor portal and communicated via email. Material changes will be notified directly.",
          ),
          
          // 18. CONTACT US
          _buildSection(
            "18. CONTACT US",
            "If you have any questions or complaints regarding privacy:",
            contactInfo: [
              "CLASSY UG – Vendor Privacy Team",
              "📩 Email: vendors@classyug.com",
              "📩 Address: Classic Net Uganda Limited\nP.O. Box 200550, Kyanja, Kampala, Uganda",
              "📩 Tel: +256 762 992 376",
              "📩 Website: https://classyug.com",
              "📩 Vendor Support Hours: 8:00 AM - 8:00 PM (EAT)",
            ],
          ),
          
          // 19. LEGAL COMPLIANCE
          _buildSection(
            "19. ANNEX: LEGAL COMPLIANCE",
            "This Privacy Policy complies with:",
            bullets: [
              "The Constitution of the Republic of Uganda (1995)",
              "The Data Protection and Privacy Act, 2019",
              "The Computer Misuse Act, 2011",
              "The Electronic Transactions Act, 2011",
              "Uganda Communications Act, 2013",
              "Anti-Money Laundering Act, 2013",
              "Business Registration Act, 2014",
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
            child: "📩 CLASSY UG values your trust as a business partner. We ensure your business and personal data is protected through stringent protocols. Our compliance with the Data Protection and Privacy Act (2019) means your rights are safeguarded, including your right to access, rectify, and erase your data. Our privacy practices reflect international best standards, guaranteeing security, transparency, and accountability in all business operations."
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
