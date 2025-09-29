import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/services/firebase_payment.service.dart';
import 'package:Classy/models/api_response.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AddMobileMoneyPage extends StatefulWidget {
  const AddMobileMoneyPage({super.key});

  @override
  _AddMobileMoneyPageState createState() => _AddMobileMoneyPageState();
}

class _AddMobileMoneyPageState extends State<AddMobileMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  bool _isLoading = false;
  bool _isDefault = false;
  String _selectedProvider = 'MTN';
  String _countryCode = '+256';

  final List<Map<String, dynamic>> _providers = [
    {'name': 'MTN', 'icon': Icons.phone_android, 'color': Colors.yellow.shade700},
    {'name': 'Airtel', 'icon': Icons.phone_android, 'color': Colors.red},
    {'name': 'Vodafone', 'icon': Icons.phone_android, 'color': Colors.red.shade700},
    {'name': 'Other', 'icon': Icons.phone_android, 'color': Colors.grey},
  ];

  final List<Map<String, dynamic>> _countryCodes = [
    {'code': '+256', 'country': 'Uganda', 'flag': '🇺🇬'},
    {'code': '+254', 'country': 'Kenya', 'flag': '🇰🇪'},
    {'code': '+255', 'country': 'Tanzania', 'flag': '🇹🇿'},
    {'code': '+250', 'country': 'Rwanda', 'flag': '🇷🇼'},
    {'code': '+257', 'country': 'Burundi', 'flag': '🇧🇮'},
  ];

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Add Mobile Money'.tr(),
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: VStack([
            UiSpacer.verticalSpace(space: 20),
            
            // Mobile Money Preview
            _buildMobileMoneyPreview(),
            
            UiSpacer.verticalSpace(space: 30),
            
            // Form Fields
            VStack([
              // Provider Selection
              _buildProviderSelection(),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Country Code and Phone Number
              HStack([
                // Country Code
                Container(
                  width: 120,
                  child: _buildCountryCodeDropdown(),
                ),
                
                UiSpacer.horizontalSpace(space: 16),
                
                // Phone Number
                Expanded(
                  child: _buildTextField(
                    controller: _phoneNumberController,
                    label: 'Phone Number'.tr(),
                    hint: '712 345 678',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number'.tr();
                      }
                      if (value.length < 9) {
                        return 'Please enter a valid phone number'.tr();
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
                hint: 'Any special instructions for this mobile money account',
                maxLines: 2,
              ),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Set as Default
              _buildDefaultToggle(),
              
              UiSpacer.verticalSpace(space: 30),
              
              // Add Mobile Money Button
              _buildAddButton(),
              
              UiSpacer.verticalSpace(space: 20),
            ]).px20(),
          ]),
        ),
      ),
    );
  }

  Widget _buildMobileMoneyPreview() {
    final provider = _providers.firstWhere((p) => p['name'] == _selectedProvider);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [provider['color'], provider['color'].withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: provider['color'].withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: VStack([
        // Provider Icon and Name
        HStack([
          Icon(
            provider['icon'],
            color: Colors.white,
            size: 32,
          ),
          UiSpacer.horizontalSpace(space: 12),
          Text(
            _selectedProvider,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            'Mobile Money',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ]),
        
        UiSpacer.verticalSpace(space: 20),
        
        // Phone Number
        Text(
          _phoneNumberController.text.isEmpty 
              ? '•••• •••• ••'
              : '$_countryCode ${_phoneNumberController.text}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        
        UiSpacer.verticalSpace(space: 20),
        
        // Instructions
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

  Widget _buildProviderSelection() {
    return VStack([
      Text(
        'Select Provider'.tr(),
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
        children: _providers.map((provider) {
          final isSelected = _selectedProvider == provider['name'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedProvider = provider['name'];
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? provider['color'].withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? provider['color'] : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: HStack([
                Icon(
                  provider['icon'],
                  color: provider['color'],
                  size: 20,
                ),
                UiSpacer.horizontalSpace(space: 8),
                Text(
                  provider['name'],
                  style: TextStyle(
                    color: provider['color'],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ]),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildCountryCodeDropdown() {
    return VStack([
      Text(
        'Country Code'.tr(),
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
            value: _countryCode,
            isExpanded: true,
            items: _countryCodes.map((country) {
              return DropdownMenuItem<String>(
                value: country['code'],
                child: HStack([
                  Text(country['flag'], style: TextStyle(fontSize: 16)),
                  UiSpacer.horizontalSpace(space: 8),
                  Text(country['code']),
                ]),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _countryCode = value!;
              });
            },
          ),
        ),
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
        onPressed: _isLoading ? null : _addMobileMoney,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Add Mobile Money'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _addMobileMoney() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fullPhoneNumber = '$_countryCode${_phoneNumberController.text}';
      final instructions = _instructionsController.text.isNotEmpty 
          ? '${_instructionsController.text}\nProvider: $_selectedProvider\nCountry: ${_countryCodes.firstWhere((c) => c['code'] == _countryCode)['country']}'
          : 'Provider: $_selectedProvider\nCountry: ${_countryCodes.firstWhere((c) => c['code'] == _countryCode)['country']}';

      final response = await FirebasePaymentService.addPaymentAccount(
        name: '$_selectedProvider Mobile Money',
        number: fullPhoneNumber,
        instructions: instructions,
        isActive: _isDefault,
      );

      if (response.allGood) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mobile Money account added successfully!'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        throw Exception(response.message ?? 'Failed to add mobile money account');
      }
    } catch (e) {
      print('❌ Error adding mobile money: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add mobile money account: ${e.toString()}'),
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
