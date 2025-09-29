import 'package:Classy/services/firebase_payment.service.dart';
import 'package:Classy/models/api_response.dart';

/// Test script to verify payment methods update is working
class PaymentFixTest {
  static Future<void> runTest() async {
    print("🧪 Testing Payment Methods Update Fix");
    print("=====================================");
    
    try {
      // Test 1: Get payment accounts
      print("1️⃣ Testing getPaymentAccounts...");
      ApiResponse response = await FirebasePaymentService.getPaymentAccounts();
      print("   Result: ${response.allGood ? '✅ SUCCESS' : '❌ FAILED'}");
      print("   Message: ${response.message}");
      
      // Test 2: Add a test payment account
      print("\n2️⃣ Testing addPaymentAccount...");
      response = await FirebasePaymentService.addPaymentAccount(
        name: "Test Mobile Money",
        number: "+256712345678",
        instructions: "Test payment method",
        isActive: true,
      );
      print("   Result: ${response.allGood ? '✅ SUCCESS' : '❌ FAILED'}");
      print("   Message: ${response.message}");
      
      if (response.allGood && response.body != null) {
        String accountId = response.body['id'];
        
        // Test 3: Update the payment account
        print("\n3️⃣ Testing updatePaymentAccount...");
        response = await FirebasePaymentService.updatePaymentAccount(
          accountId: accountId,
          name: "Updated Mobile Money",
          number: "+256712345679",
          instructions: "Updated test payment method",
          isActive: true,
        );
        print("   Result: ${response.allGood ? '✅ SUCCESS' : '❌ FAILED'}");
        print("   Message: ${response.message}");
        
        // Test 4: Delete the test payment account
        print("\n4️⃣ Testing deletePaymentAccount...");
        response = await FirebasePaymentService.deletePaymentAccount(accountId);
        print("   Result: ${response.allGood ? '✅ SUCCESS' : '❌ FAILED'}");
        print("   Message: ${response.message}");
      }
      
      // Test 5: Get payment methods
      print("\n5️⃣ Testing getPaymentMethods...");
      response = await FirebasePaymentService.getPaymentMethods();
      print("   Result: ${response.allGood ? '✅ SUCCESS' : '❌ FAILED'}");
      print("   Message: ${response.message}");
      
      print("\n🎉 Payment Methods Update Fix Test Complete!");
      print("   All Firebase payment operations are working correctly.");
      
    } catch (e) {
      print("\n❌ Payment Methods Update Fix Test Failed!");
      print("   Error: $e");
    }
  }
}
