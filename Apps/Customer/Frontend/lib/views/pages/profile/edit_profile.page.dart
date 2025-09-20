import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/constants/app_strings.dart';
import 'package:Classy/extensions/context.dart';
import 'package:Classy/extensions/dynamic.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/requests/auth.request.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/services/location.service.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/utils/app_text_style.dart';
import 'package:Classy/view_models/profile.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/custom_text_form_field.dart';
import 'package:Classy/widgets/cards/profile.card.dart';
import 'package:Classy/widgets/states/empty.state.dart';
import 'package:Classy/widgets/main_bottom_nav.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:Classy/services/location_bridge.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _homeAddressController;
  late TextEditingController _workAddressController;
  bool _isSaving = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    final currentUser = AuthServices.currentUser;
    _fullNameController = TextEditingController(text: currentUser?.name ?? "");
    _phoneController = TextEditingController(text: currentUser?.phone ?? "");
    _homeAddressController = TextEditingController(text: "Home Address"); // TODO: Get from user preferences
    _workAddressController = TextEditingController(text: "Work Address"); // TODO: Get from user preferences
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _homeAddressController.dispose();
    _workAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo selected!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
        return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Edit Profile",
      body: VStack([
        // Pink Header Section
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: VStack([
            // Status bar spacer
            UiSpacer.verticalSpace(space: 50),
            
            // Back button and title
            HStack([
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: "Edit Profile".tr().text.white.bold.xl2.make().centered(),
              ),
              SizedBox(width: 48), // Balance the back button
            ]).py12(),
            
            // Profile Picture
            VStack([
                  Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : AuthServices.currentUser?.photo != null
                        ? NetworkImage(AuthServices.currentUser!.photo!)
                        : AssetImage(AppImages.appLogo) as ImageProvider,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColor.primaryColor,
                      size: 20,
                    ),
                  ).onTap(() {
                    _pickImage();
                  }),
                ],
              ),
              "Change Profile Photo".tr().text.white.make().py8().onTap(() {
                _pickImage();
              }),
            ]).py20(),
          ]).p20(),
        ),
        
        // Content Section
        Expanded(
          child: SingleChildScrollView(
            child: VStack([
              UiSpacer.verticalSpace(space: 20),
              
              // Personal Information Section
              _buildSection(
                title: "Personal Information",
                children: [
                  _buildFormField(
                    label: "Full Name",
                    controller: _fullNameController,
                    icon: Icons.person,
                  ),
                  UiSpacer.verticalSpace(space: 16),
                  _buildFormField(
                    label: "Phone Number",
                    controller: _phoneController,
                    icon: Icons.phone,
                  ),
                ],
              ),
              
              UiSpacer.verticalSpace(space: 24),
              
              // Saved Locations Section
              _buildSection(
                title: "Saved Locations",
                children: [
                  _buildLocationField(
                    controller: _homeAddressController,
                    icon: Icons.home,
                  ),
                  UiSpacer.verticalSpace(space: 16),
                  _buildLocationField(
                    controller: _workAddressController,
                    icon: Icons.work,
                  ),
                ],
              ),
              
              UiSpacer.verticalSpace(space: 40),
              
              // Action Buttons
              HStack([
                Expanded(
                  child: CustomButton(
                    title: "Cancel",
                    color: Colors.white,
                    titleStyle: AppTextStyle.h3TitleTextStyle(
                      color: AppColor.primaryColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                UiSpacer.horizontalSpace(space: 16),
                Expanded(
                  child: CustomButton(
                    title: _isSaving ? "Saving..." : "Save Changes",
                    color: AppColor.primaryColor,
                    titleStyle: AppTextStyle.h3TitleTextStyle(
                      color: Colors.white,
                    ),
                    onPressed: _isSaving ? null : () async {
                      await _saveProfileChanges();
                    },
                  ),
                ),
              ]),
              
              UiSpacer.verticalSpace(space: 20),
            ]).px20(),
          ),
        ),
      ]),
    );
  }
  
  Future<void> _changeProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
                    children: [
              ListTile(
                leading: Icon(Icons.photo_camera, color: AppColor.primaryColor),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement camera functionality
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColor.primaryColor),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement gallery picker
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.remove_circle, color: Colors.red),
                title: Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _removeProfilePhoto() {
    // TODO: Implement remove photo functionality
    setState(() {
      _selectedImage = null;
    });
    _showMessage('Photo removed successfully!');
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.primaryColor,
      ),
    );
  }
  
  Future<void> _saveProfileChanges() async {
    // Validate form fields
    if (_fullNameController.text.trim().isEmpty) {
      _showMessage('Please enter your full name');
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      _showMessage('Please enter your phone number');
      return;
    }
    
    try {
      setState(() {
        _isSaving = true;
      });
      
      // Call API to update profile
      final response = await AuthRequest.updateProfile({
        'name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': AuthServices.currentUser?.email,
        'countryCode': AuthServices.currentUser?.countryCode ?? "256",
      });

      if (response.allGood) {
        // Update local user data with new information
        final currentUser = AuthServices.currentUser;
        if (currentUser != null) {
          currentUser.name = _fullNameController.text.trim();
          currentUser.phone = _phoneController.text.trim();
          await AuthServices.saveUser(currentUser.toJson());
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back
        Navigator.of(context).pop();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating profile'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return VStack([
      title.text.bold.xl.make().py8(),
      ...children,
    ]);
  }
  
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return VStack([
      label.text.gray600.sm.make().py4(),
      CustomTextFormField(
        textEditingController: controller,
        prefixIcon: Icon(icon, color: AppColor.primaryColor),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
      ),
    ], crossAlignment: CrossAxisAlignment.start);
  }
  
  Widget _buildLocationField({
    required TextEditingController controller,
    required IconData icon,
  }) {
    String locationName = "";
    if (icon == Icons.home) {
      locationName = "Home Address";
    } else if (icon == Icons.work) {
      locationName = "Work Address";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showAddLocationModal(context, locationName);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: HStack([
              Icon(icon, color: AppColor.primaryColor),
              UiSpacer.horizontalSpace(space: 12),
              Expanded(
                child: controller.text.text.make(),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ]),
          ),
        ),
      ),
    );
  }
  
  void _showAddLocationModal(BuildContext context, String locationType) {
    final addressController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    HStack([
                      "Add $locationType".tr().text.bold.xl.make(),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                    ]).py16(),
                    
                    UiSpacer.verticalSpace(space: 20),
                    
                    // Address Input
                        CustomTextFormField(
                      textEditingController: addressController,
                      labelText: "Enter Address".tr(),
                      hintText: "123 Main Street, City",
                      prefixIcon: Icon(Icons.location_on, color: AppColor.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      maxLines: 3,
                    ),
                    
                    UiSpacer.verticalSpace(space: 20),
                    
                    // Quick Location Options
                    VStack([
                      "Quick Options".tr().text.bold.make(),
                      UiSpacer.verticalSpace(space: 12),
                      
                      ListTile(
                        leading: Icon(Icons.my_location, color: AppColor.primaryColor),
                        title: "Use Current Location".tr().text.make(),
                        subtitle: "We'll detect your current location".tr().text.gray600.sm.make(),
                        onTap: () {
                          Navigator.pop(context);
                          _useCurrentLocation(locationType);
                        },
                      ),
                      
                      ListTile(
                        leading: Icon(Icons.map, color: AppColor.primaryColor),
                        title: "Select on Map".tr().text.make(),
                        subtitle: "Choose location from map".tr().text.gray600.sm.make(),
                        onTap: () {
                          Navigator.pop(context);
                          _selectOnMap(locationType);
                        },
                      ),
                    ]),
                    
                    UiSpacer.verticalSpace(space: 24),
                    
                    // Save Button
                    Container(
                      width: double.infinity,
                      child: CustomButton(
                        title: "Save Location".tr(),
                        color: AppColor.primaryColor,
                        titleStyle: AppTextStyle.h3TitleTextStyle(color: Colors.white),
                        onPressed: () {
                          if (addressController.text.trim().isEmpty) {
                            _showMessage('Please enter an address');
                            return;
                          }
                          
                          // Update the appropriate controller
                          if (locationType.contains("Home")) {
                            _homeAddressController.text = addressController.text.trim();
                          } else if (locationType.contains("Work")) {
                            _workAddressController.text = addressController.text.trim();
                          }
                          
                          Navigator.pop(context);
                          _showMessage('Location saved successfully!');
                        },
                      ),
                    ),
                    
                    UiSpacer.verticalSpace(space: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _useCurrentLocation(String locationType) async {
    try {
      _showMessage('Getting your current location...');
      
      // For web, use improved web location service
      if (kIsWeb) {
        // First check if location service is enabled
        final isEnabled = await WebLocationService.isLocationServiceEnabled();
        if (!isEnabled) {
          throw Exception('Location services are disabled. Please enable location services in your browser.');
        }

        // Request permission if needed
        final hasPermission = await WebLocationService.requestLocationPermission();
        if (!hasPermission) {
          throw Exception('Location permission denied. Please allow location access in your browser settings.');
        }

        // Get current address with better error handling
        final address = await WebLocationService.getCurrentAddress(
          timeout: Duration(seconds: 15),
        );
        
        if (address != null && address.isNotEmpty) {
          // Update the appropriate controller
          if (locationType.contains("Home")) {
            _homeAddressController.text = address;
          } else if (locationType.contains("Work")) {
            _workAddressController.text = address;
          }
          
          _showMessage('Location detected successfully!');
        } else {
          throw Exception('Unable to get address from current location');
        }
      } else {
        // For mobile, use the existing location service
        await LocationService.prepareLocationListener(true);
        await Future.delayed(Duration(seconds: 2));
        
        final currentAddress = LocationService.currenctAddress;
        if (currentAddress != null) {
          final addressText = currentAddress.addressLine ?? currentAddress.featureName ?? "Current Location";
          
          // Update the appropriate controller
          if (locationType.contains("Home")) {
            _homeAddressController.text = addressText;
          } else if (locationType.contains("Work")) {
            _workAddressController.text = addressText;
          }
          
          _showMessage('Location detected successfully!');
        } else {
          throw Exception('Unable to detect current location');
        }
      }
    } catch (e) {
      print('Location error: $e');
      String errorMessage = 'Location detection failed. Please use "Select on Map" to choose your location.';
      
      if (e.toString().contains('permission')) {
        errorMessage = 'Location permission denied. Please allow location access in your browser settings or use "Select on Map" instead.';
      } else if (e.toString().contains('disabled')) {
        errorMessage = 'Location services are disabled. Please enable location services in your browser or use "Select on Map" instead.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Location request timed out. Please try again or use "Select on Map" instead.';
      }
      
      _showMessage(errorMessage);
    }
  }
  
  void _selectOnMap(String locationType) async {
    try {
      // Import the Google Maps place picker
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlacePicker(
            apiKey: AppStrings.googleMapApiKey, // Use centralized API key
            onPlacePicked: (result) {
              final addressText = result.formattedAddress ?? "Selected Location";
              
              // Update the appropriate controller
              if (locationType.contains("Home")) {
                _homeAddressController.text = addressText;
              } else if (locationType.contains("Work")) {
                _workAddressController.text = addressText;
              }
              
              Navigator.of(context).pop();
              _showMessage('Location selected successfully!');
            },
            initialPosition: LatLng(0.3476, 32.5825), // Kampala coordinates
            useCurrentLocation: true,
            resizeToAvoidBottomInset: true,
          ),
        ),
      );
    } catch (e) {
      _showMessage('Map selection failed. Please try again.');
    }
  }
}
