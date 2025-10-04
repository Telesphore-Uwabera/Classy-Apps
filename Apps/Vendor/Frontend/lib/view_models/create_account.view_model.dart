import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/models/address.dart';
import 'package:fuodz/models/country.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';

class CreateAccountViewModel extends MyBaseViewModel {
  // Form key for validation
  GlobalKey<FormBuilderState> formBuilderKey = GlobalKey<FormBuilderState>();
  
  // Country selection
  Country? selectedCountry;
  
  // Address related
  String? address;
  String? latitude;
  String? longitude;
  
  // Services
  AuthRequest _authRequest = AuthRequest();

  CreateAccountViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    String countryCode = await Utils.getCurrentCountryCode();
    this.selectedCountry = Country.findByPhoneCode("+$countryCode") ?? Country.defaultCountry;
    notifyListeners();
  }

  void updateSelectedCountry(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  Future<List<Address>> searchAddress(String keyword) async {
    List<Address> addresses = [];
    try {
      addresses = await GeocoderService().findAddressesFromQuery(keyword);
    } catch (error) {
      toastError("$error");
    }
    return addresses;
  }

  onAddressSelected(Address address) {
    this.address = address.addressLine;
    this.latitude = address.coordinates?.latitude.toString();
    this.longitude = address.coordinates?.longitude.toString();
    notifyListeners();
  }

  void processRegistration() async {
    // Validate the form
    if (formBuilderKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> params = Map.from(
        formBuilderKey.currentState!.value,
      );
      
      // Format phone number
      String phone = params['phone'].toString();
      params["phone"] = "+${selectedCountry?.phoneCode}${phone}";
      
      // Add address and coordinates
      params["address"] = address;
      params["latitude"] = latitude;
      params["longitude"] = longitude;
      
      // Set vendor type to food vendor (default)
      params["vendor_type_id"] = 1; // Assuming 1 is food vendor
      
      setBusy(true);

      try {
        final apiResponse = await _authRequest.registerRequest(
          vals: params,
        );

        if (apiResponse.allGood) {
          await AlertService.success(
            title: "Account Created".tr(),
            text: "Your vendor account has been created successfully. Please wait for admin approval.".tr(),
          );
          // Reset form
          resetValues();
          // Navigate back to login
          Navigator.of(viewContext).pop();
        } else {
          toastError("${apiResponse.message}");
        }
      } catch (error) {
        toastError("$error");
      }

      setBusy(false);
    }
  }

  void resetValues() {
    formBuilderKey.currentState?.reset();
    selectedCountry = null;
    address = null;
    latitude = null;
    longitude = null;
    notifyListeners();
  }
}
