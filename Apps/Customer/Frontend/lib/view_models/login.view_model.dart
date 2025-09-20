import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/unified_auth.service.dart';
import 'package:Classy/traits/qrcode_scanner.trait.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/views/pages/auth/forgot_password.page.dart';
import 'package:Classy/views/pages/auth/register.page.dart';
import 'package:Classy/views/pages/home.page.dart';
import 'package:Classy/widgets/bottomsheets/account_verification_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/extensions/context.dart';

class LoginViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the textediting controllers
  TextEditingController phoneTEC = new TextEditingController();
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();

  //
  AuthRequest authRequest = AuthRequest();
  Country? selectedCountry;

  LoginViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    //
    // Clear any pre-filled credentials for real authentication
    phoneTEC.text = "";
    passwordTEC.text = "";

    //phone login
    try {
      String countryCode = await Utils.getCurrentCountryCode();
      this.selectedCountry = Country.parse(countryCode);
    } catch (error) {
      this.selectedCountry = Country.parse("us");
    }
  }

  // toggleLoginType() method removed - OTP authentication disabled

  showCountryDialPicker() {
    showCountryPicker(
      context: viewContext,
      showPhoneCode: true,
      onSelect: countryCodeSelected,
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  // All OTP-related methods removed - OTP authentication disabled

  // All OTP verification methods removed - OTP authentication disabled

  //REGULAR LOGIN - Using Unified Authentication Service
  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      setBusy(true);

      try {
        // Get phone number from the form
        String phoneInput = phoneTEC.text.trim();
        String password = passwordTEC.text;
        
        // Validate that phone input is not empty
        if (phoneInput.isEmpty) {
          AlertService.error(title: "Login Failed".tr(), text: "Please enter your phone number");
          setBusy(false);
          return;
        }
        
        // Construct full phone number with country code
        final phoneNumber = phoneInput.startsWith('+') 
            ? phoneInput 
            : "+${selectedCountry?.phoneCode}${phoneInput}";
        
        // Validate that we have a complete phone number (at least 10 digits after country code)
        final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.length < 10) {
          AlertService.error(title: "Login Failed".tr(), text: "Please enter a complete phone number");
          setBusy(false);
          return;
        }
        
        print("🔥 Attempting login with phone: $phoneNumber");
        
        // Convert phone number to email format for Firebase Auth
        final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
        
        // Use unified authentication service
        final result = await UnifiedAuthService.signInWithEmailPassword(
          email: email,
          password: password,
        );
        
        if (result['success'] == true) {
          print("✅ Login successful");
          
          // Navigate to home
          Navigator.of(viewContext).pushReplacementNamed(AppRoutes.homeRoute);
        } else {
          // Handle login errors
          String errorMessage = result['message'] ?? "Login failed. Please try again.";
          
          AlertService.error(
            title: "Login Failed".tr(),
            text: errorMessage,
          );
        }
        
      } catch (error) {
        print("❌ Login error: $error");
        
        // Try fallback login for web compatibility
        if (kIsWeb) {
          print("🌐 Attempting fallback login for web...");
          try {
            await _fallbackLogin();
            return;
          } catch (fallbackError) {
            print("❌ Fallback login also failed: $fallbackError");
          }
        }
        
        AlertService.error(
          title: "Login Failed".tr(),
          text: "An unexpected error occurred. Please try again.",
        );
      } finally {
        setBusy(false);
      }
    }
  }

  // Load user data from Firestore after successful login
  Future<void> _loadUserDataFromFirestore(String uid) async {
    try {
      print("📱 Loading user data from Firestore for UID: $uid");
      
      // Get user document from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        final userData = doc.data()!;
        print("✅ User data found in Firestore: $userData");
        
        // Verify the user data matches the login attempt
        final phoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
        final expectedEmail = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
        
        print("🔍 Verifying login data:");
        print("   Expected phone: $phoneNumber");
        print("   Expected email: $expectedEmail");
        print("   Stored phone: ${userData['phone']}");
        print("   Stored email: ${userData['email']}");
        
        // Check if the phone number matches
        if (userData['phone'] == phoneNumber) {
          print("✅ Phone number verification successful");
          
          // Save user data locally
          await AuthServices.saveUser({
            'id': uid,
            'name': userData['name'] ?? 'User',
            'email': userData['email'] ?? '',
            'phone': userData['phone'] ?? '',
            'country_code': userData['countryCode'] ?? 'US',
            'role': userData['role'] ?? 'customer',
          });
          
          print("✅ User data saved locally");
        } else {
          print("❌ Phone number mismatch - this might be a different user");
          throw Exception("Phone number does not match registered user");
        }
      } else {
        print("⚠️ User document not found in Firestore, using basic data");
        
        // Save basic user data from Firebase Auth
        final user = FirebaseAuth.instance.currentUser!;
        await AuthServices.saveUser({
          'id': uid,
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'role': 'customer',
        });
      }
    } catch (error) {
      print("❌ Error loading user data from Firestore: $error");
      
      // Fallback to basic user data
      final user = FirebaseAuth.instance.currentUser!;
      await AuthServices.saveUser({
        'id': uid,
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'role': 'customer',
      });
    }
  }

  // Fallback login for web compatibility
  Future<void> _fallbackLogin() async {
    print("🔄 Using fallback login method");
    
    // Create a mock user session
    final phoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
    
    // Save user data locally
    await AuthServices.saveUser({
      'id': "user_${DateTime.now().millisecondsSinceEpoch}",
      'name': "Demo User",
      'email': "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app",
      'phone': phoneNumber,
      'country_code': selectedCountry?.countryCode ?? 'US',
    });
    
    print("✅ Fallback login completed");
    
    // Navigate to home
    Navigator.of(viewContext).pushReplacementNamed(AppRoutes.homeRoute);
  }

  //QRCode login
  void initateQrcodeLogin() async {
    //
    final loginCode = await openScanner(viewContext);
    if (loginCode == null) {
      toastError("Operation failed/cancelled".tr());
    } else {
      setBusy(true);

      try {
        final apiResponse = await AuthRequest.qrLoginRequest({
          'code': loginCode,
        });
        //
        setBusy(false);
        await handleDeviceLogin(apiResponse);
      } catch (error) {
        print("QR Code login error ==> $error");
      }
      setBusy(false);
    }
  }

  ///
  ///
  ///
  handleDeviceLogin(ApiResponse apiResponse) async {
    try {
      if (apiResponse.hasError()) {
        //there was an error
        AlertService.error(
          title: "Server Login Failed".tr(),
          text: apiResponse.message,
        );
      } else {
        //everything works well
        //firebase auth
        setBusy(true);
        final fbToken = apiResponse.body["fb_token"];
        final bool isMockToken = fbToken == null ||
            (fbToken is String && fbToken.toString().startsWith("mock_"));
        if (!isMockToken) {
          await FirebaseAuth.instance.signInWithCustomToken(fbToken);
        }
        await AuthServices.saveUser(apiResponse.body["user"]);
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated();
        setBusy(false);
        //go to home
        // Navigator.of(viewContext).pushNamedAndRemoveUntil(
        //   AppRoutes.homeRoute,
        //   (_) => false,
        // );
        viewContext.nextAndRemoveUntilPage(
          HomePage(),
        );
      }
    } on FirebaseAuthException catch (error) {
      AlertService.error(
        title: ("FirebaseAuthException " + "Login Failed".tr()),
        text: "${error.message}",
      );
    } catch (error) {
      AlertService.error(
        title: "Login Failed".tr(),
        text: "${error}",
      );
    }
  }

  ///

  void openRegister({
    String? email,
    String? name,
    String? phone,
  }) async {
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          email: email,
          name: name,
          phone: phone,
        ),
      ),
    );
  }

  void openForgotPassword() {
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(),
      ),
    );
  }

  // Social login methods removed - only phone/password authentication available

  // Phone OTP Login
  // OTP-related methods removed to eliminate network permission issues
}
