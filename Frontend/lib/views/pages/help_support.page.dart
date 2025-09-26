import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Classy/widgets/bottomsheets/emergency_contacts.bottomsheet.dart';
import 'package:Classy/widgets/bottomsheets/report_issue.bottomsheet.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Help & Support'.tr(),
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: VStack([
          UiSpacer.verticalSpace(space: 20),
          _CustomerSupportSection(),
          UiSpacer.verticalSpace(space: 30),
        _FaqsSection(),
        ]).px20(),
      ),
    );
  }
}

class _CustomerSupportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: VStack([
        // Header with icon and title
        HStack([
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.headset_mic,
              color: AppColor.primaryColor,
              size: 24,
            ),
          ),
          UiSpacer.horizontalSpace(space: 12),
          "Customer Support".tr().text.bold.xl.make(),
        ]).py16(),
        
        Divider(color: Colors.grey.shade200, height: 1),
        
        UiSpacer.verticalSpace(space: 20),
        
        // Support options grid
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1, // Standard ratio for support tiles
          children: [
            _SupportTile(
              icon: Icons.headset_mic_outlined,
              iconColor: AppColor.primaryColor,
              backgroundColor: AppColor.primaryColor.withOpacity(0.1),
              title: "Contact",
              onTap: () => _showContactSupportModal(context),
            ),
            _SupportTile(
              icon: Icons.chat_bubble_outline,
              iconColor: Colors.green,
              backgroundColor: Colors.green.withOpacity(0.1),
              title: "WhatsApp",
              onTap: () => _showWhatsAppModal(context),
            ),
            _SupportTile(
              icon: Icons.warning_outlined,
              iconColor: AppColor.primaryColor,
              backgroundColor: AppColor.primaryColor.withOpacity(0.1),
              title: "Report",
              onTap: () => _showReportIssueModal(context),
            ),
            _SupportTile(
              icon: Icons.emergency,
              iconColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
              title: "Emergency",
              onTap: () => _showEmergencyContactsModal(context),
            ),
          ],
        ),
        
        UiSpacer.verticalSpace(space: 20),
      ]).px20(),
    );
  }
  
  void _showContactSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ContactSupportModal();
      },
    );
  }
  
  void _showEmergencyContactsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _EmergencyContactsModal();
      },
    );
  }
  
  void _showReportIssueModal(BuildContext context) {
    showModalBottomSheet(
                context: context,
                isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ReportIssueModal();
      },
    );
  }
  
  void _showWhatsAppModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _WhatsAppModal();
      },
    );
  }
  

  

  

  

}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 120, // Standard height for support tiles
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
      onTap: onTap,
          borderRadius: BorderRadius.circular(12),
        child: VStack([
            UiSpacer.verticalSpace(space: 16),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            UiSpacer.verticalSpace(space: 12),
            title.text.bold.make(),
            if (subtitle != null) ...[
              UiSpacer.verticalSpace(space: 4),
              subtitle!.text.size(12).color(Colors.grey.shade600).make(),
            ],
            UiSpacer.verticalSpace(space: 16),
        ]).centered(),
        ),
      ),
    );
  }
}

class _FaqsSection extends StatefulWidget {
  @override
  _FaqsSectionState createState() => _FaqsSectionState();
}

class _FaqsSectionState extends State<_FaqsSection> {
  int selectedCategoryIndex = 0;
  
