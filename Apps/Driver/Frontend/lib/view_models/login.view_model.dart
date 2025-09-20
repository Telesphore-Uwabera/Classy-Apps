import 'package:fuodz/services/alert.service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fuodz/services/fallback_auth.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/traits/qrcode_scanner.trait.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/auth/register.page.dart';
import 'package:fuodz/views/pages/permission/permission.page.dart';
import 'package:fuodz/widgets/bottomsheets/account_verification_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class LoginViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the textediting controllers
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  TextEditingController phoneTEC = new TextEditingController();
  late Country selectedCountry;
  String? accountPhoneNumber;
  bool otpLogin = false;

  //
  AuthRequest authRequest = AuthRequest();

  LoginViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedCountry = Country.parse("US");
  }

  void initialise() async {
    //
    emailTEC.text = "";
    passwordTEC.text = "";

    //
    //phone login
    try {
      String? countryCode = await Utils.getCurrentCountryCode();
      this.selectedCountry = Country.parse(countryCode);
    } catch (error) {
      this.selectedCountry = Country.parse("us");
    }
    notifyListeners();
  }

  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      setBusy(true);

      try {
        // Check if Firebase is initialized
        bool firebaseAvailable = false;
        try {
          Firebase.app();
          firebaseAvailable = true;
        } catch (e) {
          print('Firebase not available, using fallback login');
        }
        
        final phoneNumber = "+${selectedCountry.phoneCode}${phoneTEC.text}";
        
        if (firebaseAvailable) {
          try {
            // Use Firebase authentication
            final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
            
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: passwordTEC.text,
            );
            
            // If successful, navigate to home
            Navigator.of(viewContext).pushReplacementNamed(AppRoutes.homeRoute);
            return;
          } catch (firebaseError) {
            print('Firebase login failed: $firebaseError');
            // Continue with fallback login
          }
        }
        
        // Fallback: Use local authentication when Firebase is not available
        if (!firebaseAvailable) {
          print('Using fallback login - Firebase not available');
          
          final user = await FallbackAuthService.loginUser(phoneNumber, passwordTEC.text);
          
          if (user != null) {
            // If successful, navigate to home
            Navigator.of(viewContext).pushReplacementNamed(AppRoutes.homeRoute);
            return;
          } else {
            throw Exception('Invalid credentials');
          }
        }
        
      } catch (error) {
        print("Firebase login error: $error");
        
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

  toggleLoginType() {
    otpLogin = !otpLogin;
    notifyListeners();
  }

  //START OTP RELATED METHODS
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
    accountPhoneNumber = "+${selectedCountry.phoneCode}${phoneTEC.text}";
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      setBusyForObject(otpLogin, true);
      //phone number verification
      final apiResponse = await authRequest.verifyPhoneAccount(
        accountPhoneNumber!,
      );

      if (!apiResponse.allGood) {
        AlertService.error(
          title: "Login".tr(),
          text: apiResponse.message,
        );
        setBusyForObject(otpLogin, false);
        return;
      }

      setBusyForObject(otpLogin, false);
      //
      if (AppStrings.isFirebaseOtp) {
        processFirebaseOTPVerification();
      } else {
        processCustomOTPVerification();
      }
    }
  }

  //PROCESSING VERIFICATION
  processFirebaseOTPVerification() async {
    setBusyForObject(otpLogin, true);
    //firebase authentication
    // Check if Firebase is initialized
    try {
      Firebase.app();
    } catch (e) {
      throw Exception('Firebase is not initialized. Please restart the app.');
    }
    
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: accountPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // firebaseVerificationId = credential.verificationId;
        // verifyFirebaseOTP(credential.smsCode);
        print("verificationCompleted ==>  Yes");
        // finishOTPLogin(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
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
      await authRequest.sendOTP(accountPhoneNumber!);
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
        onResendCode: AppStrings.isCustomOtp
            ? () async {
                try {
                  final response =
                      await authRequest.sendOTP(accountPhoneNumber!);
                  toastSuccessful(response.message ?? "Success".tr());
                } catch (error) {
                  viewContext.showToast(msg: "$error", bgColor: Colors.red);
                }
              }
            : null,
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
    // Sign the user in (or link) with the credential
    try {
      final apiResponse = await authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
        isLogin: true,
      );

      //
      await handleDeviceLogin(apiResponse);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusy(false);
  }

  //Login to with firebase token
  finishOTPLogin(AuthCredential authCredential) async {
    //
    setBusyForObject(otpLogin, true);
    // Sign the user in (or link) with the credential
    try {
      //
      // Check if Firebase is initialized
      try {
        Firebase.app();
      } catch (e) {
        throw Exception('Firebase is not initialized. Please restart the app.');
      }
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        authCredential,
      );
      //
      String? firebaseToken = await userCredential.user!.getIdToken();
      final apiResponse = await authRequest.verifyFirebaseToken(
        accountPhoneNumber!,
        firebaseToken!,
      );
      //
      await handleDeviceLogin(apiResponse);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(otpLogin, false);
  }

//END OTP RELATED METHODS

  //QRCode login
  void initateQrcodeLogin() async {
    //
    final loginCode = await openScanner(viewContext);
    if (loginCode == null) {
      toastError("Operation failed/cancelled".tr());
    } else {
      setBusy(true);

      try {
        final apiResponse = await authRequest.qrLoginRequest(
          code: loginCode,
        );
        //
        handleDeviceLogin(apiResponse);
      } catch (error) {
        print("QR Code login error ==> $error");
      }

      setBusy(false);
    }
  }

  handleDeviceLogin(ApiResponse apiResponse) async {
    try {
      if (apiResponse.hasError()) {
        //there was an error
        AlertService.error(
          title: "Login Failed".tr(),
          text: apiResponse.message,
        );
      } else {
        //check it the user is a driver
        final user = User.fromJson(apiResponse.body["user"]);
        if (user.role != "driver") {
          AlertService.error(
            title: "Login Failed".tr(),
            text: "Unauthorized user access".tr(),
          );
          return;
        }
        //everything works well
        //firebase auth
        final fbToken = apiResponse.body["fb_token"];
        // Check if Firebase is initialized
        try {
          Firebase.app();
        } catch (e) {
          throw Exception('Firebase is not initialized. Please restart the app.');
        }
        
        await FirebaseAuth.instance.signInWithCustomToken(fbToken);
        final driver = await AuthServices.saveUser(apiResponse.body["user"]);
        if (driver.isTaxiDriver && apiResponse.body["vehicle"] != null) {
          await AuthServices.saveVehicle(apiResponse.body["vehicle"]);
          await AuthServices.syncDriverData(apiResponse.body);
        }
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated();

        // Navigator.of(viewContext).pushNamedAndRemoveUntil(
        //   AppRoutes.homeRoute,
        //   (route) => false,
        // );
        viewContext.nextAndRemoveUntilPage(PermissionPage());
      }
    } on FirebaseAuthException catch (error) {
      AlertService.error(
        title: "Login Failed".tr(),
        text: "${error.message}",
      );
    } catch (error) {
      AlertService.error(
        title: "Login Failed".tr(),
        text: "${error}",
      );
    }
  }

  void openForgotPassword() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.forgotPasswordRoute,
    );
  }

  void openRegistrationlink() async {
    viewContext.nextPage(RegisterPage());
    //final url = Api.register;
    // openExternalWebpageLink(url);
  }
}
