import 'package:flutter/material.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/models/vendor.dart';
import 'package:Classy/requests/vendor.request.dart';
import 'package:Classy/view_models/base.view_model.dart';

class FeaturedVendorsPageViewModel extends MyBaseViewModel {
  FeaturedVendorsPageViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  List<Vendor> vendors = [];
  int page = 1;
  VendorRequest _vendorRequest = VendorRequest();

  //
  initialise() {
    fetchFeaturedVendors();
  }

  //
  fetchFeaturedVendors([bool initial = true]) async {
    if (initial) {
      page = 1;
      refreshController.refreshCompleted();
      setBusy(true);
    } else {
      page++;
    }

    //
    try {
      //filter by location if user selects delivery address
      final mVndors = await _vendorRequest.vendorsRequest(
        page: page,
        params: {
          "type": "featured",
        },
      );

      if (initial) {
        vendors = mVndors;
      } else {
        vendors.addAll(mVndors);
      }
    } catch (error) {
      setError(error);
    }
    setBusy(false);
    refreshController.loadComplete();
  }

  vendorSelected(Vendor vendor) async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.vendorDetails,
      arguments: vendor,
    );
  }
}
