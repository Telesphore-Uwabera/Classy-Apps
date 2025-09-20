import 'package:flutter/material.dart';
import '../../../models/package_pricing.dart';
import '../../../services/package_pricing_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../constants/app_theme.dart';

class EditPackagePricingScreen extends StatefulWidget {
  final PackagePricing pricing;

  const EditPackagePricingScreen({
    super.key,
    required this.pricing,
  });

  @override
  State<EditPackagePricingScreen> createState() => _EditPackagePricingScreenState();
}

class _EditPackagePricingScreenState extends State<EditPackagePricingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _pricePerKmController = TextEditingController();
  final _pricePerKgController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  
  final PackagePricingService _pricingService = PackagePricingService.instance;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _pricePerKmController.dispose();
    _pricePerKgController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    _nameController.text = widget.pricing.name;
    _descriptionController.text = widget.pricing.description;
    _basePriceController.text = widget.pricing.basePrice.toString();
    _pricePerKmController.text = widget.pricing.pricePerKm.toString();
    _pricePerKgController.text = widget.pricing.pricePerKg.toString();
    _minPriceController.text = widget.pricing.minPrice.toString();
    _maxPriceController.text = widget.pricing.maxPrice.toString();
    _isActive = widget.pricing.isActive;
  }

  Future<void> _updatePricing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPricing = widget.pricing.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        basePrice: double.parse(_basePriceController.text.trim()),
        pricePerKm: double.parse(_pricePerKmController.text.trim()),
        pricePerKg: double.parse(_pricePerKgController.text.trim()),
        minPrice: double.parse(_minPriceController.text.trim()),
        maxPrice: double.parse(_maxPriceController.text.trim()),
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      final success = await _pricingService.updatePackagePricing(updatedPricing);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Package pricing updated successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to update package pricing');
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
        title: const Text('Edit Package Pricing'),
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
                      
                      // Pricing Name
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Pricing Name',
                        hintText: 'e.g., Standard Delivery',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pricing name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        hintText: 'Describe this pricing tier',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Pricing Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pricing Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Base Price
                      CustomTextField(
                        controller: _basePriceController,
                        labelText: 'Base Price',
                        hintText: '0.00',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter base price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid price';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price Per Km and Per Kg Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _pricePerKmController,
                              labelText: 'Price Per Km',
                              hintText: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _pricePerKgController,
                              labelText: 'Price Per Kg',
                              hintText: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Min and Max Price Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _minPriceController,
                              labelText: 'Minimum Price',
                              hintText: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _maxPriceController,
                              labelText: 'Maximum Price',
                              hintText: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                        title: const Text('Active Pricing'),
                        subtitle: const Text('This pricing will be available for customers'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
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
                text: 'Update Package Pricing',
                onPressed: _isLoading ? null : _updatePricing,
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
        title: const Text('Delete Package Pricing'),
        content: Text('Are you sure you want to delete "${widget.pricing.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _pricingService.deletePackagePricing(widget.pricing.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Package pricing deleted successfully')),
                );
                Navigator.pop(context);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete package pricing')),
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
