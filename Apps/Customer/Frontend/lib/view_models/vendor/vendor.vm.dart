import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/view_models/base.view_model.dart';

class VendorViewModel extends MyBaseViewModel {
  VendorViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
  }

  final VendorType vendorType;

  void initialise() {
    setBusy(false);
  }
}
