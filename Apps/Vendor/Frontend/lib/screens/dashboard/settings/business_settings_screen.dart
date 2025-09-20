import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _businessHoursController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBusinessInfo();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _businessDescriptionController.dispose();
    _businessHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessInfo() async {
    // In a real app, you would load this from Firebase
    // For now, we'll use placeholder data
    setState(() {
      _businessNameController.text = 'My Restaurant';
      _businessTypeController.text = 'Restaurant';
      _businessAddressController.text = '123 Main St, City, State 12345';
      _businessPhoneController.text = '+1 (555) 123-4567';
      _businessEmailController.text = 'business@example.com';
      _businessDescriptionController.text = 'Delicious food delivered fresh to your door';
      _businessHoursController.text = 'Mon-Fri: 9AM-10PM, Sat-Sun: 10AM-11PM';
    });
  }

  Future<void> _saveBusinessInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would save this to Firebase
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business information saved successfully')),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Settings'),
        backgroundColor: Colors.blue[600],
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
              // Business Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Business Name
                      CustomTextField(
                        controller: _businessNameController,
                        labelText: 'Business Name',
                        hintText: 'Enter your business name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Business Type
                      CustomTextField(
                        controller: _businessTypeController,
                        labelText: 'Business Type',
                        hintText: 'e.g., Restaurant, Cafe, Bakery',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business type';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Business Address
                      CustomTextField(
                        controller: _businessAddressController,
                        labelText: 'Business Address',
                        hintText: 'Enter your business address',
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business address';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Phone and Email Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _businessPhoneController,
                              labelText: 'Phone Number',
                              hintText: '+1 (555) 123-4567',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _businessEmailController,
                              labelText: 'Email',
                              hintText: 'business@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Business Description
                      CustomTextField(
                        controller: _businessDescriptionController,
                        labelText: 'Business Description',
                        hintText: 'Describe your business',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business description';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Business Hours
                      CustomTextField(
                        controller: _businessHoursController,
                        labelText: 'Business Hours',
                        hintText: 'e.g., Mon-Fri: 9AM-10PM',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business hours';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Business Preferences Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Auto Accept Orders
                      SwitchListTile(
                        title: const Text('Auto Accept Orders'),
                        subtitle: const Text('Automatically accept new orders'),
                        value: true,
                        onChanged: (value) {
                          // Handle auto accept toggle
                        },
                        activeColor: Colors.blue[600],
                      ),
                      
                      // Email Notifications
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Receive email notifications for orders'),
                        value: true,
                        onChanged: (value) {
                          // Handle email notifications toggle
                        },
                        activeColor: Colors.blue[600],
                      ),
                      
                      // SMS Notifications
                      SwitchListTile(
                        title: const Text('SMS Notifications'),
                        subtitle: const Text('Receive SMS notifications for orders'),
                        value: false,
                        onChanged: (value) {
                          // Handle SMS notifications toggle
                        },
                        activeColor: Colors.blue[600],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _isLoading ? null : _saveBusinessInfo,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
