import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/driver_status.service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
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
        // Use Firebase authentication instead of Laravel backend
        final phoneNumber = "+${selectedCountry.phoneCode}${phoneTEC.text}";
        
        // Sign in with Firebase using phone number and password
        // For now, we'll use email/password authentication with a generated email
        final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
        
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: passwordTEC.text,
        );
        
        // ✅ CRITICAL SECURITY FIX: Validate driver status before allowing access
        final statusValidation = await DriverStatusService.validateDriverStatus();
        
        if (statusValidation['canLogin'] == true) {
          // Driver is approved, allow access
          Navigator.of(viewContext).pushReplacementNamed(AppRoutes.homeRoute);
        } else {
          // Driver not approved, show detailed message and sign out
          await FirebaseAuth.instance.signOut();
          _showDetailedStatusMessage(statusValidation);
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

  void _showDetailedStatusMessage(Map<String, dynamic> statusValidation) {
    final status = statusValidation['status'] ?? 'unknown';
    final reason = statusValidation['reason'] ?? 'Unable to access the app';
    
    String title = 'Access Denied';
    String message = reason;
    IconData icon = Icons.block;
    Color iconColor = Colors.red;
    
    switch (status) {
      case 'pending':
        title = 'Account Pending Approval';
        message = 'Your driver account is currently under review by our admin team. You will receive a notification once your account is approved. This process usually takes 24-48 hours.';
        icon = Icons.hourglass_empty;
        iconColor = Colors.orange;
        break;
      case 'rejected':
        title = 'Account Rejected';
        message = 'Your driver application has been rejected. Please contact our support team for more information.';
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case 'suspended':
        title = 'Account Suspended';
        message = 'Your driver account has been suspended. Please contact our support team for assistance.';
        icon = Icons.pause_circle;
        iconColor = Colors.red;
        break;
    }
    
    showDialog(
      context: viewContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (status == 'pending') ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What happens next?',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700]),
                    ),
                    SizedBox(height: 8),
                    Text('• Admin will review your application', style: TextStyle(color: Colors.blue[700])),
                    Text('• You will receive an email/SMS notification', style: TextStyle(color: Colors.blue[700])),
                    Text('• Once approved, you can login to the app', style: TextStyle(color: Colors.blue[700])),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (status == 'pending')
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('I understand'),
            )
          else
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Contact Support'),
            ),
        ],
      ),
    );
  }
}
