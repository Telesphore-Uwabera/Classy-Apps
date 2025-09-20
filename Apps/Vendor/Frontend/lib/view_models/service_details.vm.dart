import 'services/alert.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/swidgets/framework.dart';
import 'models/service.dart';
import 'requests/service.request.dart';
import 'view_models/base.view_model.dart';
import 'views/pages/service/edit_service.page.dart';
import 'extensions/context.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ServiceDetailsViewModel extends MyBaseViewModel {
  //
  ServiceDetailsViewModel(BuildContext context, this.service) {
    this.viewContext = context;
  }

  //
  ServiceRequest _serviceRequest = ServiceRequest();
  Service service;

  goBack() {
    viewContext.pop(service);
  }

  editService() async {
    //
    final result = await viewContext.push(
      (context) => EditServicePage(service),
    );
    if (result != null && result is Service) {
      service = result;
      notifyListeners();
    }
  }

  deleteService() {
    //
    AlertService.confirm(
      title: "Delete Service".tr(),
      text: "Are you sure you want to delete service?".tr(),
      onConfirm: () {
        processDeletion();
      },
    );
  }

  processDeletion() async {
    //
    setBusy(true);
    try {
      final apiResponse = await _serviceRequest.deleteService(
        service,
      );

      //show dialog to present state
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Delete Service".tr(),
        text: apiResponse.message,
        onConfirm: apiResponse.allGood
            ? () {
                viewContext.pop(true);
              }
            : null,
      );
      clearErrors();
    } catch (error) {
      print("delete service Error ==> $error");
      setError(error);
    }
    setBusy(false);
  }
}
