import 'package:flutter/material.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/view_models/payment.view_model.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:velocity_x/velocity_x.dart';

class AccountDeleteViewModel extends PaymentViewModel {
  //
  User? currentUser;
  AuthRequest _authRequest = AuthRequest();
  bool otherReason = false;
  String? reason;

  AccountDeleteViewModel(BuildContext context) {
    this.viewContext = context;
  }

  List<String> get reasons {
    return ["customer support", "other"];
  }

  onReasonChange(String reason) {
    otherReason = reason.toLowerCase() == "other";
    if (!otherReason) {
      reason = reason;
    }
    notifyListeners();
  }

  processAccountDeletion() async {
    // AuthRequest.deleteAccount("");
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //
      setBusy(true);
      try {
        final formValue = formBuilderKey.currentState?.value;
        final apiResponse = await AuthRequest.deleteProfile({
          'password': formValue!["password"],
        });
        if (apiResponse.allGood) {
          toastSuccessful("${apiResponse.message}");
          await AuthServices.logout();
          Navigator.of(viewContext).pushNamedAndRemoveUntil(
            AppRoutes.loginRoute,
            (route) => false,
          );
        } else {
          toastError("${apiResponse.message}");
        }
      } catch (error) {
        toastError("$error");
      }
      setBusy(false);
    }
  }
}
