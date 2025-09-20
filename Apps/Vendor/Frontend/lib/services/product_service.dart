import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'firebase_service.dart';

class ProductService {
  static ProductService? _instance;
  static ProductService get instance => _instance ??= ProductService._();
  
  ProductService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Product CRUD operations - Optimized for speed
  Future<List<Product>> getProducts(String vendorId) async {
    try {
      // Use limit to get only essential data quickly
      final querySnapshot = await _firebaseService.firestore
          .collection('products')
          .where('vendorId', isEqualTo: vendorId)
          .limit(50) // Limit for faster loading
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firebaseService.getDocument('products', productId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      await _firebaseService.setDocument('products', product.id.toString(), product.toJson());
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _firebaseService.updateDocument('products', product.id.toString(), product.toJson());
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _firebaseService.deleteDocument('products', productId);
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Category operations
  Future<List<Category>> getCategories() async {
    try {
      final querySnapshot = await _firebaseService.getCollectionWhere('categories', 'status', 'active');
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Category.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<bool> addCategory(Category category) async {
    try {
      await _firebaseService.setDocument('categories', category.id.toString(), category.toJson());
      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String vendorId, String query) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('products')
          .where('vendorId', isEqualTo: vendorId)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Stream products for real-time updates
  Stream<List<Product>> streamProducts(String vendorId) {
    return _firebaseService.firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    });
  }

  // Update product stock
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      await _firebaseService.updateDocument('products', productId, {
        'stock': newStock,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  // Update product status
  Future<bool> updateStatus(String productId, String status) async {
    try {
      await _firebaseService.updateDocument('products', productId, {
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }
}
