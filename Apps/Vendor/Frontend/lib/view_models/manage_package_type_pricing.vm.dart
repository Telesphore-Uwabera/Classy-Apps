import 'services/alert.service.dart';
import 'package:flutter/material.dart';
import 'models/package_type.dart';
import 'models/package_type_pricing.dart';
import 'requests/package_type_pricing.request.dart';
import 'view_models/base.view_model.dart';
import 'extensions/context.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ManagePackageTypePricingViewModel extends MyBaseViewModel {
  //
  ManagePackageTypePricingViewModel(
    BuildContext context,
    this.packageTypePricing,
  ) {
    this.viewContext = context;
  }

  //
  PackageTypePricingRequest packageTypePricingRequest =
      PackageTypePricingRequest();
  List<PackageType> packageTypes = [];
  PackageTypePricing? packageTypePricing;

  void initialise() {
    fetchPackageTypes();
  }

  //
  fetchPackageTypes() async {
    setBusyForObject(packageTypes, true);

    try {
      packageTypes = await packageTypePricingRequest.getPackageTypes();
      clearErrors();
    } catch (error) {
      print("Package Types Error ==> $error");
      setError(error);
    }

    setBusyForObject(packageTypes, false);
  }

  //update pricing
  processUpdate() async {
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //
      setBusy(true);

      try {
        try {
          final apiResponse = await packageTypePricingRequest.updateDetails(
            packageTypePricing!,
            data: formBuilderKey.currentState!.value,
          );
          //
          //show dialog to present state
          AlertService.dynamic(
              type: apiResponse.allGood ? AlertType.success : AlertType.error,
              title: "Successfull".tr(),
              text: apiResponse.message,
              onConfirm: () {
                viewContext.pop(true);
              });
          clearErrors();
        } catch (error) {
          print("Update Status Package Type Pricing Error ==> $error");
          setError(error);
        }
        clearErrors();
      } catch (error) {
        print("Package Types Error ==> $error");
        setError(error);
      }

      setBusy(false);
    }
  }

  //New pricing
  processNewPricing() async {
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //
      setBusy(true);

      try {
        try {
          final apiResponse = await packageTypePricingRequest.newPricing(
            formBuilderKey.currentState!.value,
          );
          //
          //show dialog to present state
          AlertService.dynamic(
            type: apiResponse.allGood ? AlertType.success : AlertType.error,
            title: "Successfull".tr(),
            text: apiResponse.message,
            onConfirm: () {
              viewContext.pop(true);
            },
          );
          clearErrors();
        } catch (error) {
          print("Update Status Package Type Pricing Error ==> $error");
          setError(error);
        }
        clearErrors();
      } catch (error) {
        print("Package Types Error ==> $error");
        setError(error);
      }

      setBusy(false);
    }
  }
}
