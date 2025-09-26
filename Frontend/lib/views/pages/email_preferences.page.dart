import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EmailPreferencesPage extends StatefulWidget {
  const EmailPreferencesPage({Key? key}) : super(key: key);

  @override
  _EmailPreferencesPageState createState() => _EmailPreferencesPageState();
}

class _EmailPreferencesPageState extends State<EmailPreferencesPage> {
  bool _promotionalEmails = true;
  bool _orderUpdates = true;
  bool _securityAlerts = true;
  bool _newsletter = false;
  bool _specialOffers = true;
  bool _accountNotifications = true;
  bool _rideUpdates = true;
  bool _deliveryUpdates = true;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Email Preferences",
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: VStack([
          // Header Description
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: VStack([
              Icon(
                Icons.email_outlined,
                color: AppColor.primaryColor,
                size: 32,
              ),
              UiSpacer.verticalSpace(space: 8),
              "Manage your email preferences".text.bold.lg.make().centered(),
              UiSpacer.verticalSpace(space: 4),
              "Choose which emails you'd like to receive from Classy".text.gray600.make().centered(),
            ]),
          ),
          
          UiSpacer.verticalSpace(space: 24),
          
          // Email Categories
          _buildEmailCategory(
            "Account & Security",
            [
              _buildEmailPreference(
                "Account Notifications",
                "Important updates about your account",
                _accountNotifications,
                (value) => setState(() => _accountNotifications = value),
              ),
              _buildEmailPreference(
                "Security Alerts",
                "Notifications about login attempts and security changes",
                _securityAlerts,
                (value) => setState(() => _securityAlerts = value),
              ),
            ],
          ),
          
          UiSpacer.verticalSpace(space: 20),
          
          _buildEmailCategory(
            "Rides & Deliveries",
            [
              _buildEmailPreference(
                "Ride Updates",
                "Updates about your ride bookings and status",
                _rideUpdates,
                (value) => setState(() => _rideUpdates = value),
              ),
              _buildEmailPreference(
                "Delivery Updates",
                "Updates about your food and package deliveries",
                _deliveryUpdates,
                (value) => setState(() => _deliveryUpdates = value),
              ),
              _buildEmailPreference(
                "Order Updates",
                "Receipts and order confirmations",
                _orderUpdates,
                (value) => setState(() => _orderUpdates = value),
              ),
            ],
          ),
          
          UiSpacer.verticalSpace(space: 20),
          
          _buildEmailCategory(
            "Marketing & Promotions",
            [
              _buildEmailPreference(
                "Promotional Emails",
                "Special offers and discounts",
                _promotionalEmails,
                (value) => setState(() => _promotionalEmails = value),
              ),
              _buildEmailPreference(
                "Special Offers",
                "Limited-time deals and exclusive offers",
                _specialOffers,
                (value) => setState(() => _specialOffers = value),
              ),
              _buildEmailPreference(
                "Newsletter",
                "Weekly updates and app news",
                _newsletter,
                (value) => setState(() => _newsletter = value),
              ),
            ],
          ),
          
          UiSpacer.verticalSpace(space: 30),
          
          // Save Button
          ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: "Save Preferences".text.white.bold.lg.make(),
          ).wFull(context),
          
          UiSpacer.verticalSpace(space: 16),
          
          // Unsubscribe All Button
          TextButton(
            onPressed: _unsubscribeAll,
            child: "Unsubscribe from all emails".text.color(Colors.red).make(),
          ),
          
          UiSpacer.verticalSpace(space: 20),
        ]),
      ),
    );
  }

  Widget _buildEmailCategory(String title, List<Widget> preferences) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        // Category Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: title.text.bold.lg.make(),
        ),
        
        // Preferences
        VStack(preferences),
      ]),
    );
  }

  Widget _buildEmailPreference(String title, String description, bool value, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: HStack([
        Expanded(
          child: VStack([
            title.text.bold.make(),
            UiSpacer.verticalSpace(space: 4),
            description.text.gray600.sm.make(),
          ], crossAlignment: CrossAxisAlignment.start),
        ),
        
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColor.primaryColor,
        ),
      ]),
    );
  }

  void _savePreferences() {
    // TODO: Save preferences to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Email preferences saved successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _unsubscribeAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: "Unsubscribe from all emails".text.bold.make(),
        content: "Are you sure you want to unsubscribe from all emails? You'll miss important updates about your account and orders.".text.make(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: "Cancel".text.make(),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _promotionalEmails = false;
                _orderUpdates = false;
                _securityAlerts = false;
                _newsletter = false;
                _specialOffers = false;
                _accountNotifications = false;
                _rideUpdates = false;
                _deliveryUpdates = false;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Unsubscribed from all emails"),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: "Unsubscribe".text.color(Colors.red).make(),
          ),
        ],
      ),
    );
  }
}
