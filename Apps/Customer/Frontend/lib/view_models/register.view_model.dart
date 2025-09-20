import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:Classy/services/auth_validation.service.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase.service.dart';
import 'package:Classy/services/toast.service.dart';
import 'package:Classy/services/unified_auth.service.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/widgets/bottomsheets/account_verification_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/extensions/context.dart';

class RegisterViewModel extends MyBaseViewModel {
  //
  AuthRequest _authRequest = AuthRequest();
  // FirebaseAuth auth = FirebaseAuth.instance;
  //the textediting controllers
  TextEditingController nameTEC =
      new TextEditingController(text: !kReleaseMode ? "John Doe" : "");
  TextEditingController emailTEC =
      new TextEditingController(text: !kReleaseMode ? "john@mail.com" : "");
  TextEditingController phoneTEC =
      new TextEditingController(text: !kReleaseMode ? "557484181" : "");
  TextEditingController passwordTEC =
      new TextEditingController(text: !kReleaseMode ? "password" : "");
  TextEditingController referralCodeTEC = new TextEditingController();
  Country? selectedCountry;
  String? accountPhoneNumber;
  bool agreed = false;
  bool otpLogin = AppStrings.enableOTPLogin;

  RegisterViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedCountry = Country.parse("us");
  }

  void initialise() async {
    try {
      String countryCode = await Utils.getCurrentCountryCode();
      this.selectedCountry = Country.parse(countryCode);
    } catch (error) {
      this.selectedCountry = Country.parse("us");
    }
  }

  //
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

  void processRegister() async {
    //
    accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
    
    // Validate phone number is complete
    if (phoneTEC.text.trim().isEmpty) {
      ToastService.toastError("Please enter your phone number");
      return;
    }
    
    final digitsOnly = accountPhoneNumber!.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      ToastService.toastError("Please enter a complete phone number");
      return;
    }
    
    //
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate() && agreed) {
      //
      // COMMENTED OUT FIREBASE OTP - GOING DIRECT TO REGISTRATION
      // if (AppStrings.isFirebaseOtp) {
      //   processFirebaseOTPVerification();
      // } else if (AppStrings.isCustomOtp) {
      //   processCustomOTPVerification();
      // } else {
      //   finishAccountRegistration();
      // }
      
      // GO DIRECTLY TO REGISTRATION - NO OTP REQUIRED
      finishAccountRegistration();
    }
  }

  //PROCESSING VERIFICATION - COMMENTED OUT FIREBASE OTP
  // processFirebaseOTPVerification() async {
  //   setBusy(true);
  //   //firebase authentication
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     phoneNumber: accountPhoneNumber,
  //     verificationCompleted: (PhoneAuthCredential credential) {
  //       // firebaseVerificationId = credential.verificationId;
  //       // verifyFirebaseOTP(credential.smsCode);
  //       finishAccountRegistration();
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       setBusy(false);
  //       String msg = "Failed".tr();
  //       if (e.code == 'invalid-phone-number') {
  //         msg = "Invalid Phone Number".tr();
  //       } else {
  //         msg = e.message ?? "Failed".tr();
  //       }
  //       //
  //       AlertService.error(
  //         title: "Error".tr(),
  //         text: msg,
  //       );
  //     },
  //     codeSent: (String verificationId, int? resendToken) async {
  //       setBusy(false);
  //       firebaseVerificationId = verificationId;
  //       showVerificationEntry();
  //     },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //       setBusy(false);
  //       print("codeAutoRetrievalTimeout called");
  //     },
  //   );
  // }

  // processCustomOTPVerification() async {
  //   setBusy(true);
  //   try {
  //     await _authRequest.sendOTP(accountPhoneNumber!);
  //     setBusy(false);
  //     showVerificationEntry();
  //   } catch (error) {
  //     setBusy(false);
  //     viewContext.showToast(msg: "$error", bgColor: Colors.red);
  //   }
  // }

  //
  // void showVerificationEntry() async {
  //   //
  //   setBusy(false);
  //   //
  //   await viewContext.push(
  //     (context) => AccountVerificationEntry(
  //       vm: this,
  //       phone: accountPhoneNumber!,
  //       onSubmit: (smsCode) {
  //         //
  //         if (AppStrings.isFirebaseOtp) {
  //           verifyFirebaseOTP(smsCode);
  //         } else if (AppStrings.isCustomOtp) {
  //           verifyCustomOTP(smsCode);
  //         }

  //         viewContext.pop();
  //       },
  //       onResendCode: AppStrings.isCustomOtp
  //           ? () async {
  //               try {
  //                 final response = await _authRequest.sendOTP(
  //                   accountPhoneNumber!,
  //                 );
  //                 toastSuccessful("${response.message}");
  //                 } catch (error) {
  //                   viewContext.showToast(msg: "$error", bgColor: Colors.red);
  //                 }
  //               }
  //             : () {},
  //     ),
  //   );
  // }

  //
  // void verifyFirebaseOTP(String smsCode) async {
  //   //
  //   setBusyForObject(firebaseVerificationId, true);

  //   // Sign the user in (or link) with the credential
  //   try {
  //     // Create a PhoneAuthCredential with the code
  //     PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
  //       verificationId: firebaseVerificationId!,
  //       smsCode: smsCode,
  //   );

  //     await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
  //     await finishAccountRegistration();
  //     } catch (error) {
  //       viewContext.showToast(msg: "$error", bgColor: Colors.red);
  //     }
  //   //
  //   setBusyForObject(firebaseVerificationId, false);
  // }

  // void verifyCustomOTP(String smsCode) async {
  //   //
  //   setBusyForObject(firebaseVerificationId, true);
  //   // Sign the user in (or link) with the credential
  //   try {
  //     await _authRequest.verifyOTP(accountPhoneNumber!, smsCode);
  //     await finishAccountRegistration();
  //     await finishAccountRegistration();
  //   } catch (error) {
  //     viewContext.showToast(msg: "$error", bgColor: Colors.red);
  //     }
  //   //
  //   setBusyForObject(firebaseVerificationId, false);
  // }

