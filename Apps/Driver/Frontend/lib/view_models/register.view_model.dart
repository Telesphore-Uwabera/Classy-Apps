import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          
          // Show detailed success message with approval information
          _showRegistrationSuccessDialog();
        }
        
      } catch (error) {
        print("Driver registration error: $error");
        toastError("Registration failed. Please try again.");
      } finally {
        setBusy(false);
      }
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: viewContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Registration Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your driver account has been created successfully.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: Colors.orange[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pending Admin Approval',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your account is currently under review by our admin team. You will receive a notification once your account is approved.',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'What happens next?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Admin will review your application'),
            Text('• You will receive an email/SMS notification'),
            Text('• Once approved, you can login to the app'),
            Text('• This process usually takes 24-48 hours'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to login
            },
            child: Text('Got it', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
