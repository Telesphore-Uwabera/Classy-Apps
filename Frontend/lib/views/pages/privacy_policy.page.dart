import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
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
          "Privacy Policy – CLASSY UG".text.xl2.bold.color(AppColor.primaryColor).make(),
          UiSpacer.verticalSpace(space: 8),
          "Last Updated: July 21, 2025".text.sm.gray600.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // Introduction paragraph
          "This Privacy Policy describes how CLASSY UG (\"we,\" \"our,\" \"us\") collects, uses, shares, and protects information about our users (\"you,\" \"your\") through our mobile application, web platform, and related services (collectively, the \"Platform\"). This Policy complies with the Data Protection and Privacy Act, 2019 of Uganda and other relevant legal frameworks."
              .text.make(),
          UiSpacer.verticalSpace(space: 20),
          
          // 1. INTRODUCTION
          _buildSection(
            "1. INTRODUCTION",
            "CLASSY UG is committed to protecting your privacy and ensuring that your personal information is handled in a secure, lawful, and transparent manner. This Privacy Policy explains how we collect, use, and safeguard your personal data when you interact with our services, including ride-hailing, food and agro supply delivery, boda boda transportation, and domestic flight booking. Your use of our Platform confirms your consent to this Policy.",
          ),
          
          // 2. DEFINITIONS
          _buildSection(
            "2. DEFINITIONS",
            null,
            bullets: [
              "\"Personal Data\" means any information relating to an identified or identifiable natural person.",
              "\"Processing\" means any operation or set of operations which is performed on personal data or on sets of personal data.",
              "\"Controller\" means CLASSY UG, who determines the purposes and means of the processing of personal data.",
              "\"Data Subject\" means any individual whose personal data is collected.",
              "\"Third Party\" means any natural or legal person, authority, or agency other than the data subject, controller, processor, or person authorized to process personal data under the direct authority of the controller.",
            ],
          ),
          
          // 3. INFORMATION WE COLLECT
          _buildSection(
            "3. INFORMATION WE COLLECT",
            "We collect the following categories of data:",
            subSections: [
              "a) Identity Data\n• Full name, date of birth, national ID/passport number\n• Profile photo",
              "b) Contact Data\n• Mobile phone number\n• Email address\n• Home or office address",
              "c) Device and Technical Data\n• IP address\n• Device type and OS\n• App usage logs\n• Cookies and tracking pixels",
              "d) Transaction Data\n• Mobile money payment records (MTN, Airtel)\n• Card top-ups and fare transactions\n• Booking history",
              "e) Geolocation Data\n• Live GPS data for rides and deliveries\n• Saved addresses (home, work)",
              "f) Communications\n• Customer support messages\n• Emails and feedback",
              "g) Biometric (Optional)\n• Facial recognition for secure login (if enabled)",
            ],
            footer: "We only collect data that is necessary and directly relevant to the service we offer.",
          ),
          
          // 4. HOW WE COLLECT DATA
          _buildSection(
            "4. HOW WE COLLECT DATA",
            "We collect your data through:",
            bullets: [
              "Direct input when signing up or updating your profile",
              "Use of the app and its features",
              "Automatic tracking (e.g., location or cookies)",
              "Third parties (e.g., payment providers or authentication services)",
            ],
          ),
          
          // 5. LEGAL BASIS FOR PROCESSING
          _buildSection(
            "5. LEGAL BASIS FOR PROCESSING",
            "We process your data on the following grounds:",
            bullets: [
              "Consent – where required by law (e.g., marketing, location sharing)",
              "Contractual necessity – to deliver services as agreed",
              "Legal obligation – compliance with Uganda Revenue Authority (URA), Financial Intelligence Authority (FIA), or UCC",
              "Legitimate interest – fraud detection, customer support, and service improvement",
            ],
          ),
          
          // 6. HOW WE USE YOUR DATA
          _buildSection(
            "6. HOW WE USE YOUR DATA",
            "Your personal data is used to:",
            bullets: [
              "Facilitate and manage ride requests, food deliveries, and bookings",
              "Verify identity and payment credentials",
              "Communicate with you about services or updates",
              "Provide customer support and dispute resolution",
              "Prevent and detect fraud or unauthorized access",
              "Improve user experience and service offerings",
            ],
            footer: "We may use data analytics to enhance efficiency, safety, and quality.",
          ),
          
          // 7. DATA SHARING & THIRD PARTIES
          _buildSection(
            "7. DATA SHARING & THIRD PARTIES",
            "We only share data with:",
            bullets: [
              "Drivers & delivery agents – limited access to necessary info (name, pickup point)",
              "Payment processors – mobile money integrators (MTN, Airtel)",
              "Airline or third-party service providers – in case of flight bookings",
              "Legal authorities – if required under the law or court order",
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
            ],
            footer: "We do not transfer your personal data outside Uganda unless necessary and secured.",
          ),
          
          // 9. YOUR RIGHTS
          _buildSection(
            "9. YOUR RIGHTS UNDER THE UGANDA DATA PROTECTION AND PRIVACY ACT, 2019",
            "As a data subject, you have the right to:",
            bullets: [
              "Access your personal data held by CLASSY UG",
              "Rectify inaccurate or outdated information",
              "Delete your data when no longer needed",
              "Restrict processing in certain circumstances",
              "Object to processing for direct marketing",
              "Withdraw consent at any time",
              "Lodge a complaint with the Personal Data Protection Office (PDPO)",
            ],
            footer: "You can exercise your rights by contacting:\n📩 support@classyug.com",
          ),
          
          // 10. DATA RETENTION
          _buildSection(
            "10. DATA RETENTION",
            "We retain your personal data for:",
            bullets: [
              "As long as your account is active",
              "6 years after the last transaction (for legal compliance)",
              "Longer if required by URA, UCC, or in ongoing legal matters",
            ],
            footer: "We securely delete or anonymize data when retention is no longer needed.",
          ),
          
          // 11. COOKIES & TRACKING
          _buildSection(
            "11. COOKIES & TRACKING",
            "CLASSY UG uses cookies to:",
            bullets: [
              "Store user sessions",
              "Remember preferences",
              "Track app usage for analytics",
            ],
            footer: "You can disable cookies in browser settings, but it may affect app functionality.",
          ),
          
          // 12. SECURITY MEASURES
          _buildSection(
            "12. SECURITY MEASURES",
            "We implement industry-grade safeguards:",
            bullets: [
              "End-to-end encryption",
              "Biometric authentication (optional)",
              "Secure socket layer (SSL) for data transmission",
              "Access control and audit logging",
              "Regular vulnerability assessments",
            ],
          ),
          
          // 13. CHILDREN'S PRIVACY
          _buildSection(
            "13. CHILDREN'S PRIVACY",
            "Our services are not intended for individuals under 18 years. We do not knowingly collect data from minors. If discovered, we delete it promptly.",
          ),
          
          // 14. AUTOMATED DECISION-MAKING
          _buildSection(
            "14. AUTOMATED DECISION-MAKING",
            "We may use algorithms to:",
            bullets: [
              "Assign closest drivers",
              "Estimate fares",
              "Detect fraud or risky behaviors",
            ],
            footer: "These decisions are regularly reviewed by human supervisors.",
          ),
          
          // 15. MARKETING & PROMOTIONS
          _buildSection(
            "15. MARKETING & PROMOTIONS",
            "You may receive marketing emails or SMS about:",
            bullets: [
              "Special offers",
              "New services",
              "Partner campaigns",
            ],
            footer: "You can opt-out anytime via your account settings or by emailing support@classyug.com.",
          ),
          
          // 16. THIRD-PARTY LINKS
          _buildSection(
            "16. THIRD-PARTY LINKS",
            "Our app may contain links to other platforms (e.g., airline portals or partner services). We are not responsible for their privacy practices.",
          ),
          
          // 17. CHANGES TO THIS POLICY
          _buildSection(
            "17. CHANGES TO THIS POLICY",
            "We may update this Policy as laws or services change. All updates will be posted in-app and on our website. Material changes will be notified directly.",
          ),
          
          // 18. CONTACT US
          _buildSection(
            "18. CONTACT US",
            "If you have any questions or complaints regarding privacy:",
            contactInfo: [
              "CLASSY UG – Privacy Team",
              "📩 Email: support@classyug.com",
              "📩 Address: Classic Net Uganda Limited\nP.O. Box 200550, Kyanja, Kampala, Uganda",
              "📩 Tel: +256 762 992 376",
              "📩 Website: https://classyug.com",
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
            child: "📩 CLASSY UG values your trust. We ensure your personal data is protected through stringent protocols. Our compliance with the Data Protection and Privacy Act (2019) means your rights are safeguarded, including your right to access, rectify, and erase your data. Our privacy practices reflect international best standards, guaranteeing security, transparency, and accountability in all digital transactions."
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
