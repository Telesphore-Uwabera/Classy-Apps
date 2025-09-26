import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/services/cart.service.dart';
import 'package:Classy/services/cart_api.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/views/pages/food/order_confirmation.page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  double _totalAmount = 0.0;
  double _deliveryFee = 2.99;
  double _serviceFee = 1.50;
  bool _isLoading = false;
  
  final CartApiService _cartApiService = CartApiService();

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _cartApiService.getCartItems();
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        setState(() {
          _cartItems = List<Map<String, dynamic>>.from(response.body!['data']);
          _calculateTotal();
        });
      } else {
        // If no items in cart, show empty state
        setState(() {
          _cartItems = [];
          _calculateTotal();
        });
      }
    } catch (e) {
      print('Error loading cart items: $e');
      setState(() {
        _cartItems = [];
        _calculateTotal();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotal() {
    double subtotal = 0.0;
    for (var item in _cartItems) {
      subtotal += (item['price'] * item['quantity']);
    }
    setState(() {
      _totalAmount = subtotal + _deliveryFee + _serviceFee;
    });
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(index);
    } else {
      try {
        final cartItemId = _cartItems[index]['id'].toString();
        final response = await _cartApiService.updateCartItem(
          cartItemId: cartItemId,
          quantity: newQuantity,
        );
        
        if (response.allGood) {
          setState(() {
            _cartItems[index]['quantity'] = newQuantity;
            _calculateTotal();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update quantity')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating quantity: $e')),
        );
      }
    }
  }

  Future<void> _removeItem(int index) async {
    try {
      final cartItemId = _cartItems[index]['id'].toString();
      final response = await _cartApiService.removeFromCart(cartItemId);
      
      if (response.allGood) {
        setState(() {
          _cartItems.removeAt(index);
          _calculateTotal();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item removed from cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Shopping Cart",
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? _buildEmptyCart()
              : VStack([
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(_cartItems[index], index);
                  },
                ),
              ),
              
              // Order Summary
              _buildOrderSummary(),
            ]),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
              child: VStack([
        Icon(
          Icons.shopping_cart_outlined,
          size: 100,
          color: Colors.grey.shade400,
        ),
        UiSpacer.verticalSpace(space: 20),
        "Your cart is empty".text.xl2.bold.gray600.make(),
        UiSpacer.verticalSpace(space: 8),
        "Add some delicious food to get started!".text.gray500.make(),
        UiSpacer.verticalSpace(space: 30),
        CustomButton(
          title: "Browse Food",
          color: AppColor.primaryColor,
                        onPressed: () => Navigator.of(context).pop(),
        ).wFull(context),
      ]),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: HStack([
        // Food Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item['image'],
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade300,
                child: Icon(Icons.restaurant, color: Colors.grey.shade600),
              );
            },
          ),
        ),
        
        UiSpacer.horizontalSpace(space: 16),
        
        // Food Details
        Expanded(
          child: VStack([
            item['name'].toString().text.bold.lg.make(),
            UiSpacer.verticalSpace(space: 4),
            item['restaurant'].toString().text.gray600.make(),
            UiSpacer.verticalSpace(space: 4),
            item['description'].toString().text.gray500.sm.make(),
            UiSpacer.verticalSpace(space: 8),
            "\$${item['price'].toStringAsFixed(2)}".text.bold.color(AppColor.primaryColor).make(),
          ], crossAlignment: CrossAxisAlignment.start),
        ),
        
        // Quantity Controls
                  VStack([
          // Remove Button
          GestureDetector(
            onTap: () => _removeItem(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
          ),
          
          UiSpacer.verticalSpace(space: 8),
          
          // Quantity Controls
          HStack([
            GestureDetector(
              onTap: () => _updateQuantity(index, item['quantity'] - 1),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.remove, size: 16),
              ),
            ),
            
            UiSpacer.horizontalSpace(space: 12),
            
            item['quantity'].toString().text.bold.make(),
            
            UiSpacer.horizontalSpace(space: 12),
            
            GestureDetector(
              onTap: () => _updateQuantity(index, item['quantity'] + 1),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildOrderSummary() {
    double subtotal = 0.0;
    for (var item in _cartItems) {
      subtotal += (item['price'] * item['quantity']);
    }

    return Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
            color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          child: VStack([
        // Order Summary Header
        "Order Summary".text.bold.xl.make(),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Summary Details
        HStack([
          "Subtotal".text.make(),
          Spacer(),
          "\$${subtotal.toStringAsFixed(2)}".text.make(),
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
        
        UiSpacer.verticalSpace(space: 12),
        
        Divider(),
        
        UiSpacer.verticalSpace(space: 12),
        
        HStack([
          "Total".text.bold.xl.make(),
          Spacer(),
          "\$${_totalAmount.toStringAsFixed(2)}".text.bold.xl.color(AppColor.primaryColor).make(),
        ]),
        
        UiSpacer.verticalSpace(space: 20),
        
        // Checkout Button
                            CustomButton(
          title: "Proceed to Checkout",
          color: AppColor.primaryColor,
          onPressed: () {
            // Navigate to order confirmation page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderConfirmationPage(),
              ),
            );
          },
        ).wFull(context),
      ]),
    );
  }
}