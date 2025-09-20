import 'services/alert.service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'constants/app_strings.dart';
import 'requests/auth.request.dart';
import 'widgets/bottomsheets/account_verification_entry.dart';
import 'widgets/bottomsheets/new_password_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sim_card_code/sim_card_code.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'extensions/context.dart';

class ForgotPasswordViewModel extends MyBaseViewModel {
  //the textediting controllers
  TextEditingController phoneTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  AuthRequest _authRequest = AuthRequest();
  late Country selectedCountry;
  String? accountPhoneNumber;


  ForgotPasswordViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedCountry = Country.parse("us");
  }

  void initialise() async {
    // Set default country to Rwanda (+250) for web compatibility
    this.selectedCountry = Country.parse("RW");
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
    accountPhoneNumber = "+${selectedCountry.phoneCode}${phoneTEC.text}";
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);
      final apiResponse = await _authRequest.verifyPhoneAccount(
        accountPhoneNumber!,
      );
      setBusy(false);
      if (apiResponse.allGood) {
        //
        final phoneNumber = apiResponse.body["phone"]?.toString() ?? "";
        if (phoneNumber.isNotEmpty) {
          accountPhoneNumber = phoneNumber;
          // For now, show message that password reset is not available
          AlertService.success(
            title: "Password Reset".tr(),
            text: "Password reset functionality is currently not available. Please contact support.",
          );
        } else {
          AlertService.error(
            title: "Forgot Password".tr(),
            text: "Invalid phone number format".tr(),
          );
        }
      } else {
        AlertService.error(
          title: "Forgot Password".tr(),
          text: apiResponse.message,
        );
      }
    }
  }



  //
  processCustomForgotPassword(String phoneNumber) async {
    setBusy(true);
    try {
      final apiResponse = await _authRequest.sendOTP(phoneNumber);
      String? instructions = (apiResponse.body as Map)["instructions"] ?? null;
      setBusy(false);
      showVerificationEntry(instructions);
    } catch (error) {
      setBusy(false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //show a bottomsheet to the user for verification code entry
  void showVerificationEntry([String? instructions]) {
    //
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder:
            (context) => AccountVerificationEntry(
              vm: this,
              onSubmit: (smsCode) {
                viewContext.pop();
                // For now, only custom OTP is supported
                verifyCustomOTP(smsCode);
              },
            ),
      ),
    );
    // showModalBottomSheet(
    //   context: viewContext,
    //   isScrollControlled: true,
    //   builder: (context) {
    //     return AccountVerificationEntry(
    //       vm: this,
    //       instruction: instructions,
    //       onSubmit: (smsCode) {
    //         //
    //         print("sms code ==> $smsCode");
    //         if (!AppStrings.isCustomOtp) {
    //           verifyFirebaseOTP(smsCode);
    //         } else {
    //           verifyCustomOTP(smsCode);
    //         }
    //         viewContext.pop();
    //       },
    //     );
    //   },
    // );
  }



  //verify the provided code with the custom sms gateway server
  void verifyCustomOTP(String smsCode) async {
    //
    setBusy(true);

    // Sign the user in (or link) with the credential
    try {
      final apiResponse = await _authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
      );
      // Store token for password reset
      showNewPasswordEntry();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusy(false);
  }

  //show a bottomsheet to the user for verification code entry
  showNewPasswordEntry() {
    //
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder:
            (context) => NewPasswordEntry(
              vm: this,
              onSubmit: (password) {
                //
                finishChangeAccountPassword();
                viewContext.pop();
              },
            ),
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
    final apiResponse = await _authRequest.resetPasswordRequest(
      phone: accountPhoneNumber!,
      password: passwordTEC.text,
      firebaseToken: null,
      customToken: null,
    );
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
}
