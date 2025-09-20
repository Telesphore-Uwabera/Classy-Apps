import 'dart:async';
import 'package:Classy/models/cart.dart';
import 'package:Classy/models/coupon.dart';
import 'package:Classy/models/product.dart';
import 'package:Classy/services/firebase_cart.service.dart';

class CartServices {
  static final FirebaseCartService _firebaseService = FirebaseCartService();

  // Legacy keys for backward compatibility
  static String cartItemsKey = "cart_items";
  static String totalItemKey = "total_cart_items";
  static StreamController<int> cartItemsCountStream = StreamController.broadcast();
  
  // Cart items
  static List<Cart> productsInCart = [];

  /// Initialize cart service
  static void initialize() {
    _firebaseService.initialize();
    
    // Connect Firebase streams to legacy streams
    _firebaseService.cartStream.listen((cartItems) {
      productsInCart = cartItems;
      cartItemsCountStream.add(cartItems.length);
    });
  }

  /// Get cart items
  static Future<void> getCartItems() async {
    await _firebaseService.getCartItems();
    productsInCart = FirebaseCartService.productsInCart;
    cartItemsCountStream.add(productsInCart.length);
  }

  /// Check if can add to cart
  static bool canAddToCart(Cart cart) {
    return _firebaseService.canAddToCart(cart);
  }

  /// Check if can add digital product to cart
  static bool canAddDigitalProductToCart(Cart cart) {
    return _firebaseService.canAddDigitalProductToCart(cart);
  }

  /// Check if all cart products are digital
  static bool allCartProductsDigital() {
    return _firebaseService.allCartProductsDigital();
  }

  /// Clear cart
  static Future<void> clearCart() async {
    await _firebaseService.clearCart();
    productsInCart = FirebaseCartService.productsInCart;
    cartItemsCountStream.add(productsInCart.length);
  }

  /// Add to cart
  static Future<void> addToCart(Cart cart) async {
    await _firebaseService.addToCart(cart);
    productsInCart = FirebaseCartService.productsInCart;
    cartItemsCountStream.add(productsInCart.length);
  }

  /// Save cart items
  static Future<void> saveCartItems(List<Cart> cartItems) async {
    await _firebaseService.saveCartItems(cartItems);
    productsInCart = FirebaseCartService.productsInCart;
    cartItemsCountStream.add(productsInCart.length);
  }

  /// Update total cart item count
  static Future<void> updateTotalCartItemCount(int total) async {
    await _firebaseService.updateTotalCartItemCount(total);
  }

  /// Check if multiple order
  static bool isMultipleOrder() {
    return _firebaseService.isMultipleOrder();
  }

  /// Get vendor subtotal
  static double vendorSubTotal(int id) {
    return _firebaseService.vendorSubTotal(id);
  }

  /// Get vendor order discount
  static double vendorOrderDiscount(int id, Coupon coupon) {
    return _firebaseService.vendorOrderDiscount(id, coupon);
  }

  /// Get multiple vendor order payload
  static List<Map> multipleVendorOrderPayload(int id) {
    return _firebaseService.multipleVendorOrderPayload(id);
  }

  /// Get product quantity in cart
  static Future<int> productQtyInCart(Product product) async {
    return await _firebaseService.productQtyInCart(product);
  }

  /// Get product quantity allowed
  static Future<int> productQtyAllowed(Product product) async {
    return await _firebaseService.productQtyAllowed(product);
  }

  /// Check if cart item quantity is available
  static Future<bool> cartItemQtyAvailable(Product product) async {
    return await _firebaseService.cartItemQtyAvailable(product);
  }

  /// Get total subtotal
  static double get totalSubtotal {
    return _firebaseService.totalSubtotal;
  }

  /// Refresh state
  static Future<void> refreshState() async {
    await _firebaseService.refreshState();
    productsInCart = FirebaseCartService.productsInCart;
    cartItemsCountStream.add(productsInCart.length);
  }

  /// Dispose resources
  static void dispose() {
    _firebaseService.dispose();
  }
}
