import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/services/firebase_payment.service.dart';
import 'package:Classy/models/api_response.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AddBankAccountPage extends StatefulWidget {
  const AddBankAccountPage({super.key});

  @override
  _AddBankAccountPageState createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends State<AddBankAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _swiftCodeController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  bool _isLoading = false;
  bool _isDefault = false;
  String _selectedBank = 'Select Bank';
  String _accountType = 'Savings';

  final List<Map<String, dynamic>> _banks = [
    {'name': 'Stanbic Bank Uganda', 'code': 'SBU', 'icon': Icons.account_balance},
    {'name': 'Centenary Bank', 'code': 'CEN', 'icon': Icons.account_balance},
    {'name': 'Equity Bank Uganda', 'code': 'EQU', 'icon': Icons.account_balance},
    {'name': 'Absa Bank Uganda', 'code': 'ABS', 'icon': Icons.account_balance},
    {'name': 'DFCU Bank', 'code': 'DFC', 'icon': Icons.account_balance},
    {'name': 'Bank of Uganda', 'code': 'BOU', 'icon': Icons.account_balance},
    {'name': 'KCB Bank Uganda', 'code': 'KCB', 'icon': Icons.account_balance},
    {'name': 'Other', 'code': 'OTH', 'icon': Icons.account_balance},
  ];

  final List<String> _accountTypes = ['Savings', 'Current', 'Fixed Deposit', 'Business'];

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _routingNumberController.dispose();
    _swiftCodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Add Bank Account'.tr(),
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: VStack([
            UiSpacer.verticalSpace(space: 20),
            
            // Bank Account Preview
            _buildBankAccountPreview(),
            
            UiSpacer.verticalSpace(space: 30),
            
            // Form Fields
            VStack([
              // Bank Selection
              _buildBankSelection(),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Account Type
              _buildAccountTypeSelection(),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Account Number
              _buildTextField(
                controller: _accountNumberController,
                label: 'Account Number'.tr(),
                hint: '1234567890',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number'.tr();
                  }
                  if (value.length < 8) {
                    return 'Please enter a valid account number'.tr();
                  }
                  return null;
                },
              ),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Account Holder Name
              _buildTextField(
                controller: _accountHolderNameController,
                label: 'Account Holder Name'.tr(),
                hint: 'John Doe',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name'.tr();
                  }
                  return null;
                },
              ),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Routing Number and Swift Code Row
              HStack([
                // Routing Number
                Expanded(
                  child: _buildTextField(
                    controller: _routingNumberController,
                    label: 'Routing Number'.tr(),
                    hint: '123456',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter routing number'.tr();
                      }
                      return null;
                    },
                  ),
                ),
                
                UiSpacer.horizontalSpace(space: 16),
                
                // Swift Code
                Expanded(
                  child: _buildTextField(
                    controller: _swiftCodeController,
                    label: 'SWIFT Code'.tr(),
                    hint: 'SBICUGKX',
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter SWIFT code'.tr();
                      }
                      if (value.length < 8) {
                        return 'Please enter valid SWIFT code'.tr();
                      }
                      return null;
                    },
                  ),
                ),
              ]),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Instructions (Optional)
              _buildTextField(
                controller: _instructionsController,
                label: 'Instructions (Optional)'.tr(),
                hint: 'Any special instructions for this bank account',
                maxLines: 2,
              ),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Set as Default
              _buildDefaultToggle(),
              
              UiSpacer.verticalSpace(space: 30),
              
              // Add Bank Account Button
              _buildAddButton(),
              
              UiSpacer.verticalSpace(space: 20),
            ]).px20(),
          ]),
        ),
      ),
    );
  }

  Widget _buildBankAccountPreview() {
    final bank = _banks.firstWhere((b) => b['name'] == _selectedBank, orElse: () => _banks.last);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primaryColor, AppColor.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: VStack([
        // Bank Icon and Name
        HStack([
          Icon(
            bank['icon'],
            color: Colors.white,
            size: 32,
          ),
          UiSpacer.horizontalSpace(space: 12),
          Expanded(
            child: Text(
              _selectedBank == 'Select Bank' ? 'Bank Account' : _selectedBank,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            _accountType,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ]),
        
        UiSpacer.verticalSpace(space: 20),
        
        // Account Number
        Text(
          _accountNumberController.text.isEmpty 
              ? '•••• •••• ••••'
              : _formatAccountNumber(_accountNumberController.text),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        
        UiSpacer.verticalSpace(space: 20),
        
        // Account Holder Name
        HStack([
          Expanded(
            child: VStack([
              Text(
                'ACCOUNT HOLDER',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                _accountHolderNameController.text.isEmpty 
                    ? 'ACCOUNT HOLDER NAME'
                    : _accountHolderNameController.text.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          ),
          if (_routingNumberController.text.isNotEmpty)
            VStack([
              Text(
                'ROUTING',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                _routingNumberController.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
        ]),
        
        if (_instructionsController.text.isNotEmpty)
          UiSpacer.verticalSpace(space: 20),
        
        if (_instructionsController.text.isNotEmpty)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _instructionsController.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildBankSelection() {
    return VStack([
      Text(
        'Select Bank'.tr(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
      UiSpacer.verticalSpace(space: 8),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedBank,
            isExpanded: true,
            items: _banks.map((bank) {
              return DropdownMenuItem<String>(
                value: bank['name'],
                child: HStack([
                  Icon(bank['icon'], size: 20, color: AppColor.primaryColor),
                  UiSpacer.horizontalSpace(space: 12),
                  Expanded(child: Text(bank['name'])),
                ]),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBank = value!;
                if (value != 'Other') {
                  _bankNameController.text = value;
                } else {
                  _bankNameController.clear();
                }
              });
            },
          ),
        ),
      ),
      
      if (_selectedBank == 'Other')
        UiSpacer.verticalSpace(space: 16),
      
      if (_selectedBank == 'Other')
        _buildTextField(
          controller: _bankNameController,
          label: 'Bank Name'.tr(),
          hint: 'Enter bank name',
          validator: (value) {
            if (_selectedBank == 'Other' && (value == null || value.isEmpty)) {
              return 'Please enter bank name'.tr();
            }
            return null;
          },
        ),
    ]);
  }

  Widget _buildAccountTypeSelection() {
    return VStack([
      Text(
        'Account Type'.tr(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
      UiSpacer.verticalSpace(space: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _accountTypes.map((type) {
          final isSelected = _accountType == type;
          return GestureDetector(
            onTap: () {
              setState(() {
                _accountType = type;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColor.primaryColor : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: isSelected ? AppColor.primaryColor : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return VStack([
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
      UiSpacer.verticalSpace(space: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    ]);
  }

  Widget _buildDefaultToggle() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: HStack([
        Icon(
          Icons.star,
          color: _isDefault ? AppColor.primaryColor : Colors.grey.shade400,
          size: 20,
        ),
        UiSpacer.horizontalSpace(space: 12),
        Expanded(
          child: Text(
            'Set as default payment method'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: _isDefault,
          onChanged: (value) {
            setState(() {
              _isDefault = value;
            });
          },
          activeColor: AppColor.primaryColor,
        ),
      ]),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addBankAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Add Bank Account'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _formatAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    
    final buffer = StringBuffer();
    for (int i = 0; i < accountNumber.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(accountNumber[i]);
    }
    return buffer.toString();
  }

  Future<void> _addBankAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bankName = _selectedBank == 'Other' ? _bankNameController.text : _selectedBank;
      final instructions = _instructionsController.text.isNotEmpty 
          ? '${_instructionsController.text}\nBank: $bankName\nAccount Type: $_accountType\nRouting: ${_routingNumberController.text}\nSWIFT: ${_swiftCodeController.text}'
          : 'Bank: $bankName\nAccount Type: $_accountType\nRouting: ${_routingNumberController.text}\nSWIFT: ${_swiftCodeController.text}';

      final response = await FirebasePaymentService.addPaymentAccount(
        name: '$bankName ($_accountType)',
        number: _accountNumberController.text,
        instructions: instructions,
        isActive: _isDefault,
      );

      if (response.allGood) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bank account added successfully!'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        throw Exception(response.message ?? 'Failed to add bank account');
      }
    } catch (e) {
      print('❌ Error adding bank account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add bank account: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
