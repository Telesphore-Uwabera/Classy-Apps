import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MyBaseViewModel extends BaseViewModel {
  BuildContext? viewContext;
  
  void initialise() {
    // Custom initialization logic
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}