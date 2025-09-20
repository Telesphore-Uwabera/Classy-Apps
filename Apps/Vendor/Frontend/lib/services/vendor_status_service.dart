import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor.dart';
import 'firebase_service.dart';

class VendorStatusService {
  static VendorStatusService? _instance;
  static VendorStatusService get instance => _instance ??= VendorStatusService._();
  
  VendorStatusService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Update vendor online status
  Future<bool> updateVendorStatus(String vendorId, String status) async {
    try {
      await _firebaseService.updateDocument('vendors', vendorId, {
        'status': status,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error updating vendor status: $e');
      return false;
    }
  }

  // Get vendor status
  Future<String> getVendorStatus(String vendorId) async {
    try {
      final doc = await _firebaseService.getDocument('vendors', vendorId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] ?? 'offline';
      }
      return 'offline';
    } catch (e) {
      print('Error getting vendor status: $e');
      return 'offline';
    }
  }

  // Set vendor online
  Future<bool> setVendorOnline(String vendorId) async {
    return await updateVendorStatus(vendorId, 'online');
  }

  // Set vendor offline
  Future<bool> setVendorOffline(String vendorId) async {
    return await updateVendorStatus(vendorId, 'offline');
  }

  // Set vendor busy
  Future<bool> setVendorBusy(String vendorId) async {
    return await updateVendorStatus(vendorId, 'busy');
  }

  // Stream vendor status for real-time updates
  Stream<String> streamVendorStatus(String vendorId) {
    return _firebaseService.firestore
        .collection('vendors')
        .doc(vendorId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['status'] ?? 'offline';
      }
      return 'offline';
    });
  }

  // Get all online vendors
  Future<List<Vendor>> getOnlineVendors() async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('vendors')
          .where('status', isEqualTo: 'online')
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Vendor.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting online vendors: $e');
      return [];
    }
  }

  // Update last seen timestamp
  Future<bool> updateLastSeen(String vendorId) async {
    try {
      await _firebaseService.updateDocument('vendors', vendorId, {
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error updating last seen: $e');
      return false;
    }
  }

  // Check if vendor is available for orders
  Future<bool> isVendorAvailable(String vendorId) async {
    try {
      final status = await getVendorStatus(vendorId);
      return status == 'online';
    } catch (e) {
      print('Error checking vendor availability: $e');
      return false;
    }
  }
}
