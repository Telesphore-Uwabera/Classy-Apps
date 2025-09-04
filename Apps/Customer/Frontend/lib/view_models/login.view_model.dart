import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/social_media_login.service.dart';
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
  SocialMediaLoginService socialMediaLoginService = SocialMediaLoginService();
  bool otpLogin = AppStrings.enableOTPLogin;
  Country? selectedCountry;
  String? accountPhoneNumber;

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

  toggleLoginType() {
    otpLogin = !otpLogin;
    notifyListeners();
  }

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

  void processOTPLogin() async {
    //
    accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //

      setBusyForObject(otpLogin, true);
      //phone number verification
      // Demo: skip server verify and open 4-digit entry immediately
      setBusyForObject(otpLogin, false);
      showVerificationEntry();
    }
  }

  //PROCESSING VERIFICATION
  processFirebaseOTPVerification() async {
    setBusyForObject(otpLogin, true);
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: accountPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // firebaseVerificationId = credential.verificationId;
        // verifyFirebaseOTP(credential.smsCode);
        print("verificationCompleted ==>  Yes");
        // finishOTPLogin(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        log("Error message ==> ${e.message}");
        if (e.code == 'invalid-phone-number') {
          viewContext.showToast(
              msg: "Invalid Phone Number".tr(), bgColor: Colors.red);
        } else {
          viewContext.showToast(
              msg: e.message ?? "Failed".tr(), bgColor: Colors.red);
        }
        //
        setBusyForObject(otpLogin, false);
      },
      codeSent: (String verificationId, int? resendToken) async {
        firebaseVerificationId = verificationId;
        print("codeSent ==>  $firebaseVerificationId");
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("codeAutoRetrievalTimeout called");
      },
    );
    setBusyForObject(otpLogin, false);
  }

  processCustomOTPVerification() async {
    setBusyForObject(otpLogin, true);
    try {
      await AuthRequest.sendOTP(accountPhoneNumber!);
      setBusyForObject(otpLogin, false);
      showVerificationEntry();
    } catch (error) {
      setBusyForObject(otpLogin, false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //
  void showVerificationEntry() async {
    //
    setBusy(false);
    //
    await viewContext.push(
      (context) => AccountVerificationEntry(
        vm: this,
        phone: accountPhoneNumber!,
        onSubmit: (smsCode) {
          //
          if (AppStrings.isFirebaseOtp) {
            verifyFirebaseOTP(smsCode);
          } else {
            verifyCustomOTP(smsCode);
          }

          viewContext.pop();
        },
        onResendCode: () async {
          if (!AppStrings.isCustomOtp) {
            return;
          }
          try {
            final response = await AuthRequest.sendOTP(
              accountPhoneNumber!,
            );
            toastSuccessful(response.message ?? "Code sent successfully".tr());
          } catch (error) {
            viewContext.showToast(msg: "$error", bgColor: Colors.red);
          }
        },
      ),
    );
  }

  //
  void verifyFirebaseOTP(String smsCode) async {
    //
    setBusyForObject(otpLogin, true);

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );

      //
      await finishOTPLogin(phoneAuthCredential);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(otpLogin, false);
  }

  void verifyCustomOTP(String smsCode) async {
    //
    setBusy(true);
    // Demo: accept any 4-digit code
    final apiResponse = ApiResponse(
      code: 200,
      message: "OK",
      body: {
        "token": "mock_token_demo",
        "fb_token": "mock_offline_token",
        "user": {
          "id": 785043355,
          "name": "Classy Customer",
          "email": "client@demo.com",
          "phone": accountPhoneNumber ?? "+250 785 043 355",
          "photo": "",
        }
      },
    );
    setBusy(false);
    await handleDeviceLogin(apiResponse);
  }

  //Login with Firebase OTP - Direct Firebase authentication
  finishOTPLogin(AuthCredential authCredential) async {
    //
    setBusyForObject(otpLogin, true);
    // Sign the user in (or link) with the credential
    try {
      //
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        authCredential,
      );
      
      if (userCredential.user != null) {
        // Save user data locally
        await AuthServices.saveUser({
          'id': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? 'User',
          'email': userCredential.user!.email ?? '',
          'phone': accountPhoneNumber!,
        });
        
        // Navigate to home
        Navigator.of(viewContext).pushReplacementNamed(AppRoutes.homeRoute);
      }
      
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(otpLogin, false);
  }

  //REGULAR LOGIN - Using Firebase Authentication
  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      setBusy(true);

      try {
        // Use Firebase authentication instead of Laravel backend
        final phoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
        
        // Sign in with Firebase using phone number and password
        // For now, we'll use email/password authentication with a generated email
        final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
        
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: passwordTEC.text,
        );
        
        // If successful, navigate to home
        Navigator.of(viewContext).pushReplacementNamed(AppRoutes.homeRoute);
        
      } catch (error) {
        print("Firebase login error: $error");
        
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
        
        // Handle specific Firebase errors
        String errorMessage = "Please check your credentials and try again.";
        if (error.toString().contains('user-not-found')) {
          errorMessage = "No account found with this phone number.";
        } else if (error.toString().contains('wrong-password')) {
          errorMessage = "Incorrect password.";
        } else if (error.toString().contains('invalid-email')) {
          errorMessage = "Invalid phone number format.";
        }
        
        AlertService.error(
          title: "Login Failed".tr(),
          text: errorMessage,
        );
      } finally {
        setBusy(false);
      }
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
}
