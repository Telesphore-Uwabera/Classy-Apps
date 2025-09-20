import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/payment_account_service.dart';
import '../../../models/payment_account.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../constants/app_theme.dart';

class AddPaymentAccountScreen extends StatefulWidget {
  const AddPaymentAccountScreen({super.key});

  @override
  State<AddPaymentAccountScreen> createState() => _AddPaymentAccountScreenState();
}

class _AddPaymentAccountScreenState extends State<AddPaymentAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final PaymentAccountService _paymentService = PaymentAccountService.instance;
  
  String _selectedAccountType = 'bank';
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final vendorId = authService.currentUser?.id?.toString() ?? '';
      
      if (vendorId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final account = PaymentAccount(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _accountNameController.text.trim(),
        number: _accountNumberController.text.trim(),
        instructions: '',
        isActive: true,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
        formattedDate: DateTime.now().toString(),
        formattedUpdatedDate: DateTime.now().toString(),
        accountType: _selectedAccountType,
        accountName: _accountNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        routingNumber: _routingNumberController.text.trim(),
        bankName: _bankNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isDefault: _isDefault,
        isVerified: false,
      );

      if (!_paymentService.validatePaymentAccount(account)) {
        throw Exception('Invalid account data');
      }

      final success = await _paymentService.addPaymentAccount(account);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment account added successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to save payment account');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportedTypes = _paymentService.getSupportedAccountTypes();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Account'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...supportedTypes.map((type) => RadioListTile<String>(
                        title: Row(
                          children: [
                            Text(type['icon']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(type['name']!),
                          ],
                        ),
                        subtitle: Text(type['description']!),
                        value: type['type']!,
                        groupValue: _selectedAccountType,
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountType = value!;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      )),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Account Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Account Name
                      CustomTextField(
                        controller: _accountNameController,
                        labelText: 'Account Name',
                        hintText: 'e.g., Main Business Account',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Account Number
                      CustomTextField(
                        controller: _accountNumberController,
                        labelText: 'Account Number',
                        hintText: 'Enter account number',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bank-specific fields
                      if (_selectedAccountType == 'bank') ...[
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _routingNumberController,
                                labelText: 'Routing Number',
                                hintText: '9-digit routing number',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required for bank accounts';
                                  }
                                  if (value.length != 9) {
                                    return 'Must be 9 digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _bankNameController,
                                labelText: 'Bank Name',
                                hintText: 'e.g., Chase Bank',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required for bank accounts';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Account Holder Name
                      CustomTextField(
                        controller: _accountHolderController,
                        labelText: 'Account Holder Name',
                        hintText: 'Full name on the account',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account holder name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email (for digital payment methods)
                      if (_selectedAccountType != 'bank') ...[
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'Account email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (_selectedAccountType != 'bank' && (value == null || value.isEmpty)) {
                              return 'Required for ${_selectedAccountType} accounts';
                            }
                            if (value != null && value.isNotEmpty && !value.contains('@')) {
                              return 'Please enter valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Phone Number
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        hintText: 'Contact phone number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Set as Default'),
                        subtitle: const Text('Use this account for all payments'),
                        value: _isDefault,
                        onChanged: (value) {
                          setState(() {
                            _isDefault = value;
                          });
                        },
                        activeThumbColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              CustomButton(
                text: 'Add Payment Account',
                onPressed: _isLoading ? null : _saveAccount,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
