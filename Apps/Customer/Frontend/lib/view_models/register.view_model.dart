import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase_error.service.dart';
import 'package:Classy/services/firebase.service.dart';
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
  // DIRECT REGISTRATION PATH - Using Firebase Authentication
  Future<void> finishAccountRegistration() async {
    setBusy(true);

    try {
      // Use AuthRequest for proper registration handling
      final phoneNumber = accountPhoneNumber!;
      
      print("🔥 Starting Firebase registration for: $phoneNumber");
      
      final apiResponse = await AuthRequest.registerRequest({
        'name': nameTEC.text,
        'phone': phoneNumber,
        'password': passwordTEC.text,
        'email': emailTEC.text,
        'country_code': selectedCountry!.countryCode,
        'referral_code': referralCodeTEC.text,
      });
      
      if (apiResponse.code == 200) {
        print("✅ Registration successful, saving user data...");
        
        // Save user data and set authentication state
        final user = await AuthServices.saveUser(apiResponse.body['user']);
        await AuthServices.isAuthenticated();
        
        print("✅ User data saved, navigating to home...");
        
        // Registration completed successfully
        setBusy(false);
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (_) => false,
        );
        
        print("✅ Registration and navigation completed");
      } else {
        setBusy(false);
        viewContext.showToast(
          msg: apiResponse.message ?? "Registration failed", 
          bgColor: Colors.red
        );
      }
      
    } on FirebaseAuthException catch (e) {
      setBusy(false);
      print("Firebase Auth error: ${e.code} - ${e.message}");
      
      String errorMessage = FirebaseErrorService.handleAuthException(e);
      
      viewContext.showToast(
        msg: errorMessage,
        bgColor: Colors.red,
      );
    } catch (error) {
      setBusy(false);
      print("General registration error: $error");
      
      // Handle errors with user-friendly messages
      String errorMessage = FirebaseErrorService.getUserFriendlyMessage(error);
      
      viewContext.showToast(
        msg: errorMessage,
        bgColor: Colors.red,
      );
    }
  }


  void openLogin() async {
    viewContext.pop();
  }

  verifyRegistrationOTP(String text) {}
}