  final List<Map<String, dynamic>> _faqData = [
    // Account & Profile FAQs
    {
      'category': 0,
      'question': 'How do I edit my profile?',
      'answer': 'Go to your profile section and tap the "Edit Profile" button. You can update your name, phone number, and profile picture from there.',
    },
    {
      'category': 0,
      'question': 'How do I change my phone number?',
      'answer': 'You can change your phone number in the edit profile section. Make sure to verify the new number for security purposes.',
    },
    {
      'category': 0,
      'question': 'How do I update my profile picture?',
      'answer': 'In the edit profile section, tap on your current profile picture to select a new one from your gallery or take a new photo.',
    },
    {
      'category': 0,
      'question': 'How do I change my password?',
      'answer': 'Go to Settings > Security > Change Password. Enter your current password and then your new password twice to confirm.',
    },
    
    // Rides & Bookings FAQs
    {
      'category': 1,
      'question': 'How do I book a ride?',
      'answer': 'To book a ride, open the app and select your desired service (Taxi or Boda). Enter your pickup location and destination, then tap "Request Ride". You can also schedule a ride for later by selecting the "Schedule" option.',
    },
    {
      'category': 1,
      'question': 'How do I cancel a ride?',
      'answer': 'You can cancel a ride by tapping the "Cancel Ride" button in the ride details. Note that cancellation fees may apply depending on the timing.',
    },
    {
      'category': 1,
      'question': 'How do I track my ride?',
      'answer': 'Once your ride is confirmed, you can track your driver\'s location in real-time on the map. You\'ll also receive updates about the driver\'s arrival.',
    },
    {
      'category': 1,
      'question': 'How do I rate my driver?',
      'answer': 'After completing your ride, you\'ll be prompted to rate your driver and leave a review. This helps us maintain service quality.',
    },
    {
      'category': 1,
      'question': 'What payment methods are accepted?',
      'answer': 'We accept cash, mobile money, and credit/debit cards. You can set your preferred payment method in the app settings.',
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    return _faqData.where((faq) => faq['category'] == selectedCategoryIndex).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: VStack([
        // Header with icon and title
        HStack([
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              color: AppColor.primaryColor,
              size: 24,
            ),
          ),
          UiSpacer.horizontalSpace(space: 12),
          "Frequently Asked Questions".tr().text.bold.xl.make(),
        ]).py16(),
        
        Divider(color: Colors.grey.shade200, height: 1),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Category chips
        _CategoryChips(
          ['Account & Profile'.tr(), 'Rides & Bookings'.tr()],
          selectedIndex: selectedCategoryIndex,
          onCategoryChanged: (index) {
            setState(() {
              selectedCategoryIndex = index;
            });
          },
        ),
        
        UiSpacer.verticalSpace(space: 16),
        
        // FAQ items based on selected category
        for (var faq in _filteredFaqs)
          _FaqItem(faq['question'].toString().tr(), faq['answer'].toString().tr()),
        
        UiSpacer.verticalSpace(space: 16),
      ]).px20(),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips(this.items, {required this.selectedIndex, required this.onCategoryChanged});
  final List<String> items;
  final int selectedIndex;
  final Function(int) onCategoryChanged;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onCategoryChanged(i);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedIndex == i 
                          ? AppColor.primaryColor 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: items[i].text
                        .color(selectedIndex == i ? Colors.white : Colors.grey.shade600)
                        .make()
                        .centered(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem(this.question, this.answer);
  final String question;
  final String answer;
  
  @override
  _FaqItemState createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: VStack([
            HStack([
              Expanded(
                child: widget.question.text.make(),
              ),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColor.primaryColor,
              ),
            ]).py12(),
            
            if (isExpanded) ...[
              UiSpacer.verticalSpace(space: 8),
              widget.answer.text.color(Colors.grey.shade600).make().py12(),
            ],
          ]),
        ),
      ),
    );
  }
}

class _ContactSupportModal extends StatefulWidget {
  @override
  _ContactSupportModalState createState() => _ContactSupportModalState();
}

