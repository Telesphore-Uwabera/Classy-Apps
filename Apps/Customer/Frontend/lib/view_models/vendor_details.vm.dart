import 'package:flutter/material.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/models/vendor.dart';
import 'package:Classy/models/product.dart';
import 'package:Classy/requests/vendor.request.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/view_models/base.view_model.dart';
import 'package:Classy/views/pages/vendor_search/vendor_search.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:Classy/extensions/context.dart';

class VendorDetailsViewModel extends MyBaseViewModel {
  //
  VendorDetailsViewModel(BuildContext context, this.vendor) {
    this.viewContext = context;
  }

  //
  VendorRequest _vendorRequest = VendorRequest();

  //
  Vendor? vendor;
  TabController? tabBarController;
  final currencySymbol = AppStrings.currencySymbol;

  RefreshController refreshContoller = RefreshController();
  List<RefreshController> refreshContollers = [];
  List<int> refreshContollerKeys = [];

  //
  Map<int, List> menuProducts = {};
  Map<int, int> menuProductsQueryPages = {};

  //
  getVendorDetails() async {
    //
    setBusy(true);

    try {
      vendor = await _vendorRequest.vendorDetails(
        vendor!.id,
        params: {"type": "small"},
      );

      clearErrors();
    } catch (error) {
      setError(error);
      print("error ==> ${error}");
    }
    setBusy(false);
  }

  void productSelected(Product product) async {
    await Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.product, arguments: product);

    //
    notifyListeners();
  }

  //
  void uploadPrescription() {
    //
    // Pharmacy upload prescription removed
  }

  openVendorSearch() {
    viewContext.push((context) => VendorSearchPage(vendor!));
  }
}
