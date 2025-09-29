import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/services/firebase_payment.service.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  int _selectedPaymentMethod = 1; // Mobile Money is default
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = false;
  
  // Using Firebase service instead of HTTP API

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await FirebasePaymentService.getPaymentAccounts();
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        final accounts = List<Map<String, dynamic>>.from(response.body!['data']['data'] ?? []);
        
        // Transform backend data to frontend format
        setState(() {
          _paymentMethods = accounts.map((account) {
            return {
              'id': account['id'],
              'name': account['name'] ?? 'Unknown',
              'type': _getPaymentType(account['name']),
              'details': account['number'] ?? '',
              'icon': _getPaymentIcon(account['name']),
              'iconColor': _getPaymentColor(account['name']),
              'isDefault': account['is_active'] == 1,
              'instructions': account['instructions'],
            };
          }).toList();
        });
      } else {
        // Fallback to default payment methods if Firebase fails
        setState(() {
          _paymentMethods = _getDefaultPaymentMethods();
        });
      }
    } catch (e) {
      print('Error loading payment methods: $e');
      setState(() {
        _paymentMethods = _getDefaultPaymentMethods();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDefaultPaymentMethods() {
    return [
      {
        'id': 1,
        'name': 'Mobile Money',
        'type': 'Default',
        'details': '+256 712 345 678',
        'icon': Icons.phone_android,
        'iconColor': Colors.green,
        'isDefault': true,
      },
      {
        'id': 2,
        'name': 'Visa Card',
        'type': 'Card',
        'details': '**** **** **** 4582',
        'icon': Icons.credit_card,
        'iconColor': Colors.blue,
        'isDefault': false,
      },
      {
        'id': 3,
        'name': 'Cash',
        'type': 'Cash',
        'details': 'Pay with cash',
        'icon': Icons.attach_money,
        'iconColor': Colors.grey,
        'isDefault': false,
      },
    ];
  }

  String _getPaymentType(String? name) {
    if (name == null) return 'Unknown';
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mobile') || lowerName.contains('money')) return 'Mobile Money';
    if (lowerName.contains('card') || lowerName.contains('visa') || lowerName.contains('mastercard')) return 'Card';
    if (lowerName.contains('cash')) return 'Cash';
    return 'Payment';
  }

  IconData _getPaymentIcon(String? name) {
    if (name == null) return Icons.payment;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mobile') || lowerName.contains('money')) return Icons.phone_android;
    if (lowerName.contains('card') || lowerName.contains('visa') || lowerName.contains('mastercard')) return Icons.credit_card;
    if (lowerName.contains('cash')) return Icons.attach_money;
    return Icons.payment;
  }

  Color _getPaymentColor(String? name) {
    if (name == null) return Colors.grey;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mobile') || lowerName.contains('money')) return Colors.green;
    if (lowerName.contains('card') || lowerName.contains('visa') || lowerName.contains('mastercard')) return Colors.blue;
    if (lowerName.contains('cash')) return Colors.grey;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Payment Methods'.tr(),
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: VStack([
          UiSpacer.verticalSpace(space: 20),
          
          // Section Title
          "Your Payment Methods".tr().text.bold.xl.make().px20(),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Payment Methods List
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ).py20()
          else
            VStack([
              for (var paymentMethod in _paymentMethods)
                _buildPaymentMethodCard(paymentMethod),
            ]).px20(),
          
          UiSpacer.verticalSpace(space: 30),
          
          // Add Payment Method Button
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HStack([
              Icon(
                Icons.add,
                color: AppColor.primaryColor,
                size: 24,
              ),
              UiSpacer.horizontalSpace(space: 12),
              "Add Payment Method".tr().text.color(AppColor.primaryColor).bold.make(),
            ]).centered(),
          ).onTap(() {
            _showAddPaymentMethodModal(context);
          }),
          
          UiSpacer.verticalSpace(space: 20),
        ]),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> paymentMethod) {
    final isSelected = _selectedPaymentMethod == paymentMethod['id'];
    final isDefault = paymentMethod['isDefault'];
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? AppColor.primaryColor : Colors.grey.shade200,
          width: isDefault ? 2 : 1,
        ),
      ),
      child: HStack([
        // Icon
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: paymentMethod['iconColor'].withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            paymentMethod['icon'],
            color: paymentMethod['iconColor'],
            size: 24,
          ),
        ),
        
        UiSpacer.horizontalSpace(space: 16),
        
        // Payment Method Details
        Expanded(
          child: VStack([
            paymentMethod['name'].toString().text.bold.make(),
            UiSpacer.verticalSpace(space: 4),
            if (isDefault)
              "Default".tr().text.color(AppColor.primaryColor).sm.make()
            else
              paymentMethod['type'].toString().text.gray600.sm.make(),
            UiSpacer.verticalSpace(space: 4),
            paymentMethod['details'].toString().text.gray600.make(),
          ]),
        ),
        
        // Radio Button and Menu
        HStack([
          // Radio Button
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColor.primaryColor : Colors.white,
              border: Border.all(
                color: isSelected ? AppColor.primaryColor : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  )
                : null,
          ),
          
          UiSpacer.horizontalSpace(space: 12),
          
          // Menu Icon
          IconButton(
            onPressed: () => _showPaymentMethodOptions(context, paymentMethod),
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey.shade600,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ]),
      ]).onTap(() {
        setState(() {
          _selectedPaymentMethod = paymentMethod['id'];
        });
      }),
    );
  }

  void _showPaymentMethodOptions(BuildContext context, Map<String, dynamic> paymentMethod) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: VStack([
          "Payment Method Options".tr().text.bold.xl.make().py16(),
          
          if (paymentMethod['isDefault'])
            ListTile(
              leading: Icon(Icons.star_border, color: Colors.grey),
              title: "Remove Default".tr().text.make(),
              onTap: () {
                Navigator.pop(context);
                _removeDefault(paymentMethod);
              },
            )
          else
            ListTile(
              leading: Icon(Icons.star, color: AppColor.primaryColor),
              title: "Set as Default".tr().text.make(),
              onTap: () {
                Navigator.pop(context);
                _setAsDefault(paymentMethod);
              },
            ),
          
          ListTile(
            leading: Icon(Icons.edit, color: Colors.blue),
            title: "Edit".tr().text.make(),
            onTap: () {
              Navigator.pop(context);
              _editPaymentMethod(paymentMethod);
            },
          ),
          
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: "Delete".tr().text.make(),
            onTap: () {
              Navigator.pop(context);
              _deletePaymentMethod(paymentMethod);
            },
          ),
          
          UiSpacer.verticalSpace(space: 20),
        ]),
      ),
    );
  }

  void _showAddPaymentMethodModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                HStack([
                  "Add Payment Method".tr().text.bold.xl.make(),
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
                
                // Payment Method Options
                VStack([
                  _buildAddOption(
                    icon: Icons.credit_card,
                    title: "Add Credit/Debit Card".tr(),
                    subtitle: "Visa, Mastercard, American Express".tr(),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to add card page
                    },
                  ),
                  
                  UiSpacer.verticalSpace(space: 16),
                  
                  _buildAddOption(
                    icon: Icons.phone_android,
                    title: "Add Mobile Money".tr(),
                    subtitle: "MTN, Airtel, Vodafone".tr(),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to add mobile money page
                    },
                  ),
                  
                  UiSpacer.verticalSpace(space: 16),
                  
                  _buildAddOption(
                    icon: Icons.account_balance,
                    title: "Add Bank Account".tr(),
                    subtitle: "Direct bank transfer".tr(),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to add bank account page
                    },
                  ),
                ]),
                
                UiSpacer.verticalSpace(space: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColor.primaryColor,
            size: 24,
          ),
        ),
        title: title.text.bold.make(),
        subtitle: subtitle.text.gray600.make(),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade600,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  // CRUD Operations
  Future<void> _setAsDefault(Map<String, dynamic> paymentMethod) async {
    try {
      // Update all methods to not be default
      for (var method in _paymentMethods) {
        method['isDefault'] = false;
      }
      
      // Set selected method as default
      paymentMethod['isDefault'] = true;
      
      setState(() {});
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${paymentMethod['name']} set as default payment method"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to set default payment method"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeDefault(Map<String, dynamic> paymentMethod) async {
    try {
      paymentMethod['isDefault'] = false;
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Default payment method removed"),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to remove default payment method"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editPaymentMethod(Map<String, dynamic> paymentMethod) async {
    final nameController = TextEditingController(text: paymentMethod['name']);
    final numberController = TextEditingController(text: paymentMethod['details']);
    final instructionsController = TextEditingController(text: paymentMethod['instructions'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Payment Method"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: numberController,
              decoration: InputDecoration(
                labelText: "Number/Details",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: instructionsController,
              decoration: InputDecoration(
                labelText: "Instructions (Optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updatePaymentMethod(paymentMethod, nameController.text, numberController.text, instructionsController.text);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePaymentMethod(Map<String, dynamic> paymentMethod, String name, String number, String instructions) async {
    try {
      final response = await FirebasePaymentService.updatePaymentAccount(
        accountId: paymentMethod['id'].toString(),
        name: name,
        number: number,
        instructions: instructions,
        isActive: paymentMethod['isDefault'],
      );

      if (response.allGood) {
        // Update local data
        paymentMethod['name'] = name;
        paymentMethod['details'] = number;
        paymentMethod['instructions'] = instructions;
        setState(() {});
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment method updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response.message ?? 'Failed to update payment method');
      }
    } catch (e) {
      print("❌ Error updating payment method: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update payment method: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePaymentMethod(Map<String, dynamic> paymentMethod) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Payment Method"),
        content: Text("Are you sure you want to delete ${paymentMethod['name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeletePaymentMethod(paymentMethod);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePaymentMethod(Map<String, dynamic> paymentMethod) async {
    try {
      final response = await FirebasePaymentService.deletePaymentAccount(paymentMethod['id'].toString());

      if (response.allGood) {
        // Remove from local list
        setState(() {
          _paymentMethods.removeWhere((method) => method['id'] == paymentMethod['id']);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment method deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response.message ?? 'Failed to delete payment method');
      }
    } catch (e) {
      print("❌ Error deleting payment method: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete payment method: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
