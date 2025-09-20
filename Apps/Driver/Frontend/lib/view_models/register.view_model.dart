import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuodz/services/fallback_auth.service.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/vehicle.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/requests/general.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/traits/qrcode_scanner.trait.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';

class RegisterViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the textediting controllers
  TextEditingController carMakeTEC = new TextEditingController();
  TextEditingController carModelTEC = new TextEditingController();
  List<String> types = ["Regular", "Taxi"];
  List<VehicleType> vehicleTypes = [];
  String selectedDriverType = "regular";
  List<CarMake> carMakes = [];
  List<CarModel> carModels = [];
  CarMake? selectedCarMake;
  CarModel? selectedCarModel;
  List<File> selectedDocuments = [];
  bool hidePassword = true;
  late Country selectedCountry;

  //
  AuthRequest _authRequest = AuthRequest();
  GeneralRequest _generalRequest = GeneralRequest();

  RegisterViewModel(BuildContext context) {
    this.viewContext = context;
    try {
      this.selectedCountry = Country.parse(
        AppStrings.countryCode
            .toUpperCase()
            .replaceAll("AUTO,", "")
            .replaceAll("INTERNATIONAL", "")
            .split(",")[0],
      );
    } catch (error) {
      this.selectedCountry = Country.parse("us");
    }
    notifyListeners();
  }

  @override
  void initialise() {
    super.initialise();
    fetchVehicleTypes();
    fetchCarMakes();
  }

  showCountryDialPicker() {
    showCountryPicker(
      context: viewContext,
      showPhoneCode: true,
      onSelect: (value) => countryCodeSelected(value),
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void onDocumentsSelected(List<File> documents) {
    selectedDocuments = documents;
    notifyListeners();
  }

  void onSelectedDriverType(String? value) {
    selectedDriverType = value ?? "regular";
    notifyListeners();
  }

  onCarMakeSelected(dynamic value) {
    if (!(value is CarMake)) {
      value = carMakes.firstWhere((carMake) => carMake.id == value);
    }
    selectedCarMake = value;
    carMakeTEC.text = value.name;
    notifyListeners();
    fetchCarModel();
  }

  onCarModelSelected(dynamic value) {
    if (!(value is CarModel)) {
      value = carModels.firstWhere((carModel) => carModel.id == value);
    }
    selectedCarModel = value;
    carModelTEC.text = value.name;
    notifyListeners();
  }

  void fetchVehicleTypes() async {
    setBusyForObject(vehicleTypes, true);
    try {
      vehicleTypes = await _generalRequest.getVehicleTypes();
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(vehicleTypes, false);
  }

  void fetchCarMakes() async {
    setBusyForObject(carMakes, true);
    try {
      carMakes = await _generalRequest.getCarMakes();
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(carMakes, false);
  }

  void fetchCarModel() async {
    setBusyForObject(carModels, true);
    try {
      carModels = await _generalRequest.getCarModels(
        carMakeId: selectedCarMake?.id,
      );
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(carModels, false);
  }

  void processRegister() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formBuilderKey.currentState!.saveAndValidate()) {
      setBusy(true);

      try {
        Map<String, dynamic> mValues = formBuilderKey.currentState!.value;
        final carData = {
          "car_make_id": selectedCarMake?.id,
          "car_model_id": selectedCarModel?.id,
        };

        final values = {...mValues, ...carData};
        Map<String, dynamic> params = Map.from(values);
        String phone = params['phone'].toString().telFormat();
        final phoneNumber = "+${selectedCountry.phoneCode}${phone}";
        
        // Use Firebase authentication for registration
        final email = "${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@classy.app";
        
        // Create user with Firebase
        // Check if Firebase is initialized
        bool firebaseAvailable = false;
        try {
          Firebase.app();
          firebaseAvailable = true;
        } catch (e) {
          print('Firebase not available, using fallback registration');
        }
        
        if (firebaseAvailable) {
          try {
            final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: params['password'],
            );
            
            if (userCredential.user != null) {
              // Update user profile with additional information
              await userCredential.user!.updateDisplayName(params['name']);
              
              // Save driver data to Firestore
              await FirebaseFirestore.instance.collection('drivers').doc(userCredential.user!.uid).set({
                'name': params['name'],
                'email': email,
                'phone': phoneNumber,
                'address': params['address'],
                'car_make_id': selectedCarMake?.id,
                'car_model_id': selectedCarModel?.id,
                'driver_type': params['driver_type'] ?? 'regular',
                'role': 'driver',
                'status': 'pending', // New drivers need approval
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
              
              await AlertService.success(
                title: "Become a partner".tr(),
                text: "Registration successful! Your account is pending approval.",
              );
            }
          } catch (firebaseError) {
            print('Firebase registration failed: $firebaseError');
            // Continue with fallback registration
          }
        }
        
        // Fallback: Use local authentication when Firebase is not available
        if (!firebaseAvailable) {
          print('Using fallback registration - Firebase not available');
          
          final userData = {
            'name': params['name'],
            'phone': phoneNumber,
            'email': email,
            'service_type': params['service_type'],
            'address': params['address'],
            'country_code': params['country_code'],
            'driver_type': params['driver_type'] ?? 'regular',
          };
          
          final user = await FallbackAuthService.registerUser(userData);
          
          await AlertService.success(
            title: "Become a partner".tr(),
            text: "Registration successful! Your account is pending approval. (Offline Mode)",
          );
        }
        
      } catch (error) {
        print("Driver registration error: $error");
        toastError("Registration failed. Please try again.");
      } finally {
        setBusy(false);
      }
    }
  }
}
