import 'package:flutter/material.dart';
import 'package:Classy/models/enhanced_payment.dart';
import 'package:Classy/services/enhanced_payment.service.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EnhancedPaymentSelectionPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final String currency;
  final String customerId;
  final String providerId;
  final String providerType;
  final Function(PaymentTransaction) onPaymentCompleted;

  const EnhancedPaymentSelectionPage({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.customerId,
    required this.providerId,
    required this.providerType,
    required this.onPaymentCompleted,
  }) : super(key: key);

  @override
  _EnhancedPaymentSelectionPageState createState() => _EnhancedPaymentSelectionPageState();
}

class _EnhancedPaymentSelectionPageState extends State<EnhancedPaymentSelectionPage> {
  PaymentMethod? _selectedMethod;
  bool _isProcessing = false;
  String? _errorMessage;

  // Form controllers for different payment methods
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardholderController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: VStack([
        // Header
        HStack([
          Icon(Icons.arrow_back).onTap(() => Navigator.pop(context)),
          "Payment Method".tr().text.xl2.semiBold.make().expand(),
        ]).p20(),

        // Order Summary
        _buildOrderSummary(),

        UiSpacer.verticalSpace(space: 20),

        // Payment Methods
        "Choose Payment Method".tr().text.lg.semiBold.make().px20(),
        UiSpacer.verticalSpace(space: 10),

        // Cash Payment
        _buildPaymentMethodCard(
          PaymentMethod.cash,
          Icons.money,
          Colors.green,
          "Pay with cash directly to the service provider",
        ),

        // Mobile Money Payment
        _buildPaymentMethodCard(
          PaymentMethod.mobileMoney,
          Icons.phone_android,
          Colors.blue,
          "Pay with Mobile Money (MTN, Airtel)",
        ),

        // Card Payment
        _buildPaymentMethodCard(
          PaymentMethod.card,
          Icons.credit_card,
          Colors.purple,
          "Pay with Visa or Mastercard",
        ),

        // Eversend Payment
        _buildPaymentMethodCard(
          PaymentMethod.eversend,
          Icons.send,
          Colors.orange,
          "Send money globally with Eversend",
        ),

        UiSpacer.verticalSpace(space: 20),

        // Payment Details Form
        if (_selectedMethod != null) _buildPaymentDetailsForm(),

        UiSpacer.verticalSpace(space: 20),

        // Error Message
        if (_errorMessage != null)
          _errorMessage!.text.red500.make().px20(),

        UiSpacer.verticalSpace(space: 20),

        // Pay Button
        _buildPayButton(),
      ]).scrollVertical(),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: VStack([
        "Order Summary".tr().text.lg.semiBold.make(),
        UiSpacer.verticalSpace(space: 10),
        HStack([
          "Amount:".tr().text.make().expand(),
          "${widget.currency} ${widget.amount.toStringAsFixed(2)}".text.semiBold.make(),
        ]),
        UiSpacer.verticalSpace(space: 5),
        HStack([
          "Order ID:".tr().text.make().expand(),
          widget.orderId.text.semiBold.make(),
        ]),
        UiSpacer.verticalSpace(space: 5),
        HStack([
          "Commission (15%):".tr().text.make().expand(),
          "${widget.currency} ${(widget.amount * 0.15).toStringAsFixed(2)}".text.semiBold.make(),
        ]),
      ]),
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod method,
    IconData icon,
    Color color,
    String description,
  ) {
    final isSelected = _selectedMethod == method;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: method.displayName.text.semiBold.make(),
        subtitle: description.text.sm.make(),
        trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
        onTap: () {
          setState(() {
            _selectedMethod = method;
            _errorMessage = null;
          });
        },
      ),
    );
  }

  Widget _buildPaymentDetailsForm() {
    switch (_selectedMethod!) {
      case PaymentMethod.cash:
        return _buildCashPaymentInfo();
      case PaymentMethod.mobileMoney:
        return _buildMobileMoneyForm();
      case PaymentMethod.card:
        return _buildCardForm();
      case PaymentMethod.eversend:
        return _buildEversendForm();
    }
  }

  Widget _buildCashPaymentInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: VStack([
        Icon(Icons.info_outline, color: Colors.green[700], size: 30),
        UiSpacer.verticalSpace(space: 10),
        "Cash Payment Instructions".tr().text.lg.semiBold.make(),
        UiSpacer.verticalSpace(space: 10),
        "• Pay the driver/vendor directly in cash".tr().text.make(),
        "• Commission will be calculated automatically".tr().text.make(),
        "• Payment will be marked as completed immediately".tr().text.make(),
      ]),
    );
  }

  Widget _buildMobileMoneyForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: VStack([
        "Mobile Money Details".tr().text.lg.semiBold.make(),
        UiSpacer.verticalSpace(space: 15),
        
        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Phone Number".tr(),
            hintText: "+256712345678",
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
        ),
        
        UiSpacer.verticalSpace(space: 15),
        
        // Provider Selection
        "Select Provider".tr().text.semiBold.make(),
        UiSpacer.verticalSpace(space: 10),
        HStack([
          _buildProviderButton("MTN", Icons.phone_android, Colors.yellow[700]!),
          UiSpacer.horizontalSpace(space: 10),
          _buildProviderButton("Airtel", Icons.phone_android, Colors.red[700]!),
        ]),
      ]),
    );
  }

  Widget _buildCardForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: VStack([
        "Card Details".tr().text.lg.semiBold.make(),
        UiSpacer.verticalSpace(space: 15),
        
        // Card Number
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Card Number".tr(),
            hintText: "1234 5678 9012 3456",
            prefixIcon: Icon(Icons.credit_card),
            border: OutlineInputBorder(),
          ),
        ),
        
        UiSpacer.verticalSpace(space: 15),
        
        // Expiry and CVV
        HStack([
          TextFormField(
            controller: _expiryController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: "Expiry".tr(),
              hintText: "MM/YY",
              border: OutlineInputBorder(),
            ),
          ).expand(),
          UiSpacer.horizontalSpace(space: 10),
          TextFormField(
            controller: _cvvController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "CVV".tr(),
              hintText: "123",
              border: OutlineInputBorder(),
            ),
          ).expand(),
        ]),
        
        UiSpacer.verticalSpace(space: 15),
        
        // Cardholder Name
        TextFormField(
          controller: _cardholderController,
          decoration: InputDecoration(
            labelText: "Cardholder Name".tr(),
            hintText: "John Doe",
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
      ]),
    );
  }

  Widget _buildEversendForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: VStack([
        "Eversend Details".tr().text.lg.semiBold.make(),
        UiSpacer.verticalSpace(space: 15),
        
        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Phone Number".tr(),
            hintText: "+256712345678",
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
        ),
        
        UiSpacer.verticalSpace(space: 15),
        
        // Eversend Info
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: VStack([
            Icon(Icons.info, color: Colors.orange[700]),
            UiSpacer.verticalSpace(space: 5),
            "Eversend will send you a payment request to complete the transaction".tr().text.sm.make(),
          ]),
        ),
      ]),
    );
  }

  Widget _buildProviderButton(String provider, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: HStack([
        Icon(icon, color: color, size: 20),
        UiSpacer.horizontalSpace(space: 5),
        provider.text.semiBold.color(color).make(),
      ]),
    ).onTap(() {
      // Handle provider selection
    });
  }

  Widget _buildPayButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedMethod?.value == 'cash' ? Colors.green : Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? CircularProgressIndicator(color: Colors.white)
            : "Pay ${widget.currency} ${widget.amount.toStringAsFixed(2)}".tr().text.white.semiBold.make(),
      ).wFull(context),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == null) {
      setState(() {
        _errorMessage = "Please select a payment method".tr();
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      ApiResponse response;

      switch (_selectedMethod!) {
        case PaymentMethod.cash:
          response = await EnhancedPaymentService.processCashPayment(
            orderId: widget.orderId,
            amount: widget.amount,
            currency: widget.currency,
            customerId: widget.customerId,
            providerId: widget.providerId,
            providerType: widget.providerType,
          );
          break;

        case PaymentMethod.mobileMoney:
          if (_phoneController.text.isEmpty) {
            throw Exception("Please enter your phone number".tr());
          }
          response = await EnhancedPaymentService.processMobileMoneyPayment(
            orderId: widget.orderId,
            amount: widget.amount,
            currency: widget.currency,
            phoneNumber: _phoneController.text,
            provider: "mtn", // Default to MTN
            customerId: widget.customerId,
            providerId: widget.providerId,
            providerType: widget.providerType,
          );
          break;

        case PaymentMethod.card:
          if (_cardNumberController.text.isEmpty ||
              _expiryController.text.isEmpty ||
              _cvvController.text.isEmpty ||
              _cardholderController.text.isEmpty) {
            throw Exception("Please fill in all card details".tr());
          }
          response = await EnhancedPaymentService.processCardPayment(
            orderId: widget.orderId,
            amount: widget.amount,
            currency: widget.currency,
            cardNumber: _cardNumberController.text,
            expiryDate: _expiryController.text,
            cvv: _cvvController.text,
            cardholderName: _cardholderController.text,
            customerId: widget.customerId,
            providerId: widget.providerId,
            providerType: widget.providerType,
          );
          break;

        case PaymentMethod.eversend:
          if (_phoneController.text.isEmpty) {
            throw Exception("Please enter your phone number".tr());
          }
          response = await EnhancedPaymentService.processEversendPayment(
            orderId: widget.orderId,
            amount: widget.amount,
            currency: widget.currency,
            phoneNumber: _phoneController.text,
            customerId: widget.customerId,
            providerId: widget.providerId,
            providerType: widget.providerType,
          );
          break;
      }

      if (response.allGood) {
        // Create payment transaction object
        final transaction = PaymentTransaction(
          id: response.body['transaction_id'],
          orderId: widget.orderId,
          customerId: widget.customerId,
          providerId: widget.providerId,
          providerType: widget.providerType,
          amount: widget.amount,
          currency: widget.currency,
          method: _selectedMethod!,
          status: PaymentStatus.completed,
          externalReference: response.body['external_reference'],
          commission: response.body['commission'] ?? 0.0,
          processingFee: 0.0,
          netAmount: response.body['net_amount'] ?? widget.amount,
          settlementStatus: SettlementStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        widget.onPaymentCompleted(transaction);
        Navigator.pop(context, transaction);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
