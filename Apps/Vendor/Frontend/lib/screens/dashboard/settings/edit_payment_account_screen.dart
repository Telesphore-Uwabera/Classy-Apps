import 'package:flutter/material.dart';
import '../../../models/payment_account.dart';
import '../../../services/payment_account_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../constants/app_theme.dart';

class EditPaymentAccountScreen extends StatefulWidget {
  final PaymentAccount account;

  const EditPaymentAccountScreen({
    super.key,
    required this.account,
  });

  @override
  State<EditPaymentAccountScreen> createState() => _EditPaymentAccountScreenState();
}

class _EditPaymentAccountScreenState extends State<EditPaymentAccountScreen> {
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
  void initState() {
    super.initState();
    _initializeFields();
  }

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

  void _initializeFields() {
    _accountNameController.text = widget.account.accountName;
    _accountNumberController.text = widget.account.accountNumber;
    _routingNumberController.text = widget.account.routingNumber;
    _bankNameController.text = widget.account.bankName;
    _accountHolderController.text = widget.account.accountHolderName;
    _emailController.text = widget.account.email;
    _phoneController.text = widget.account.phone;
    _selectedAccountType = widget.account.accountType;
    _isDefault = widget.account.isDefault;
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedAccount = widget.account.copyWith(
        accountType: _selectedAccountType,
        accountName: _accountNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        routingNumber: _routingNumberController.text.trim(),
        bankName: _bankNameController.text.trim(),
        // accountHolderName: _accountHolderController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isDefault: _isDefault,
        updatedAt: DateTime.now(),
      );

      if (!_paymentService.validatePaymentAccount(updatedAccount)) {
        throw Exception('Invalid account data');
      }

      final success = await _paymentService.updatePaymentAccount(updatedAccount);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment account updated successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to update payment account');
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
        title: const Text('Edit Payment Account'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
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
              
              // Update Button
              CustomButton(
                text: 'Update Payment Account',
                onPressed: _isLoading ? null : _updateAccount,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Account'),
        content: Text('Are you sure you want to delete "${widget.account.accountName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _paymentService.deletePaymentAccount(widget.account.id.toString());
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment account deleted successfully')),
                );
                Navigator.pop(context);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete payment account')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
