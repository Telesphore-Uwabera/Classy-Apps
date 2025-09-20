import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/delivery_zone_service.dart';
import '../../../models/delivery_zone.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';

class AddDeliveryZoneScreen extends StatefulWidget {
  const AddDeliveryZoneScreen({super.key});

  @override
  State<AddDeliveryZoneScreen> createState() => _AddDeliveryZoneScreenState();
}

class _AddDeliveryZoneScreenState extends State<AddDeliveryZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverageAreaController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  final _estimatedDeliveryTimeController = TextEditingController();
  
  final DeliveryZoneService _deliveryZoneService = DeliveryZoneService.instance;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _coverageAreaController.dispose();
    _deliveryFeeController.dispose();
    _minOrderAmountController.dispose();
    _estimatedDeliveryTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveDeliveryZone() async {
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

      final deliveryZone = DeliveryZone(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: vendorId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        coverageArea: _coverageAreaController.text.trim(),
        deliveryFee: double.parse(_deliveryFeeController.text.trim()),
        minOrderAmount: double.parse(_minOrderAmountController.text.trim()),
        estimatedDeliveryTime: int.parse(_estimatedDeliveryTimeController.text.trim()),
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _deliveryZoneService.addDeliveryZone(deliveryZone);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delivery zone added successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to save delivery zone');
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
        title: const Text('Add Delivery Zone'),
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
              // Basic Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Zone Name
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Zone Name',
                        hintText: 'e.g., Downtown Area',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter zone name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        hintText: 'Brief description of the delivery zone',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Coverage Area
                      CustomTextField(
                        controller: _coverageAreaController,
                        labelText: 'Coverage Area',
                        hintText: 'e.g., Downtown, City Center, Main Street',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter coverage area';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Pricing and Timing Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pricing & Timing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Delivery Fee and Min Order Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _deliveryFeeController,
                              labelText: 'Delivery Fee',
                              hintText: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter delivery fee';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _minOrderAmountController,
                              labelText: 'Min Order Amount',
                              hintText: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter min order amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Estimated Delivery Time
                      CustomTextField(
                        controller: _estimatedDeliveryTimeController,
                        labelText: 'Estimated Delivery Time (minutes)',
                        hintText: '30',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter delivery time';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid time';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Active Zone'),
                        subtitle: const Text('This zone will be available for delivery'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
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
                text: 'Add Delivery Zone',
                onPressed: _isLoading ? null : _saveDeliveryZone,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
