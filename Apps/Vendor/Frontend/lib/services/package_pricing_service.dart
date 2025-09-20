import '../models/package_pricing.dart';
import 'firebase_service.dart';

class PackagePricingService {
  static PackagePricingService? _instance;
  static PackagePricingService get instance => _instance ??= PackagePricingService._();
  
  PackagePricingService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Package Pricing CRUD operations
  Future<List<PackagePricing>> getPackagePricings(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.getCollectionWhere('packagePricings', 'vendorId', vendorId);
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PackagePricing.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting package pricings: $e');
      return [];
    }
  }

  Future<PackagePricing?> getPackagePricing(String pricingId) async {
    try {
      final doc = await _firebaseService.getDocument('packagePricings', pricingId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PackagePricing.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting package pricing: $e');
      return null;
    }
  }

  Future<bool> addPackagePricing(PackagePricing pricing) async {
    try {
      await _firebaseService.setDocument('packagePricings', pricing.id, pricing.toMap());
      return true;
    } catch (e) {
      print('Error adding package pricing: $e');
      return false;
    }
  }

  Future<bool> updatePackagePricing(PackagePricing pricing) async {
    try {
      await _firebaseService.updateDocument('packagePricings', pricing.id, pricing.toMap());
      return true;
    } catch (e) {
      print('Error updating package pricing: $e');
      return false;
    }
  }

  Future<bool> deletePackagePricing(String pricingId) async {
    try {
      await _firebaseService.deleteDocument('packagePricings', pricingId);
      return true;
    } catch (e) {
      print('Error deleting package pricing: $e');
      return false;
    }
  }

  // Toggle pricing status
  Future<bool> togglePricingStatus(String pricingId, bool isActive) async {
    try {
      await _firebaseService.updateDocument('packagePricings', pricingId, {
        'isActive': isActive,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error toggling pricing status: $e');
      return false;
    }
  }

  // Get active package pricings
  Future<List<PackagePricing>> getActivePackagePricings(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('packagePricings')
          .where('vendorId', isEqualTo: vendorId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PackagePricing.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting active package pricings: $e');
      return [];
    }
  }

  // Stream package pricings for real-time updates
  Stream<List<PackagePricing>> streamPackagePricings(String vendorId) {
    return _firebaseService.firestore
        .collection('packagePricings')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PackagePricing.fromMap(data);
      }).toList();
    });
  }

  // Calculate delivery price
  Future<double> calculateDeliveryPrice(String vendorId, double distanceKm, double weightKg) async {
    try {
      final pricings = await getActivePackagePricings(vendorId);
      
      if (pricings.isEmpty) {
        return 0.0; // No pricing available
      }
      
      // Use the first active pricing (in a real app, you might have logic to select the best pricing)
      final pricing = pricings.first;
      return pricing.calculatePrice(distanceKm, weightKg);
    } catch (e) {
      print('Error calculating delivery price: $e');
      return 0.0;
    }
  }
}
