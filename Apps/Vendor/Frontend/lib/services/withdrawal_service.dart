import '../models/withdrawal.dart';
import 'firebase_service.dart';

class WithdrawalService {
  static WithdrawalService? _instance;
  static WithdrawalService get instance => _instance ??= WithdrawalService._();
  
  WithdrawalService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Withdrawal CRUD operations
  Future<List<Withdrawal>> getWithdrawals(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.getCollectionWhere('withdrawals', 'vendorId', vendorId);
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Withdrawal.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting withdrawals: $e');
      return [];
    }
  }

  Future<Withdrawal?> getWithdrawal(String withdrawalId) async {
    try {
      final doc = await _firebaseService.getDocument('withdrawals', withdrawalId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Withdrawal.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting withdrawal: $e');
      return null;
    }
  }

  Future<bool> createWithdrawal(Withdrawal withdrawal) async {
    try {
      await _firebaseService.setDocument('withdrawals', withdrawal.id, withdrawal.toJson());
      return true;
    } catch (e) {
      print('Error creating withdrawal: $e');
      return false;
    }
  }

  Future<bool> updateWithdrawal(Withdrawal withdrawal) async {
    try {
      await _firebaseService.updateDocument('withdrawals', withdrawal.id, withdrawal.toJson());
      return true;
    } catch (e) {
      print('Error updating withdrawal: $e');
      return false;
    }
  }

  Future<bool> cancelWithdrawal(String withdrawalId) async {
    try {
      await _firebaseService.updateDocument('withdrawals', withdrawalId, {
        'status': 'cancelled',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error cancelling withdrawal: $e');
      return false;
    }
  }

  // Get vendor balance
  Future<double> getVendorBalance(String vendorId) async {
    try {
      // In a real app, this would calculate from completed orders minus withdrawals
      // For demo purposes, return a mock balance
      return 1250.75;
    } catch (e) {
      print('Error getting vendor balance: $e');
      return 0.0;
    }
  }

  // Get pending withdrawals amount
  Future<double> getPendingWithdrawalsAmount(String vendorId) async {
    try {
      final withdrawals = await getWithdrawals(vendorId);
      return withdrawals
          .where((w) => w.status == 'pending' || w.status == 'processing')
          .fold<double>(0.0, (sum, w) => sum + w.amount);
    } catch (e) {
      print('Error getting pending withdrawals amount: $e');
      return 0.0;
    }
  }

  // Get available balance (total - pending withdrawals)
  Future<double> getAvailableBalance(String vendorId) async {
    try {
      final totalBalance = await getVendorBalance(vendorId);
      final pendingAmount = await getPendingWithdrawalsAmount(vendorId);
      return totalBalance - pendingAmount;
    } catch (e) {
      print('Error getting available balance: $e');
      return 0.0;
    }
  }

  // Check if withdrawal amount is valid
  Future<bool> isValidWithdrawalAmount(String vendorId, double amount) async {
    try {
      const minWithdrawalAmount = 10.0; // Minimum $10
      const maxWithdrawalAmount = 10000.0; // Maximum $10,000
      
      if (amount < minWithdrawalAmount || amount > maxWithdrawalAmount) {
        return false;
      }
      
      final availableBalance = await getAvailableBalance(vendorId);
      return amount <= availableBalance;
    } catch (e) {
      print('Error validating withdrawal amount: $e');
      return false;
    }
  }

  // Get withdrawal history with filters
  Future<List<Withdrawal>> getWithdrawalHistory(
    String vendorId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _firebaseService.firestore
          .collection('withdrawals')
          .where('vendorId', isEqualTo: vendorId);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      
      if (startDate != null) {
        query = query.where('requestedAt', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch);
      }
      
      if (endDate != null) {
        query = query.where('requestedAt', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);
      }
      
      final querySnapshot = await query.orderBy('requestedAt', descending: true).get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Withdrawal.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting withdrawal history: $e');
      return [];
    }
  }

  // Stream withdrawals for real-time updates
  Stream<List<Withdrawal>> streamWithdrawals(String vendorId) {
    return _firebaseService.firestore
        .collection('withdrawals')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Withdrawal.fromMap(data);
      }).toList();
    });
  }

  // Get withdrawal statistics
  Future<Map<String, dynamic>> getWithdrawalStats(String vendorId) async {
    try {
      final withdrawals = await getWithdrawals(vendorId);
      
      final totalWithdrawn = withdrawals
          .where((w) => w.status == 'completed')
          .fold(0.0, (sum, w) => sum + w.amount);
      
      final pendingAmount = withdrawals
          .where((w) => w.status == 'pending' || w.status == 'processing')
          .fold(0.0, (sum, w) => sum + w.amount);
      
      final totalRequests = withdrawals.length;
      final completedRequests = withdrawals.where((w) => w.status == 'completed').length;
      final failedRequests = withdrawals.where((w) => w.status == 'failed').length;
      
      return {
        'totalWithdrawn': totalWithdrawn,
        'pendingAmount': pendingAmount,
        'totalRequests': totalRequests,
        'completedRequests': completedRequests,
        'failedRequests': failedRequests,
        'successRate': totalRequests > 0 ? (completedRequests / totalRequests) * 100 : 0.0,
      };
    } catch (e) {
      print('Error getting withdrawal stats: $e');
      return {
        'totalWithdrawn': 0.0,
        'pendingAmount': 0.0,
        'totalRequests': 0,
        'completedRequests': 0,
        'failedRequests': 0,
        'successRate': 0.0,
      };
    }
  }
}
