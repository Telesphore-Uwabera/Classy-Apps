import 'services/alert.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constants/app_routes.dart';
import 'models/api_response.dart';
import 'models/country.dart';
import 'requests/auth.request.dart';
import 'services/auth.service.dart';
import 'traits/qrcode_scanner.trait.dart';
import 'views/pages/auth/register.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the textediting controllers
  TextEditingController phoneTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  
  // Selected country
  Country selectedCountry = Country.defaultCountry;

  //
  AuthRequest _authRequest = AuthRequest();

  LoginViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() {
    // Clear any pre-filled credentials for real authentication
    phoneTEC.text = "";
    passwordTEC.text = "";
    
    // Debug: Check default country
    print("Debug: Default country = ${selectedCountry.name} (${selectedCountry.phoneCode})");
  }
  
  void updateSelectedCountry(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      setBusy(true);

      try {
        // Use Firebase authentication instead of Laravel backend
        final phoneNumber = "${selectedCountry.phoneCode}${phoneTEC.text.trim()}";
        
        // Sign in with Firebase using phone number and password
        // For now, we'll use email/password authentication with a generated email
        final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
        
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: passwordTEC.text.trim(),
        );
        
        // If successful, navigate to home
        Navigator.of(viewContext).pushReplacementNamed(AppRoutes.homeRoute);
        
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



  //QRCode login
  void initateQrcodeLogin() async {
    //
    final loginCode = await openScanner(viewContext);
    if (loginCode == null) {
      toastError("Operation failed/cancelled".tr());
    } else {
      setBusy(true);

      try {
        final apiResponse = await _authRequest.qrLoginRequest(
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

  ///
  ///
  ///
  handleDeviceLogin(ApiResponse apiResponse) async {
    try {
      if (apiResponse.hasError()) {
        //there was an error
        AlertService.error(
          title: "Login Failed".tr(),
          text: apiResponse.message,
        );
      } else {
        //everything works well
        // Save user data and navigate to home
        await AuthServices.saveUser(apiResponse.body["user"]);
        await AuthServices.saveVendor(apiResponse.body["vendor"]);
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated();
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (route) => false,
        );
      }
    } catch (error) {
      AlertService.error(
        title: "Login Failed".tr(),
        text: "$error",
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
    /*
    final url = Api.register;
    openExternalWebpageLink(url);
    */
  }
}
