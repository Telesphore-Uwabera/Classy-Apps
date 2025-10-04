import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/services/firebase_payment.service.dart';
import 'package:Classy/models/api_response.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AddCreditCardPage extends StatefulWidget {
  const AddCreditCardPage({super.key});

  @override
  _AddCreditCardPageState createState() => _AddCreditCardPageState();
}

class _AddCreditCardPageState extends State<AddCreditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  bool _isLoading = false;
  bool _isDefault = false;
  String _cardType = 'Unknown';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Add Credit/Debit Card'.tr(),
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: VStack([
            UiSpacer.verticalSpace(space: 20),
            
            // Card Preview
            _buildCardPreview(),
            
            UiSpacer.verticalSpace(space: 30),
            
            // Form Fields
            VStack([
              // Card Number
              _buildTextField(
                controller: _cardNumberController,
                label: 'Card Number'.tr(),
                hint: '1234 5678 9012 3456',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number'.tr();
                  }
                  if (value.length < 13) {
                    return 'Please enter a valid card number'.tr();
                  }
                  return null;
                },
                onChanged: (value) {
                  _detectCardType(value);
                },
              ),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Cardholder Name
              _buildTextField(
                controller: _cardholderNameController,
                label: 'Cardholder Name'.tr(),
                hint: 'John Doe',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name'.tr();
                  }
                  return null;
                },
              ),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Expiry Date and CVV Row
              HStack([
                // Expiry Date
                Expanded(
                  child: _buildTextField(
                    controller: _expiryDateController,
                    label: 'Expiry Date'.tr(),
                    hint: 'MM/YY',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      ExpiryDateInputFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expiry date'.tr();
                      }
                      if (value.length != 5) {
                        return 'Please enter valid expiry date'.tr();
                      }
                      return null;
                    },
                  ),
                ),
                
                UiSpacer.horizontalSpace(space: 16),
                
                // CVV
                Expanded(
                  child: _buildTextField(
                    controller: _cvvController,
                    label: 'CVV'.tr(),
                    hint: '123',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter CVV'.tr();
                      }
                      if (value.length < 3) {
                        return 'Please enter valid CVV'.tr();
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
                hint: 'Any special instructions for this card',
                maxLines: 2,
              ),
              
              UiSpacer.verticalSpace(space: 20),
              
              // Set as Default
              _buildDefaultToggle(),
              
              UiSpacer.verticalSpace(space: 30),
              
              // Add Card Button
              _buildAddButton(),
              
              UiSpacer.verticalSpace(space: 20),
            ]).px20(),
          ]),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
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
        // Card Type and Logo
        HStack([
          _getCardTypeIcon(),
          Spacer(),
          Text(
            _cardType,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
        
        UiSpacer.verticalSpace(space: 20),
        
        // Card Number
        Text(
          _cardNumberController.text.isEmpty 
              ? '•••• •••• •••• ••••'
              : _formatCardNumber(_cardNumberController.text),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        
        UiSpacer.verticalSpace(space: 20),
        
        // Cardholder Name and Expiry
        HStack([
          Expanded(
            child: VStack([
              Text(
                'CARDHOLDER',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                _cardholderNameController.text.isEmpty 
                    ? 'CARDHOLDER NAME'
                    : _cardholderNameController.text.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          ),
          VStack([
            Text(
              'EXPIRES',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              _expiryDateController.text.isEmpty 
                  ? 'MM/YY'
                  : _expiryDateController.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
        onChanged: onChanged,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
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
        onPressed: _isLoading ? null : _addCard,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Add Card'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _getCardTypeIcon() {
    switch (_cardType.toLowerCase()) {
      case 'visa':
        return Icon(Icons.credit_card, color: Colors.white, size: 24);
      case 'mastercard':
        return Icon(Icons.credit_card, color: Colors.white, size: 24);
      case 'amex':
        return Icon(Icons.credit_card, color: Colors.white, size: 24);
      default:
        return Icon(Icons.credit_card, color: Colors.white, size: 24);
    }
  }

  void _detectCardType(String cardNumber) {
    setState(() {
      if (cardNumber.startsWith('4')) {
        _cardType = 'Visa';
      } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
        _cardType = 'Mastercard';
      } else if (cardNumber.startsWith('3')) {
        _cardType = 'Amex';
      } else {
        _cardType = 'Unknown';
      }
    });
  }

  String _formatCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(' ', '');
    final formatted = cleaned.replaceAllMapped(
      RegExp(r'.{4}'),
      (match) => '${match.group(0)} ',
    );
    return formatted.trim();
  }

  Future<void> _addCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await FirebasePaymentService.addPaymentAccount(
        name: '${_cardType} Card (${_cardNumberController.text.substring(_cardNumberController.text.length - 4)})',
        number: _cardNumberController.text,
        instructions: _instructionsController.text.isNotEmpty 
            ? '${_instructionsController.text}\nCardholder: ${_cardholderNameController.text}\nExpiry: ${_expiryDateController.text}'
            : 'Cardholder: ${_cardholderNameController.text}\nExpiry: ${_expiryDateController.text}',
        isActive: _isDefault,
      );

      if (response.allGood) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card added successfully!'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        throw Exception(response.message ?? 'Failed to add card');
      }
    } catch (e) {
      print('❌ Error adding card: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add card: ${e.toString()}'),
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

// Custom input formatters
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length <= 4) return newValue;
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length <= 2) return newValue;
    
    return TextEditingValue(
      text: '${text.substring(0, 2)}/${text.substring(2)}',
      selection: TextSelection.collapsed(offset: text.length + 1),
    );
  }
}
