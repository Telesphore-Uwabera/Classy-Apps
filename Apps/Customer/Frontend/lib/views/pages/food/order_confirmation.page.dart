import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/services/cart_api.service.dart';
import 'package:Classy/requests/wallet.request.dart';
import 'package:Classy/models/wallet.dart';
import 'package:Classy/widgets/enhanced_location_search.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({Key? key, this.orderDetails}) : super(key: key);
  
  final Map<String, dynamic>? orderDetails;

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  String _selectedPaymentMethod = 'post_service';
  String _selectedDeliveryTime = 'asap';
  String _deliveryAddress = 'Tap to set delivery address';
  LatLng? _deliveryCoordinates;
  double _subtotal = 0.0;
  double _deliveryFee = 2.99;
  double _serviceFee = 1.50;
  double _discount = 0.0;
  double _total = 0.0;
  bool _isPlacingOrder = false;
  bool _isLoading = true;
  
  final CartApiService _cartApiService = CartApiService();
  final WalletRequest _walletRequest = WalletRequest();

  List<Map<String, dynamic>> _orderItems = [];
  double _walletBalance = 0.0;
  bool _isLoadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      setState(() {
        _isLoadingWallet = true;
      });
      
      final wallet = await _walletRequest.walletBalance();
      setState(() {
        _walletBalance = wallet.balance ?? 0.0;
        _isLoadingWallet = false;
      });
    } catch (e) {
      setState(() {
        _walletBalance = 0.0;
        _isLoadingWallet = false;
      });
      print('Error loading wallet balance: $e');
    }
  }

  Future<void> _loadOrderData() async {
    try {
      // TODO: Load real cart data from CartService
      // For now, simulate loading
      await Future.delayed(Duration(seconds: 1));
      
      // Load from orderDetails if provided
      if (widget.orderDetails != null) {
        setState(() {
          _orderItems = List<Map<String, dynamic>>.from(widget.orderDetails!['items'] ?? []);
          _subtotal = (widget.orderDetails!['subtotal'] ?? 0.0).toDouble();
          _deliveryFee = (widget.orderDetails!['delivery_fee'] ?? 2.99).toDouble();
          _serviceFee = (widget.orderDetails!['service_fee'] ?? 1.50).toDouble();
          _discount = (widget.orderDetails!['discount'] ?? 0.0).toDouble();
          _total = _subtotal + _deliveryFee + _serviceFee - _discount;
          _isLoading = false;
        });
      } else {
        // Load from cart API
        final response = await _cartApiService.getCartItems();
        if (response.allGood && response.body != null && response.body!['data'] != null) {
          setState(() {
            _orderItems = List<Map<String, dynamic>>.from(response.body!['data']);
            _subtotal = _orderItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));
            _total = _subtotal + _deliveryFee + _serviceFee - _discount;
            _isLoading = false;
          });
        } else {
          setState(() {
            _orderItems = [];
            _subtotal = 0.0;
            _total = _deliveryFee + _serviceFee;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading order data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Confirm Order",
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            )
          : _orderItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No items in cart',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add items to your cart to proceed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
          child: VStack([
          // Order Items
          _buildOrderItems(),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Delivery Address
          _buildDeliveryAddress(),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Delivery Time
          _buildDeliveryTime(),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Payment Method
          _buildPaymentMethod(),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Order Summary
          _buildOrderSummary(),
          
          UiSpacer.verticalSpace(space: 20),
          
          // Place Order Button
          CustomButton(
            title: "Place Order - \$${_total.toStringAsFixed(2)}",
            color: AppColor.primaryColor,
            onPressed: _placeOrder,
          ).wFull(context),
        ]),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: VStack([
        "Order Items".text.bold.xl.make(),
        UiSpacer.verticalSpace(space: 12),
        
        for (var item in _orderItems) ...[
          HStack([
            Expanded(
              child: VStack([
                item['name'].toString().text.bold.make(),
                item['restaurant'].toString().text.gray600.sm.make(),
              ], crossAlignment: CrossAxisAlignment.start),
            ),
            "x${item['quantity']}".text.make(),
            UiSpacer.horizontalSpace(space: 16),
            "\$${(item['price'] * item['quantity']).toStringAsFixed(2)}".text.bold.make(),
          ]),
          if (item != _orderItems.last) UiSpacer.verticalSpace(space: 8),
        ],
      ]),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: EnhancedLocationSearch(
        label: "Delivery Address",
        initialValue: _deliveryAddress == 'Tap to set delivery address' ? null : _deliveryAddress,
        hintText: "Search for delivery address...",
        onLocationSelected: (address, coordinates) {
          setState(() {
            _deliveryAddress = address;
            _deliveryCoordinates = coordinates;
          });
        },
      ),
    );
  }

  Widget _buildDeliveryTime() {
    return Container(
      padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
        borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
            blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: VStack([
        "Delivery Time".text.bold.xl.make(),
        UiSpacer.verticalSpace(space: 12),
        
        _buildDeliveryTimeOption('asap', 'ASAP (25-30 min)', 'Fastest delivery'),
        UiSpacer.verticalSpace(space: 8),
        _buildDeliveryTimeOption('scheduled', 'Schedule for later', 'Choose your preferred time'),
      ]),
    );
  }

  Widget _buildDeliveryTimeOption(String value, String title, String subtitle) {
    final isSelected = _selectedDeliveryTime == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryTime = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: HStack([
          Expanded(
            child: VStack([
              title.text.bold.make(),
              subtitle.text.gray600.sm.make(),
            ], crossAlignment: CrossAxisAlignment.start),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: AppColor.primaryColor),
              ]),
            ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: VStack([
        "Payment Method".text.bold.xl.make(),
        UiSpacer.verticalSpace(space: 12),
        
        _buildPaymentOption('post_service', 'Pay After Service', Icons.schedule),
        UiSpacer.verticalSpace(space: 8),
        _buildWalletPaymentOption(),
        UiSpacer.verticalSpace(space: 8),
        _buildPaymentOption('card', 'Credit/Debit Card', Icons.credit_card),
        UiSpacer.verticalSpace(space: 8),
        _buildPaymentOption('cash', 'Cash on Delivery', Icons.money),
        UiSpacer.verticalSpace(space: 8),
        _buildPaymentOption('mobile', 'Mobile Money', Icons.phone_android),
      ]),
    );
  }

  Widget _buildWalletPaymentOption() {
    final isSelected = _selectedPaymentMethod == 'wallet';
    final hasInsufficientBalance = _walletBalance < _total;
    
    return GestureDetector(
      onTap: hasInsufficientBalance ? null : () {
        setState(() {
          _selectedPaymentMethod = 'wallet';
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
          color: hasInsufficientBalance 
              ? Colors.red.shade50 
              : (isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: HStack([
          Icon(
            Icons.account_balance_wallet,
            color: hasInsufficientBalance 
                ? Colors.red 
                : (isSelected ? AppColor.primaryColor : Colors.grey.shade600),
          ),
          UiSpacer.horizontalSpace(space: 12),
          Expanded(
            child: VStack([
              "Wallet Balance".text.bold.make(),
              if (_isLoadingWallet)
                "Loading...".text.gray500.sm.make()
              else if (hasInsufficientBalance)
                "Insufficient balance (UGX ${_walletBalance.toStringAsFixed(0)})".text.color(Colors.red).sm.make()
              else
                "UGX ${_walletBalance.toStringAsFixed(0)}".text.color(Colors.green).sm.make(),
            ]),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: AppColor.primaryColor,
            ),
        ]),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: HStack([
          Icon(icon, color: isSelected ? AppColor.primaryColor : Colors.grey.shade600),
          UiSpacer.horizontalSpace(space: 12),
          title.text.bold.make(),
          Spacer(),
          if (isSelected)
            Icon(Icons.check_circle, color: AppColor.primaryColor),
        ]),
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: VStack([
        "Order Summary".text.bold.xl.make(),
        UiSpacer.verticalSpace(space: 12),
        
        HStack([
          "Subtotal".text.make(),
          Spacer(),
          "\$${_subtotal.toStringAsFixed(2)}".text.make(),
        ]),
        
        UiSpacer.verticalSpace(space: 8),
        
        HStack([
          "Delivery Fee".text.make(),
          Spacer(),
          "\$${_deliveryFee.toStringAsFixed(2)}".text.make(),
        ]),
        
        UiSpacer.verticalSpace(space: 8),
        
        HStack([
          "Service Fee".text.make(),
          Spacer(),
          "\$${_serviceFee.toStringAsFixed(2)}".text.make(),
        ]),
        
        UiSpacer.verticalSpace(space: 8),
        
        HStack([
          "Discount (FIRST50)".text.color(Colors.green).make(),
          Spacer(),
          "-\$${_discount.toStringAsFixed(2)}".text.color(Colors.green).make(),
        ]),
        
        UiSpacer.verticalSpace(space: 12),
        
        Divider(),
        
        UiSpacer.verticalSpace(space: 12),
        
        HStack([
          "Total".text.bold.xl.make(),
        Spacer(),
          "\$${_total.toStringAsFixed(2)}".text.bold.xl.color(AppColor.primaryColor).make(),
        ]),
      ]),
    );
  }

  Future<bool> _showPostServicePaymentDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.schedule, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            "Pay After Service".text.bold.xl.make(),
          ],
        ),
        content: VStack([
          "You will pay after receiving your order".text.make(),
          SizedBox(height: 16),
          "Total Amount: UGX ${_total.toStringAsFixed(0)}".text.bold.make(),
          SizedBox(height: 8),
          "Payment will be requested when your order is delivered".text.gray600.sm.make(),
          SizedBox(height: 8),
          "You can pay using wallet, card, or cash".text.gray600.sm.make(),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: "Cancel".text.color(Colors.grey).make(),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: "Confirm Order".text.bold.make(),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool?> _showInsufficientBalanceDialog() async {
    final shortfall = _total - _walletBalance;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.red, size: 28),
            SizedBox(width: 8),
            "Insufficient Balance".text.bold.xl.make(),
          ],
        ),
        content: VStack([
          "Your wallet balance is insufficient for this order".text.make(),
          SizedBox(height: 16),
          HStack([
            "Current Balance:".text.make(),
            Spacer(),
            "UGX ${_walletBalance.toStringAsFixed(0)}".text.bold.make(),
          ]),
          SizedBox(height: 8),
          HStack([
            "Order Total:".text.make(),
            Spacer(),
            "UGX ${_total.toStringAsFixed(0)}".text.bold.make(),
          ]),
          SizedBox(height: 8),
          HStack([
            "Shortfall:".text.red600.bold.make(),
            Spacer(),
            "UGX ${shortfall.toStringAsFixed(0)}".text.red600.bold.make(),
          ]),
          SizedBox(height: 16),
          "What would you like to do?".text.bold.make(),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null), // Cancel
            child: "Cancel".text.color(Colors.grey).make(),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Choose another method
            child: "Choose Another Method".text.color(Colors.blue).make(),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Top up wallet
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: "Top Up Wallet".text.bold.make(),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    
    // Validate wallet payment
    if (_selectedPaymentMethod == 'wallet' && _walletBalance < _total) {
      final shouldTopUp = await _showInsufficientBalanceDialog();
      if (shouldTopUp == true) {
        // Navigate to wallet top-up
        Navigator.of(context).pushNamed('/wallet');
        return;
      } else if (shouldTopUp == false) {
        // User wants to choose another payment method
        return;
      }
      // If null, user cancelled - don't proceed
      return;
    }
    
    // For post-service payment, show confirmation
    if (_selectedPaymentMethod == 'post_service') {
      final confirmed = await _showPostServicePaymentDialog();
      if (!confirmed) return;
    }
    
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              UiSpacer.verticalSpace(space: 16),
              "Placing your order...".text.make(),
            ],
          ),
        ),
      );

      // Prepare order data
      final orderData = {
        'items': _orderItems,
        'delivery_address': _deliveryAddress,
        'delivery_time': _selectedDeliveryTime,
        'payment_method': _selectedPaymentMethod,
        'subtotal': _subtotal,
        'delivery_fee': _deliveryFee,
        'service_fee': _serviceFee,
        'discount': _discount,
        'total': _total,
        'order_date': DateTime.now().toIso8601String(),
      };

      // Place order via API
      final response = await _cartApiService.placeOrder(
        items: _orderItems,
        deliveryAddress: _deliveryAddress,
        deliveryTime: _selectedDeliveryTime,
        paymentMethod: _selectedPaymentMethod,
        subtotal: _subtotal,
        deliveryFee: _deliveryFee,
        serviceFee: _serviceFee,
        discount: _discount,
        total: _total,
      );
      
      if (!response.allGood) {
        throw Exception(response.message ?? 'Failed to place order');
      }
      
      // Simulate successful order placement
      final orderId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: "Order Placed!".text.bold.xl.make(),
          content: VStack([
            "Your order has been placed successfully!".text.make(),
            UiSpacer.verticalSpace(space: 8),
            "Order ID: #$orderId".text.bold.make(),
            UiSpacer.verticalSpace(space: 8),
            "Estimated delivery: 25-30 minutes".text.gray600.make(),
            UiSpacer.verticalSpace(space: 8),
            "The vendor has been notified and will start preparing your order.".text.gray600.sm.make(),
          ]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate back to home page and clear cart
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: "OK".text.color(AppColor.primaryColor).bold.make(),
            ),
          ],
        ),
      );
      
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: "Order Failed".text.bold.xl.make(),
          content: "Failed to place order. Please try again.".text.make(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: "OK".text.color(AppColor.primaryColor).bold.make(),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }
}