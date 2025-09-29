import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class CategoriesViewModel extends MyBaseViewModel {
  CategoriesViewModel(
    BuildContext context, {
    this.vendorType,
    this.page,
  }) {
    this.viewContext = context;
  }

  final VendorType? vendorType;
  final int? page;
  List<dynamic> categories = [];
  RefreshController refreshController = RefreshController();

  void initialise() {
    loadCategories();
  }

  void loadCategories() {
    setBusy(true);
    // TODO: Load categories from API
    categories = [];
    setBusy(false);
    refreshController.refreshCompleted();
  }

  void categorySelected(dynamic category) {
    // TODO: Handle category selection
  }
}
