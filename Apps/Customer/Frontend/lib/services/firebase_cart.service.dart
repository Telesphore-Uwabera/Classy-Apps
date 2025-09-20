import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartx/dartx.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/cart.dart';
import 'package:Classy/models/coupon.dart';
import 'package:Classy/models/product.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/local_storage.service.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class FirebaseCartService {
  static final FirebaseCartService _instance = FirebaseCartService._internal();
  factory FirebaseCartService() => _instance;
  FirebaseCartService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controllers for real-time cart updates
  final StreamController<List<Cart>> _cartController = StreamController<List<Cart>>.broadcast();
  final StreamController<int> _cartCountController = StreamController<int>.broadcast();

  // Streams for listening to cart data
  Stream<List<Cart>> get cartStream => _cartController.stream;
  Stream<int> get cartCountStream => _cartCountController.stream;

  // Stream subscription
  StreamSubscription<QuerySnapshot>? _cartSubscription;

  // Local storage keys
  static String cartItemsKey = "cart_items";
  static String totalItemKey = "total_cart_items";

  // Cart items
  static List<Cart> productsInCart = [];

  /// Initialize cart service
  void initialize() {
    _startRealTimeUpdates();
    _loadCartFromLocalStorage();
  }

  /// Start real-time updates for cart
  void _startRealTimeUpdates() {
    final currentUser = AuthServices.currentUser;
    if (currentUser?.id == null) return;

    _cartSubscription?.cancel();
    _cartSubscription = _firestore
        .collection('carts')
        .where('user_id', isEqualTo: currentUser!.id.toString())
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      final cartItems = snapshot.docs.map((doc) {
        final data = doc.data();
        return Cart.fromJson(data);
      }).toList();
      
      productsInCart = cartItems;
      _cartController.add(cartItems);
      _cartCountController.add(cartItems.length);
    });
  }

  /// Load cart from local storage as fallback
  Future<void> _loadCartFromLocalStorage() async {
    try {
      final cartList = await LocalStorageService.prefs!.getString(cartItemsKey);
      
      if (cartList != null && cartList.isNotEmpty) {
        try {
          productsInCart = (jsonDecode(cartList) as List).map((cartObject) {
            return Cart.fromJson(cartObject);
          }).toList();
        } catch (error) {
          productsInCart = [];
        }
      } else {
        productsInCart = [];
      }
      
      _cartController.add(productsInCart);
      _cartCountController.add(productsInCart.length);
    } catch (e) {
      print("❌ Error loading cart from local storage: $e");
    }
  }

  /// Get cart items
  Future<void> getCartItems() async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        await _loadCartFromLocalStorage();
        return;
      }

      final snapshot = await _firestore
          .collection('carts')
          .where('user_id', isEqualTo: currentUser!.id.toString())
          .where('status', isEqualTo: 'active')
          .get();

      productsInCart = snapshot.docs.map((doc) {
        final data = doc.data();
        return Cart.fromJson(data);
      }).toList();

      _cartController.add(productsInCart);
      _cartCountController.add(productsInCart.length);
    } catch (e) {
      print("❌ Error getting cart items: $e");
      await _loadCartFromLocalStorage();
    }
  }

  /// Add item to cart
  Future<void> addToCart(Cart cart) async {
    try {
      if (cart.selectedQty == null || cart.selectedQty == 0) {
        cart.selectedQty = 1;
      }

      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        // Fallback to local storage
        await _addToLocalCart(cart);
        return;
      }

      // Check if item already exists in cart
      final existingItem = productsInCart.firstOrNullWhere(
        (item) => item.product?.id == cart.product?.id,
      );

      if (existingItem != null) {
        // Update quantity
        await updateCartItemQuantity(existingItem.id ?? '', existingItem.selectedQty! + cart.selectedQty!);
      } else {
        // Add new item
        final cartRef = _firestore.collection('carts').doc();
        final cartData = {
          'id': cartRef.id,
          'user_id': currentUser!.id.toString(),
          'product_id': cart.product?.id,
          'product': cart.product?.toJson(),
          'selected_qty': cart.selectedQty,
          'price': cart.price,
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await cartRef.set(cartData);
      }

      await getCartItems();
    } catch (e) {
      print("❌ Error adding to cart: $e");
      await _addToLocalCart(cart);
    }
  }

  /// Add to local cart (fallback)
  Future<void> _addToLocalCart(Cart cart) async {
    try {
      final mProductsInCart = List<Cart>.from(productsInCart);
      mProductsInCart.add(cart);
      
      await LocalStorageService.prefs!.setString(
        cartItemsKey,
        jsonEncode(mProductsInCart),
      );
      
      productsInCart = mProductsInCart;
      await updateTotalCartItemCount(productsInCart.length);
      await getCartItems();
    } catch (error) {
      print("❌ Error saving cart locally: $error");
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItemQuantity(String cartItemId, int newQuantity) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        // Fallback to local storage
        await _updateLocalCartItemQuantity(cartItemId, newQuantity);
        return;
      }

      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      await _firestore.collection('carts').doc(cartItemId).update({
        'selected_qty': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await getCartItems();
    } catch (e) {
      print("❌ Error updating cart item quantity: $e");
      await _updateLocalCartItemQuantity(cartItemId, newQuantity);
    }
  }

  /// Update local cart item quantity (fallback)
  Future<void> _updateLocalCartItemQuantity(String cartItemId, int newQuantity) async {
    try {
      final mProductsInCart = List<Cart>.from(productsInCart);
      final itemIndex = mProductsInCart.indexWhere((item) => item.id == cartItemId);
      
      if (itemIndex != -1) {
        if (newQuantity <= 0) {
          mProductsInCart.removeAt(itemIndex);
        } else {
          mProductsInCart[itemIndex].selectedQty = newQuantity;
        }
        
        await LocalStorageService.prefs!.setString(
          cartItemsKey,
          jsonEncode(mProductsInCart),
        );
        
        productsInCart = mProductsInCart;
        await updateTotalCartItemCount(productsInCart.length);
        await getCartItems();
      }
    } catch (error) {
      print("❌ Error updating local cart item quantity: $error");
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        // Fallback to local storage
        await _removeFromLocalCart(cartItemId);
        return;
      }

      await _firestore.collection('carts').doc(cartItemId).delete();
      await getCartItems();
    } catch (e) {
      print("❌ Error removing from cart: $e");
      await _removeFromLocalCart(cartItemId);
    }
  }

  /// Remove from local cart (fallback)
  Future<void> _removeFromLocalCart(String cartItemId) async {
    try {
      final mProductsInCart = List<Cart>.from(productsInCart);
      mProductsInCart.removeWhere((item) => item.id == cartItemId);
      
      await LocalStorageService.prefs!.setString(
        cartItemsKey,
        jsonEncode(mProductsInCart),
      );
      
      productsInCart = mProductsInCart;
      await updateTotalCartItemCount(productsInCart.length);
      await getCartItems();
    } catch (error) {
      print("❌ Error removing from local cart: $error");
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        // Fallback to local storage
        await _clearLocalCart();
        return;
      }

      // Delete all cart items for user
      final batch = _firestore.batch();
      final cartItems = await _firestore
          .collection('carts')
          .where('user_id', isEqualTo: currentUser!.id.toString())
          .where('status', isEqualTo: 'active')
          .get();

      for (final doc in cartItems.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      await getCartItems();
    } catch (e) {
      print("❌ Error clearing cart: $e");
      await _clearLocalCart();
    }
  }

  /// Clear local cart (fallback)
  Future<void> _clearLocalCart() async {
    await LocalStorageService.prefs?.setString(cartItemsKey, "");
    await updateTotalCartItemCount(0);
    productsInCart = [];
    await getCartItems();
  }

  /// Save cart items
  Future<void> saveCartItems(List<Cart> cartItems) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        // Fallback to local storage
        await _saveLocalCartItems(cartItems);
        return;
      }

      // Clear existing cart items
      await clearCart();

      // Add new cart items
      final batch = _firestore.batch();
      for (final cartItem in cartItems) {
        final cartRef = _firestore.collection('carts').doc();
        final cartData = {
          'id': cartRef.id,
          'user_id': currentUser!.id.toString(),
          'product_id': cartItem.product?.id,
          'product': cartItem.product?.toJson(),
          'selected_qty': cartItem.selectedQty,
          'price': cartItem.price,
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        batch.set(cartRef, cartData);
      }

      await batch.commit();
      await getCartItems();
    } catch (e) {
      print("❌ Error saving cart items: $e");
      await _saveLocalCartItems(cartItems);
    }
  }

  /// Save local cart items (fallback)
  Future<void> _saveLocalCartItems(List<Cart> cartItems) async {
    await LocalStorageService.prefs?.setString(
      cartItemsKey,
      jsonEncode(cartItems),
    );

    await updateTotalCartItemCount(cartItems.length);
    await getCartItems();
  }

  /// Update total cart item count
  Future<void> updateTotalCartItemCount(int total) async {
    await LocalStorageService.rxPrefs!.setInt(totalItemKey, total);
  }

  /// Check if can add to cart
  bool canAddToCart(Cart cart) {
    if (productsInCart.length > 0) {
      final firstOfferInCart = productsInCart[0];
      if (firstOfferInCart.product?.vendorId == cart.product?.vendorId ||
          AppStrings.enableMultipleVendorOrder) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  /// Check if can add digital product to cart
  bool canAddDigitalProductToCart(Cart cart) {
    if (productsInCart.length > 0) {
      final allDigital = allCartProductsDigital();
      if (allDigital) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  /// Check if all cart products are digital
  bool allCartProductsDigital() {
    if (productsInCart.length > 0) {
      bool result = true;
      for (var productInCart in productsInCart) {
        if (!productInCart.product!.isDigital) {
          result = false;
          break;
        }
      }
      return result;
    } else {
      return true;
    }
  }

  /// Check if multiple order
  bool isMultipleOrder() {
    final vendorIds = productsInCart
        .map((e) => e.product?.vendorId)
        .toList()
        .toSet()
        .toList();
    return vendorIds.length > 1;
  }

  /// Get vendor subtotal
  double vendorSubTotal(int id) {
    double subTotalPrice = 0.0;
    productsInCart.where((e) => e.product?.vendorId == id).forEach(
      (cartItem) {
        double totalProductPrice = (cartItem.price ?? cartItem.product!.sellPrice);
        totalProductPrice = totalProductPrice * cartItem.selectedQty!;
        subTotalPrice += totalProductPrice;
      },
    );
    return subTotalPrice;
  }

  /// Get vendor order discount
  double vendorOrderDiscount(int id, Coupon coupon) {
    double discountCartPrice = 0.0;
    final cartItems = productsInCart
        .where((e) => e.product?.vendorId == id)
        .toList();

    cartItems.forEach((cartItem) {
      final totalProductPrice =
          (cartItem.price ?? cartItem.product!.price) * cartItem.selectedQty!;
      
      final foundProduct = coupon.products.firstOrNullWhere(
        (product) => cartItem.product?.id == product.id,
      );
      final foundVendor = coupon.vendors.firstOrNullWhere(
        (vendor) => cartItem.product?.vendorId == vendor.id,
      );
      
      if (foundProduct != null ||
          foundVendor != null ||
          (coupon.products.isEmpty && coupon.vendors.isEmpty)) {
        if (coupon.percentage == 1) {
          discountCartPrice += (coupon.discount / 100) * totalProductPrice;
        } else {
          discountCartPrice += coupon.discount;
        }
      }
    });
    return discountCartPrice;
  }

  /// Get multiple vendor order payload
  List<Map> multipleVendorOrderPayload(int id) {
    return productsInCart
        .where((e) => e.product?.vendorId == id)
        .map((e) => e.toJson())
        .toList();
  }

  /// Get product quantity in cart
  Future<int> productQtyInCart(Product product) async {
    int addedQty = 0;
    await getCartItems();
    (productsInCart.where((e) => e.product?.id == product.id).toList()).forEach(
      (productInCart) {
        int qty = productInCart.selectedQty!;
        addedQty += qty;
      },
    );
    return addedQty;
  }

  /// Get product quantity allowed
  Future<int> productQtyAllowed(Product product) async {
    int addedQty = await productQtyInCart(product);
    if (product.availableQty == null) {
      return 20;
    }
    return (product.availableQty ?? 20) - addedQty;
  }

  /// Check if cart item quantity is available
  Future<bool> cartItemQtyAvailable(Product product) async {
    int addedQty = await productQtyInCart(product);
    return product.availableQty == null || (addedQty < product.availableQty!);
  }

  /// Get total subtotal
  double get totalSubtotal {
    double total = 0.0;
    productsInCart.forEach((cartItem) {
      double totalProductPrice = (cartItem.price ?? cartItem.product!.sellPrice);
      totalProductPrice = totalProductPrice * cartItem.selectedQty!;
      total += totalProductPrice;
    });
    return total;
  }

  /// Refresh state
  Future<void> refreshState() async {
    await getCartItems();
    int count = productsInCart.length;
    updateTotalCartItemCount(count);
  }

  /// Dispose resources
  void dispose() {
    _cartSubscription?.cancel();
    _cartController.close();
    _cartCountController.close();
  }
}
