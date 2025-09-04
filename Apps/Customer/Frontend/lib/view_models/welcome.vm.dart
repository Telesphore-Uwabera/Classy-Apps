import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/requests/vendor_type.request.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/location.service.dart';
import 'package:Classy/view_models/base.view_model.dart';
import 'package:Classy/views/pages/vendor/featured_vendors.page.dart';

class WelcomeViewModel extends MyBaseViewModel {
  //
  WelcomeViewModel(BuildContext context) {
    this.viewContext = context;
  }

  Widget? selectedPage;
  List<VendorType> vendorTypes = [];
  VendorTypeRequest vendorTypeRequest = VendorTypeRequest();
  bool showGrid = true;
  StreamSubscription? authStateSub;
  String? locationText;

  //
  //
  initialise({bool initial = true}) async {
    //
    preloadDeliveryLocation();
    //
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }

    if (!initial) {
      pageKey = GlobalKey();
      notifyListeners();
    }

    await getVendorTypes();
    listenToAuth();
    //
    handleLocationStream();
  }

  StreamSubscription? currentLocSub;
  StreamSubscription? currentLoc2Sub;
  handleLocationStream() async {
    await currentLocSub?.cancel();
    currentLocSub = LocationService.currenctDeliveryAddressSubject
        .skipWhile((_) => true)
        .listen(
      (event) {
        initialise(initial: false);
      },
    );

    await currentLoc2Sub?.cancel();
    currentLoc2Sub = LocationService.currenctDeliveryAddressSubject.stream
        .skipWhile((_) => true)
        .listen((event) {
      initialise(initial: false);
    });
  }

  listenToAuth() {
    authStateSub = AuthServices.listenToAuthState().listen((event) {
      genKey = GlobalKey();
      notifyListeners();
    });
  }

  getVendorTypes() async {
    setBusy(true);
    try {
      vendorTypes = await vendorTypeRequest.index();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  openFeaturedVendors() async {
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => FeaturedVendorsPage(),
      ),
    );
  }
}