class _ContactSupportModalState extends State<_ContactSupportModal> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              HStack([
                "Contact Support".tr().text.bold.xl.make(),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ]).py16(),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Form
              Form(
                key: _formKey,
                child: VStack([
                  // Subject field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: "Subject".tr(),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 16),
                  
                  // Message field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: "Message".tr(),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a message'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 24),
                  
                  // Submit button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitContactForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                UiSpacer.horizontalSpace(space: 12),
                                "Submitting...".tr().text.color(Colors.white).bold.make(),
                              ],
                            )
                          : "Submit".tr().text.color(Colors.white).bold.make(),
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 16),
                  
                  // WhatsApp contact option
                  Container(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchWhatsAppFromContact(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.chat_bubble_outline),
                      label: "Contact via WhatsApp".tr().text.color(Colors.green).bold.make(),
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 20),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _launchWhatsAppFromContact() async {
    const phoneNumber = '+256759968209';
    const message = 'Hello! I need help with the Classy app.';
    
    // WhatsApp URL format
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      final canLaunch = await canLaunchUrlString(whatsappUrl);
      if (canLaunch) {
        await launchUrlString(whatsappUrl);
      } else {
        // Fallback: try to open WhatsApp app directly
        final fallbackUrl = 'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';
        final canLaunchFallback = await canLaunchUrlString(fallbackUrl);
        if (canLaunchFallback) {
          await launchUrlString(fallbackUrl);
        }
      }
    } catch (e) {
      // Silently fail for contact form
    }
  }
  
  Future<void> _submitContactForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent successfully!'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      
      // Close modal
      Navigator.of(context).pop();
      
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message. Please try again.'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class _EmergencyContactsModal extends StatelessWidget {
  void _launchWhatsAppFromEmergency() async {
    const phoneNumber = '+256759968209';
    const message = 'Hello! I need emergency help with the Classy app.';
    
    // WhatsApp URL format
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      final canLaunch = await canLaunchUrlString(whatsappUrl);
      if (canLaunch) {
        await launchUrlString(whatsappUrl);
      } else {
        // Fallback: try to open WhatsApp app directly
        final fallbackUrl = 'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';
        final canLaunchFallback = await canLaunchUrlString(fallbackUrl);
        if (canLaunchFallback) {
          await launchUrlString(fallbackUrl);
        }
      }
    } catch (e) {
      // Silently fail for emergency contacts
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and emergency icon
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: HStack([
              Icon(
                Icons.emergency,
                color: Colors.red,
                size: 28,
              ),
              UiSpacer.horizontalSpace(space: 12),
              "Emergency Contact".tr().text.bold.xl.make(),
            ]),
          ),
          
          // Emergency contacts list
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: VStack([
              // Police
              _EmergencyContactItem(
                icon: Icons.shield,
                iconColor: Colors.red,
                title: "Police",
                number: "999",
                onTap: () => launchUrlString('tel:999'),
              ),
              
              UiSpacer.verticalSpace(space: 16),
              
              // Ambulance
              _EmergencyContactItem(
                icon: Icons.medical_services,
                iconColor: Colors.red,
                title: "Ambulance",
                number: "997",
                onTap: () => launchUrlString('tel:997'),
              ),
              
              UiSpacer.verticalSpace(space: 16),
              
              // Customer Support
              _EmergencyContactItem(
                icon: Icons.headset_mic,
                iconColor: Colors.red,
                title: "Customer Support",
                number: "+256 759 968209",
                onTap: () => launchUrlString('tel:+256759968209'),
              ),
              
              UiSpacer.verticalSpace(space: 16),
              
              // WhatsApp Support
              _EmergencyContactItem(
                icon: Icons.chat_bubble_outline,
                iconColor: Colors.green,
                title: "WhatsApp Support",
                number: "+256 759 968209",
                onTap: () => _launchWhatsAppFromEmergency(),
              ),
            ]),
          ),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Close button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
      children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: "CLOSE".tr().text.color(Colors.red).bold.make(),
                ),
              ],
            ),
          ),
          
          UiSpacer.verticalSpace(space: 20),
        ],
      ),
    );
  }
}

class _EmergencyContactItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String number;
  final VoidCallback onTap;
  
  const _EmergencyContactItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.number,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: HStack([
        // Icon
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        
        UiSpacer.horizontalSpace(space: 16),
        
        // Title and number
        Expanded(
          child: VStack([
            title.text.bold.make(),
            UiSpacer.verticalSpace(space: 4),
            number.text.color(Colors.grey.shade600).make(),
          ]),
        ),
        
        // Phone icon button
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Icon(
              Icons.phone,
              color: Colors.red,
              size: 20,
            ),
          ),
        ),
      ]),
    );
  }
}

class _ReportIssueModal extends StatefulWidget {
  @override
  _ReportIssueModalState createState() => _ReportIssueModalState();
}

