import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/services/alert.service.dart';
import 'package:Classy/utils/utils.dart';
import 'package:Classy/widgets/bottomsheets/account_verification_entry.dart';
import 'package:Classy/widgets/bottomsheets/new_password_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:Classy/extensions/context.dart';

class ForgotPasswordViewModel extends MyBaseViewModel {
  //the textediting controllers
  TextEditingController phoneTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  AuthRequest _authRequest = AuthRequest();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool otpLogin = AppStrings.enableOTPLogin;
  Country? selectedCountry;
  String? accountPhoneNumber;
  //
  String? firebaseToken;
  String? firebaseVerificationId;

  ForgotPasswordViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedCountry = Country.parse("US");
  }

  void initialise() async {
    try {
      this.selectedCountry = Country.parse(await Utils.getCurrentCountryCode());
    } catch (error) {
      print(error);
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

  //
  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  //verify on the server to see if there is an account associated with the supplied phone number
  processForgotPassword() async {
    accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);
      final apiResponse =
          await AuthRequest.verifyPhoneAccount(accountPhoneNumber!);
      if (apiResponse.allGood) {
        //
        final phoneNumber = apiResponse.body["phone"];
        accountPhoneNumber = phoneNumber;
        if (!AppStrings.isCustomOtp) {
          processFirebaseForgotPassword(phoneNumber);
        } else {
          processCustomForgotPassword(phoneNumber);
        }
      } else {
        AlertService.error(
          title: "Forgot Password".tr(),
          text: apiResponse.message,
        );
      }
      setBusy(false);
    }
  }

  //initiate the otp sending to provided phone
  processFirebaseForgotPassword(String phoneNumber) async {
    setBusy(true);
    
    // For web compatibility, use backend API instead of Firebase
    if (kIsWeb) {
      await processBackendForgotPassword(phoneNumber);
      return;
    }

    //
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        //
        UserCredential userCredential = await auth.signInWithCredential(
          credential,
        );

        //fetch user id token
        firebaseToken = await userCredential.user?.getIdToken();
        firebaseVerificationId = credential.verificationId;

        //
        setBusy(false);
        showNewPasswordEntry();
      },
      verificationFailed: (FirebaseAuthException e) {
        setBusy(false);
        String msg = "Error".tr();
        if (e.code == 'invalid-phone-number') {
          msg = "Invalid Phone Number".tr();
        } else if (e.code == 'too-many-requests') {
          msg = "Too many requests. Please try again later.".tr();
        } else if (e.code == 'network-request-failed') {
          msg = "Network error. Please check your connection.".tr();
        } else {
          msg = e.message ?? "Error".tr();
        }
        
        // Handle web-specific errors
        if (msg.contains('FirebaseException') || msg.contains('JavaScriptObject')) {
          msg = "Authentication service is temporarily unavailable. Please try again later.".tr();
        }
        
        AlertService.error(
          title: "Forgot Password".tr(),
          text: msg,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        firebaseVerificationId = verificationId;
        setBusy(false);
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setBusy(false);
        //
        // firebaseVerificationId = verificationId;
        // showVerificationEntry();
        // setBusy(false);
      },
    );
  }

  //
  processCustomForgotPassword(String phoneNumber) async {
    setBusy(true);
    try {
      await AuthRequest.sendOTP(phoneNumber);
      setBusy(false);
      showVerificationEntry();
    } catch (error) {
      setBusy(false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //show a bottomsheet to the user for verification code entry
  void showVerificationEntry() async {
    //
    await viewContext.push(
      (context) {
        return AccountVerificationEntry(
          vm: this,
          phone: accountPhoneNumber!,
          onSubmit: (smsCode) {
            //
            if (!AppStrings.isCustomOtp) {
              verifyFirebaseOTP(smsCode);
            } else {
              verifyCustomOTP(smsCode);
            }
            viewContext.pop();
          },
          onResendCode: AppStrings.isCustomOtp
              ? () async {
                  try {
                    final response = await AuthRequest.sendOTP(
                      accountPhoneNumber!,
                    );
                    toastSuccessful(response.message ?? "Success".tr());
                  } catch (error) {
                    viewContext.showToast(msg: "$error", bgColor: Colors.red);
                  }
                }
              : () {},
        );
      },
    );
    //
  }

  //verify the provided code with the firebase server
  void verifyFirebaseOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );

      UserCredential userCredential = await auth.signInWithCredential(
        phoneAuthCredential,
      );
      //
      firebaseToken = await userCredential.user?.getIdToken();
      showNewPasswordEntry();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

  //verify the provided code with the custom sms gateway server
  void verifyCustomOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);

    // Sign the user in (or link) with the credential
    try {
      final apiResponse = await AuthRequest.verifyOTP({
        'phone': accountPhoneNumber!,
        'otp': smsCode,
      });
      firebaseToken = apiResponse.body["token"];
      showNewPasswordEntry();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

  //show a bottomsheet to the user for verification code entry
  showNewPasswordEntry() {
    //
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) {
          return NewPasswordEntry(
            vm: this,
            onSubmit: (password) {
              viewContext.pop();
              finishChangeAccountPassword();
            },
          );
        },
      ),
    );
    // showModalBottomSheet(
    //   context: viewContext,
    //   isScrollControlled: true,
    //   builder: (context) {
    //     return NewPasswordEntry(
    //       vm: this,
    //       onSubmit: (password) {
    //         //
    //         finishChangeAccountPassword();
    //         viewContext.pop();
    //       },
    //     );
    //   },
    // );
  }

  //
  finishChangeAccountPassword() async {
    //

    setBusy(true);
    final apiResponse = await AuthRequest.resetPasswordRequest({
      'phone': accountPhoneNumber!,
      'password': passwordTEC.text,
      'firebaseToken': !AppStrings.isCustomOtp ? firebaseToken : null,
      'customToken': AppStrings.isCustomOtp ? firebaseToken : null,
    });
    setBusy(false);

    AlertService.dynamic(
      type: apiResponse.allGood ? AlertType.success : AlertType.error,
      title: "Forgot Password".tr(),
      text: apiResponse.message,
      onConfirm: () {
        Navigator.of(viewContext).popUntil((route) => route.isFirst);
      },
    );
  }

  // Simplified method for the new UI
  void sendResetCode() async {
    processForgotPassword();
  }

  // Backend forgot password method for web compatibility
  processBackendForgotPassword(String phoneNumber) async {
    try {
      final apiResponse = await AuthRequest.forgotPasswordRequest(phoneNumber);
      
      if (apiResponse.allGood) {
        AlertService.success(
          title: "Forgot Password".tr(),
          text: "Password reset instructions have been sent to your phone number.",
        );
      } else {
        AlertService.error(
          title: "Forgot Password".tr(),
          text: apiResponse.message,
        );
      }
    } catch (error) {
      AlertService.error(
        title: "Forgot Password".tr(),
        text: "Unable to process password reset. Please try again later.",
      );
    }
    
    setBusy(false);
  }
}
