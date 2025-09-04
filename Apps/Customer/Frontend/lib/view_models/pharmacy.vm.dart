import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/models/vendor.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/requests/vendor.request.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/view_models/base.view_model.dart';
import 'package:Classy/views/pages/vendor_details/vendor_details.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:Classy/extensions/context.dart';

class PharmacyViewModel extends MyBaseViewModel {
  //
  PharmacyViewModel(BuildContext context, VendorType vendorType) {
    this.viewContext = context;
    this.vendorType = vendorType;
  }

  //
  User? currentUser;
  StreamSubscription? currentLocationChangeStream;

  //
  VendorRequest vendorRequest = VendorRequest();
  RefreshController refreshController = RefreshController();
  List<Vendor> vendors = [];

  void initialise() async {
    preloadDeliveryLocation();
    //
    if (AuthServices.authenticated()) {
      currentUser = await AuthServices.getCurrentUser(force: true);
      notifyListeners();
    }
    //get vendors
    getVendors();
  }

  //
  dispose() {
    super.dispose();
    currentLocationChangeStream?.cancel();
  }

  //
  getVendors() async {
    //
    setBusyForObject(vendors, true);
    try {
      vendors = await vendorRequest.nearbyVendorsRequest(
        params: {
          "vendor_type_id": vendorType?.id,
        },
      );
    } catch (error) {
      print("Error ==> $error");
    }
    setBusyForObject(vendors, false);
  }

  //
  openVendorDetails(Vendor vendor) {
    viewContext.push(
      (context) => VendorDetailsPage(
        vendor: vendor,
      ),
    );
  }

  //
  void uploadPrescription() {}
}