class _ReportIssueModalState extends State<_ReportIssueModal> {
  String? _selectedIssueType;
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'Payment Issue',
    'Driver Behavior',
    'App Problem',
    'Lost Item',
    'Ride Quality',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              HStack([
                "Report an Issue".tr().text.bold.xl.make(),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ]).py16(),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Form
              Form(
                key: _formKey,
                child: VStack([
                  // Issue Type Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedIssueType,
                      decoration: InputDecoration(
                        labelText: "Select Issue Type *".tr(),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                      ),
                      items: _issueTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedIssueType = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an issue type'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 16),
                  
                  // Ride ID field (Optional)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Ride ID (Optional)".tr(),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 16),
                  
                  // Description field (Required)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description *".tr(),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 24),
                  
                  // Submit button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                UiSpacer.horizontalSpace(space: 12),
                                "Submitting...".tr().text.color(Colors.white).bold.make(),
                              ],
                            )
                          : "Submit".tr().text.color(Colors.white).bold.make(),
                    ),
                  ),
                  
                  UiSpacer.verticalSpace(space: 20),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Additional validation for required fields
    if (_selectedIssueType == null || _selectedIssueType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an issue type'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a description'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Issue reported successfully!'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      
      // Close modal
      Navigator.of(context).pop();
      
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to report issue. Please try again.'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class _WhatsAppModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              HStack([
                HStack([
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                  UiSpacer.horizontalSpace(space: 12),
                  "WhatsApp Support".tr().text.bold.xl.make(),
                ]),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ]).py16(),
              
              UiSpacer.verticalSpace(space: 20),
              
              // WhatsApp info
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: VStack([
                  HStack([
                    Icon(
                      Icons.phone,
                      color: Colors.green,
                      size: 24,
                    ),
                    UiSpacer.horizontalSpace(space: 12),
                    "Contact Number".tr().text.bold.make(),
                  ]),
                  UiSpacer.verticalSpace(space: 8),
                  "+256 759 968209".text.color(Colors.green).bold.size(18).make(),
                  UiSpacer.verticalSpace(space: 16),
                  "Tap the button below to open WhatsApp with this number.".tr().text.color(Colors.grey.shade600).make(),
                ]),
              ),
              
              UiSpacer.verticalSpace(space: 24),
              
              // Open WhatsApp button
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchWhatsApp(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.chat_bubble_outline),
                  label: "Open WhatsApp".tr().text.color(Colors.white).bold.make(),
                ),
              ),
              
              UiSpacer.verticalSpace(space: 16),
              
              // Copy number button
              Container(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '+256 759 968209'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Phone number copied to clipboard!'.tr()),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.copy),
                  label: "Copy Number".tr().text.color(Colors.green).bold.make(),
                ),
              ),
              
              UiSpacer.verticalSpace(space: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  void _launchWhatsApp(BuildContext context) async {
    const phoneNumber = '+256759968209';
    const message = 'Hello! I need help with the Classy app.';
    
    // WhatsApp URL format for web
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      print('🔗 Attempting to launch WhatsApp URL: $whatsappUrl');
      
      // For web browsers, we need to use mode: LaunchMode.externalApplication
      bool launched = false;
      
      try {
        // Try to open WhatsApp web URL in external application (new tab)
        launched = await launchUrlString(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
        print('✅ WhatsApp launch with external mode completed: $launched');
      } catch (e) {
        print('❌ External launch failed: $e');
        
        // Fallback: try default mode
        try {
          launched = await launchUrlString(whatsappUrl);
          print('✅ WhatsApp launch with default mode completed: $launched');
        } catch (e2) {
          print('❌ Default launch failed: $e2');
        }
      }
      
      if (launched) {
        print('✅ WhatsApp launched successfully');
        Navigator.of(context).pop(); // Close modal on success
      } else {
        print('❌ Failed to launch WhatsApp');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp. Please copy the number and open WhatsApp manually.'.tr()),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ Error launching WhatsApp: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening WhatsApp. Please copy the number and open WhatsApp manually.'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}