///////
  ///
  // DIRECT REGISTRATION PATH - Using Unified Authentication Service
  Future<void> finishAccountRegistration() async {
    setBusy(true);

    try {
      // Use unified authentication service for registration
      final phoneNumber = accountPhoneNumber!;
      // Always generate email from phone number for consistency
      final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
      
      print("🔥 Starting registration for: $email");
      print("📱 Phone number: $phoneNumber");
      print("👤 Name: ${nameTEC.text}");
      print("📧 User email (optional): ${emailTEC.text}");
      
      // Use unified authentication service
      final result = await UnifiedAuthService.signUpWithEmailPassword(
        email: email,
        password: passwordTEC.text,
        name: nameTEC.text,
        phone: phoneNumber,
        countryCode: selectedCountry!.countryCode,
      );
      
      if (result['success'] == true) {
        print("✅ Registration successful");
        
        // Navigate to home
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (_) => false,
        );
      } else {
        // Handle registration errors
        String errorMessage = result['message'] ?? "Registration failed. Please try again.";
        
        ToastService.toastError(errorMessage);
      }
      
    } catch (error) {
      setBusy(false);
      print("❌ Registration error: $error");
      
      // Try fallback registration for web compatibility
      if (kIsWeb) {
        print("🌐 Attempting fallback registration for web...");
        try {
          await _fallbackRegistration();
          return;
        } catch (fallbackError) {
          print("❌ Fallback registration also failed: $fallbackError");
        }
      }
      
      ToastService.toastError("Registration failed. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  // Fallback registration for web compatibility
  Future<void> _fallbackRegistration() async {
    print("🔄 Using fallback registration method");
    
    // Create a mock user ID
    final userId = "user_${DateTime.now().millisecondsSinceEpoch}";
    
    // Save user data locally without Firebase
    await AuthServices.saveUser({
      'id': userId,
      'name': nameTEC.text,
      'email': emailTEC.text,
      'phone': accountPhoneNumber!,
      'country_code': selectedCountry!.countryCode,
    });
    
    print("✅ Fallback registration completed");
    
    // Navigate to home
    Navigator.of(viewContext).pushNamedAndRemoveUntil(
      AppRoutes.homeRoute,
      (_) => false,
    );
  }

  void openLogin() async {
    viewContext.pop();
  }

  verifyRegistrationOTP(String text) {}
}
