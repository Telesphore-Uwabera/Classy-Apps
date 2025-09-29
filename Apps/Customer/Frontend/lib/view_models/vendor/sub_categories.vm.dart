import 'package:flutter/material.dart';
import 'package:Classy/models/category.dart';
import 'package:Classy/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class SubcategoriesViewModel extends MyBaseViewModel {
  SubcategoriesViewModel(BuildContext context, this.category) {
    this.viewContext = context;
  }

  final Category category;
  List<dynamic> subcategories = [];
  RefreshController refreshController = RefreshController();

  void initialise() {
    loadSubcategories();
  }

  void loadSubcategories() {
    setBusy(true);
    // TODO: Load subcategories from API
    subcategories = [];
    setBusy(false);
    refreshController.refreshCompleted();
  }

  void categorySelected(dynamic category) {
    // TODO: Handle category selection
  }
}
