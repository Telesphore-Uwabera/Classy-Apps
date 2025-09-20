import 'dart:io';

import 'services/alert.service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/user.dart';
import 'requests/auth.request.dart';
import 'services/auth.service.dart';
import 'view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'extensions/context.dart';

class EditProfileViewModel extends MyBaseViewModel {
  User? currentUser;
  File? newPhoto;
  //the textediting controllers
  TextEditingController nameTEC = new TextEditingController();

  TextEditingController phoneTEC = new TextEditingController();

  //
  AuthRequest _authRequest = AuthRequest();
  final picker = ImagePicker();

  EditProfileViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    //
    currentUser = await AuthServices.getCurrentUser();
    nameTEC.text = currentUser!.name;

    phoneTEC.text = currentUser!.phone;
    notifyListeners();
  }

  //
  void changePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      newPhoto = File(pickedFile.path);
    } else {
      newPhoto = null;
    }

    notifyListeners();
  }

  //
  processUpdate() async {
    //
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);

      //
      final apiResponse = await _authRequest.updateProfile(
        photo: newPhoto,
        name: nameTEC.text,
  
        phone: phoneTEC.text,
      );

      //
      setBusy(false);

      //update local data if all good
      if (apiResponse.allGood) {
        //everything works well
        await AuthServices.saveUser(apiResponse.body["user"]);
      }

      //
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Profile Update".tr(),
        text: apiResponse.message,
        onConfirm:
            apiResponse.allGood
                ? () {
                  viewContext.pop(true);
                }
                : null,
      );
    }
  }
}
