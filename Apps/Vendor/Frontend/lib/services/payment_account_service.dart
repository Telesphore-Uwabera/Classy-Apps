import '../models/payment_account.dart';
import 'firebase_service.dart';

class PaymentAccountService {
  static PaymentAccountService? _instance;
  static PaymentAccountService get instance => _instance ??= PaymentAccountService._();
  
  PaymentAccountService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Payment Account CRUD operations
  Future<List<PaymentAccount>> getPaymentAccounts(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.getCollectionWhere('paymentAccounts', 'vendorId', vendorId);
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PaymentAccount.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting payment accounts: $e');
      return [];
    }
  }

  Future<PaymentAccount?> getPaymentAccount(String accountId) async {
    try {
      final doc = await _firebaseService.getDocument('paymentAccounts', accountId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PaymentAccount.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting payment account: $e');
      return null;
    }
  }

  Future<bool> addPaymentAccount(PaymentAccount account) async {
    try {
      await _firebaseService.setDocument('paymentAccounts', account.id.toString(), account.toJson());
      return true;
    } catch (e) {
      print('Error adding payment account: $e');
      return false;
    }
  }

  Future<bool> updatePaymentAccount(PaymentAccount account) async {
    try {
      await _firebaseService.updateDocument('paymentAccounts', account.id.toString(), account.toJson());
      return true;
    } catch (e) {
      print('Error updating payment account: $e');
      return false;
    }
  }

  Future<bool> deletePaymentAccount(String accountId) async {
    try {
      await _firebaseService.deleteDocument('paymentAccounts', accountId);
      return true;
    } catch (e) {
      print('Error deleting payment account: $e');
      return false;
    }
  }

  // Set default payment account
  Future<bool> setDefaultPaymentAccount(String vendorId, String accountId) async {
    try {
      // First, unset all other accounts as default
      final accounts = await getPaymentAccounts(vendorId);
      for (final account in accounts) {
        if (account.id.toString() != accountId && account.isDefault) {
          await _firebaseService.updateDocument('paymentAccounts', account.id.toString(), {
            'isDefault': false,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }

      // Set the selected account as default
      await _firebaseService.updateDocument('paymentAccounts', accountId, {
        'isDefault': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return true;
    } catch (e) {
      print('Error setting default payment account: $e');
      return false;
    }
  }

  // Verify payment account
  Future<bool> verifyPaymentAccount(String accountId) async {
    try {
      await _firebaseService.updateDocument('paymentAccounts', accountId, {
        'isVerified': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error verifying payment account: $e');
      return false;
    }
  }

  // Get default payment account
  Future<PaymentAccount?> getDefaultPaymentAccount(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('paymentAccounts')
          .where('vendorId', isEqualTo: vendorId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        data['id'] = querySnapshot.docs.first.id;
        return PaymentAccount.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting default payment account: $e');
      return null;
    }
  }

  // Stream payment accounts for real-time updates
  Stream<List<PaymentAccount>> streamPaymentAccounts(String vendorId) {
    return _firebaseService.firestore
        .collection('paymentAccounts')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PaymentAccount.fromJson(data);
      }).toList();
    });
  }

  // Validate payment account data
  bool validatePaymentAccount(PaymentAccount account) {
    if (account.accountName.isEmpty) return false;
    if (account.accountNumber.isEmpty) return false;
    if (account.accountHolderName.isEmpty) return false;
    
    switch (account.accountType) {
      case 'bank':
        return account.routingNumber.isNotEmpty && account.bankName.isNotEmpty;
      case 'paypal':
      case 'stripe':
      case 'cashapp':
        return account.email.isNotEmpty;
      default:
        return false;
    }
  }

  // Get supported account types
  List<Map<String, String>> getSupportedAccountTypes() {
    return [
      {
        'type': 'bank',
        'name': 'Bank Account',
        'description': 'Direct bank transfer',
        'icon': '🏦',
      },
      {
        'type': 'paypal',
        'name': 'PayPal',
        'description': 'PayPal account',
        'icon': '💳',
      },
      {
        'type': 'stripe',
        'name': 'Stripe',
        'description': 'Stripe payment account',
        'icon': '💳',
      },
      {
        'type': 'cashapp',
        'name': 'Cash App',
        'description': 'Cash App account',
        'icon': '💰',
      },
    ];
  }
}
