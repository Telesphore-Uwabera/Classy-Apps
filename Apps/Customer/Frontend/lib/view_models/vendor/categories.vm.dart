import 'package:flutter/material.dart';
import 'package:Classy/models/category.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/requests/category.request.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/view_models/base.view_model.dart';

class CategoriesViewModel extends MyBaseViewModel {
  CategoriesViewModel(BuildContext context, {this.vendorType, this.page}) {
    this.viewContext = context;
  }

  int? page;

  //
  CategoryRequest _categoryRequest = CategoryRequest();
  // RefreshController refreshController = RefreshController();

  //
  List<Category> categories = [];
  VendorType? vendorType;

  //
  initialise() {
    loadCategories();
  }

  //
  loadCategories() async {
    categories = [];
    setBusy(true);

    try {
      categories = await _categoryRequest.categories(
        vendorTypeId: vendorType?.id,
        page: page,
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  categorySelected(Category category) async {
    NavigationService.categorySelected(category);
  }
}
