import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_zone.dart';
import 'firebase_service.dart';

class DeliveryZoneService {
  static DeliveryZoneService? _instance;
  static DeliveryZoneService get instance => _instance ??= DeliveryZoneService._();
  
  DeliveryZoneService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Delivery Zone CRUD operations
  Future<List<DeliveryZone>> getDeliveryZones(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.getCollectionWhere('deliveryZones', 'vendorId', vendorId);
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return DeliveryZone.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting delivery zones: $e');
      return [];
    }
  }

  Future<DeliveryZone?> getDeliveryZone(String zoneId) async {
    try {
      final doc = await _firebaseService.getDocument('deliveryZones', zoneId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return DeliveryZone.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting delivery zone: $e');
      return null;
    }
  }

  Future<bool> addDeliveryZone(DeliveryZone zone) async {
    try {
      await _firebaseService.setDocument('deliveryZones', zone.id, zone.toMap());
      return true;
    } catch (e) {
      print('Error adding delivery zone: $e');
      return false;
    }
  }

  Future<bool> updateDeliveryZone(DeliveryZone zone) async {
    try {
      await _firebaseService.updateDocument('deliveryZones', zone.id, zone.toMap());
      return true;
    } catch (e) {
      print('Error updating delivery zone: $e');
      return false;
    }
  }

  Future<bool> deleteDeliveryZone(String zoneId) async {
    try {
      await _firebaseService.deleteDocument('deliveryZones', zoneId);
      return true;
    } catch (e) {
      print('Error deleting delivery zone: $e');
      return false;
    }
  }

  // Toggle zone status
  Future<bool> toggleZoneStatus(String zoneId, bool isActive) async {
    try {
      await _firebaseService.updateDocument('deliveryZones', zoneId, {
        'isActive': isActive,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error toggling zone status: $e');
      return false;
    }
  }

  // Get active delivery zones
  Future<List<DeliveryZone>> getActiveDeliveryZones(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('deliveryZones')
          .where('vendorId', isEqualTo: vendorId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DeliveryZone.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting active delivery zones: $e');
      return [];
    }
  }

  // Stream delivery zones for real-time updates
  Stream<List<DeliveryZone>> streamDeliveryZones(String vendorId) {
    return _firebaseService.firestore
        .collection('deliveryZones')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DeliveryZone.fromMap(data);
      }).toList();
    });
  }

  // Check if address is within delivery zones
  Future<DeliveryZone?> findDeliveryZoneForAddress(String vendorId, String address) async {
    try {
      final zones = await getActiveDeliveryZones(vendorId);
      
      // Simple text matching - in a real app, you'd use geocoding and distance calculations
      for (final zone in zones) {
        if (address.toLowerCase().contains(zone.coverageArea.toLowerCase())) {
          return zone;
        }
      }
      
      return null;
    } catch (e) {
      print('Error finding delivery zone for address: $e');
      return null;
    }
  }

  // Calculate delivery fee for an address
  Future<double> calculateDeliveryFee(String vendorId, String address, double orderAmount) async {
    try {
      final zone = await findDeliveryZoneForAddress(vendorId, address);
      
      if (zone == null) {
        return 0.0; // No delivery available
      }
      
      if (orderAmount >= zone.minOrderAmount) {
        return zone.deliveryFee;
      } else {
        return zone.deliveryFee + (zone.minOrderAmount - orderAmount);
      }
    } catch (e) {
      print('Error calculating delivery fee: $e');
      return 0.0;
    }
  }
}
