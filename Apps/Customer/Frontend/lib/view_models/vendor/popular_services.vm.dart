import 'package:flutter/material.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/models/service.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/requests/service.request.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/view_models/base.view_model.dart';
import 'package:Classy/views/pages/service/service_details.page.dart';
import 'package:Classy/extensions/context.dart';

class PopularServicesViewModel extends MyBaseViewModel {
  //
  ServiceRequest _serviceRequest = ServiceRequest();
  //
  List<Service> services = [];
  VendorType? vendorType;

  PopularServicesViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
  }

  //
  initialise() async {
    setBusy(true);
    try {
      services = await _serviceRequest.getServices(
        byLocation: AppStrings.enableFatchByLocation,
        queryParams: {
          "vendor_type_id": vendorType?.id,
        },
      );
      clearErrors();
    } catch (error) {
      print("PopularServicesViewModel Error ==> $error");
      setError(error);
    }
    setBusy(false);
  }

  //
  serviceSelected(Service service) {
    viewContext.push(
      (context) => ServiceDetailsPage(service),
    );
  }

  openSearch({int showType = 4}) async {
    NavigationService.openServiceSearch(
      viewContext,
      byLocation: AppStrings.enableFatchByLocation,
      vendorType: vendorType,
      showServices: true,
      showVendors: false,
    );
  }
}
