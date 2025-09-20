import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'constants/app_strings.dart';
import 'models/delivery_address.dart';
import 'services/toast.service.dart';
import 'services/update.service.dart';
import 'views/pages/shared/custom_webview.page.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'extensions/context.dart';

class MyBaseViewModel extends BaseViewModel with UpdateService {
  //
  late BuildContext viewContext;
  final formKey = GlobalKey<FormState>();
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final currencySymbol = AppStrings.currencySymbol;
  GlobalKey pageKey = GlobalKey<FormState>();
  DeliveryAddress? deliveryaddress;
  String? firebaseVerificationId;

  void initialise() {
    //FirestoreRepository();
  }

  newPageKey() {
    pageKey = GlobalKey<FormState>();
    notifyListeners();
  }

  //show toast
  toastSuccessful(String msg, {String? title}) {
    ToastService.toastSuccessful(msg, title: title);
  }

  toastError(String msg, {String? title}) {
    ToastService.toastError(msg, title: title);
  }

  openWebpageLink(String url, {bool external = false}) async {
    if (external) {
      await launchUrlString(url);
      return;
    }
    await viewContext.push(
      (context) => CustomWebviewPage(
        selectedUrl: url,
      ),
    );
  }

  Future<dynamic> openExternalWebpageLink(String url) async {
    try {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      return;
    } catch (error) {
      print("Error ==> $error");
      ToastService.toastError("$error");
    }
  }
}
