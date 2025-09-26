import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_images.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/constants/home_screen.config.dart';
import 'package:Classy/extensions/context.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/services/simple_location.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/location_preferences.service.dart';
import 'package:Classy/models/search.dart';
import 'package:Classy/models/user.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/view_models/welcome.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/custom_easy_refresh_view.dart';
import 'package:Classy/widgets/main_bottom_nav.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
// Wallet functionality removed - using Eversend, MoMo, and card payments only

class WelcomePage extends StatefulWidget {
  WelcomePage({
    Key? key,
  }) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with AutomaticKeepAliveClientMixin<WelcomePage> {
  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return BasePage(
      body: ViewModelBuilder<WelcomeViewModel>.reactive(
        viewModelBuilder: () => WelcomeViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        disposeViewModel: false,
        builder: (context, vm, child) {
          return CustomEasyRefreshView(
            headerView: MaterialHeader(),
            onRefresh: () => vm.initialise(initial: false),
            child: _CustomerHome(),
          );
        },
      ),
    );
  }
}

class _CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<_CustomerHome> {
  String locationText = "Fetching location...";
  bool isLoadingLocation = true;
  final LocationPreferencesService _locationService = LocationPreferencesService();
  String _workAddress = "Not set";
  String _homeAddress = "Not set";
  User? _currentUser;
  
  // Payment methods: Eversend, MoMo, and Card payments only
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchCurrentLocation();
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthServices.getCurrentUser(force: true);
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Wallet functionality removed - using Eversend, MoMo, and card payments only

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
        
        // TODO: Upload image to server and update user profile
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo updated!'),
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

  Future<void> _saveLocation(String address) async {
    try {
      // Save current location to preferences
      await _locationService.saveCurrentLocation(address);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  Future<void> _loadSavedAddresses() async {
    // Load saved addresses from preferences
    final workAddr = await _locationService.getFormattedWorkAddress();
    final homeAddr = await _locationService.getFormattedHomeAddress();
    
    setState(() {
      _workAddress = workAddr;
      _homeAddress = homeAddr;
      // Current location will be fetched by _fetchCurrentLocation()
    });
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      if (mounted) {
        setState(() {
          isLoadingLocation = true;
        });
      }

      // Use simple location service
      String? address = await SimpleLocationService.getCurrentAddress();
      
      if (mounted) {
        setState(() {
          locationText = address ?? "Tap to set location";
          isLoadingLocation = false;
        });
      }
      
      // Save the location if we got one
      if (address != null) {
        await _saveLocation(address);
      }
    } catch (e) {
      print('Location fetch error: $e');
      if (mounted) {
        setState(() {
          locationText = "Tap to set location";
          isLoadingLocation = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: VStack([
        // Greeting and Search Section
        VStack([
          // Greeting
          HStack([
            VStack([
              "Welcome back, ${_currentUser?.name ?? 'User'}".tr().text.xl2.bold.make(),
              "Ready to explore today?".tr().text.lg.gray600.make(),
            ]).expand(),
            
            // Quick Menu Button
            IconButton(
              onPressed: () => _openQuickMenu(context),
              icon: Icon(Icons.menu, color: AppColor.primaryColor),
              style: IconButton.styleFrom(
                backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                padding: EdgeInsets.all(12),
              ),
            ),
          ]).py16(),
          
          // Wallet Balance Display
          GestureDetector(
            onTap: () {
              // Navigate to wallet page
              Navigator.of(context).pushNamed(AppRoutes.walletRoute);
            },
            child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: HStack([
                  Icon(Icons.account_balance_wallet, color: AppColor.primaryColor),
                UiSpacer.horizontalSpace(space: 12),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Payment Methods".text.gray500.sm.make(),
                        UiSpacer.verticalSpace(space: 4),
                        "Eversend, MoMo, Card".text.gray700.bold.make(),
                      ],
                    ),
                ),
                IconButton(
                    icon: Icon(Icons.payment, color: AppColor.primaryColor),
                  onPressed: () {
                      // Navigate to payment methods
                    },
                    tooltip: 'Payment methods',
                ),
              ]),
              ),
            ),
          ).py16(),
        ]).px20(),
        

        
        // Service Grid
        VStack([
          "What would you like to do today?".tr().text.xl.bold.make().py16(),
          
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.15,
              children: [
              _buildServiceTile(
                icon: Icons.local_taxi,
                title: "Request Ride",
                subtitle: "",
                image: "assets/images/service_car.png",
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.taxiRoute),
              ),
              _buildServiceTile(
                icon: Icons.restaurant,
                title: "Food & Supplies",
                subtitle: "",
                image: "assets/images/service_food.png",
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.foodRoute),
              ),
              _buildServiceTile(
                icon: Icons.motorcycle,
                title: "Boda Boda",
                subtitle: "",
                image: "assets/images/service_boda.png",
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.bodabodaRoute),
              ),
              _buildServiceTile(
                icon: Icons.flight,
                title: "Domestic flights",
                subtitle: "",
                image: "assets/images/service_flights.png",
                onTap: () => _showFlightsComingSoonModal(context),
              ),
            ],
          ),
          ),
        ]).px20().py16(),
        
        UiSpacer.verticalSpace(space: 16),
        
        // Dynamic Ads Section
        _buildAdsSection(),
        
        UiSpacer.verticalSpace(space: 20),
      ]),
    );
  }

  void _openQuickMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Profile Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColor.primaryColor, AppColor.primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                                child: _selectedImage != null
                                    ? Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : _currentUser?.photo != null
                                  ? Image.network(
                                            _currentUser!.photo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: 40,
                                          color: AppColor.primaryColor,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColor.primaryColor,
                                    ),
                            ),
                          ),
                          // Camera Icon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                        ),
                      ),
                      
                      UiSpacer.verticalSpace(space: 12),
                      
                      // User Name
                      "${_currentUser?.name ?? 'User'}".text.white.xl.bold.make(),
                      
                      UiSpacer.verticalSpace(space: 8),
                      
                      // Edit Profile Button
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 16),
                            UiSpacer.horizontalSpace(space: 6),
                            "Edit Profile".tr().text.white.sm.make(),
                          ],
                        ),
                      ).onTap(() {
                        Navigator.pop(ctx);
                        Navigator.of(context).pushNamed(AppRoutes.editProfileRoute);
                      }),
                    ],
                  ),
                ),
                
                UiSpacer.verticalSpace(space: 20),
                
                // Personal Information Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Personal Information".tr().text.bold.lg.make(),
                      UiSpacer.verticalSpace(space: 12),
                      
                      // Full Name
                      _buildInfoField(
                        icon: Icons.person,
                        label: "Full Name",
                        value: _currentUser?.name ?? "Not set",
                      ),
                      
                      UiSpacer.verticalSpace(space: 8),
                      
                      // Phone Number
                      _buildInfoField(
                        icon: Icons.phone,
                        label: "Phone Number",
                        value: _currentUser?.phone ?? "Not set",
                      ),
                    ],
                  ),
                ),
                
                UiSpacer.verticalSpace(space: 16),
                
                // Work location
                _buildMenuCard(
                  icon: Icons.work_outline,
                  title: "Work",
                  subtitle: _workAddress,
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await Navigator.of(ctx).pushNamed(AppRoutes.workLocationRoute);
                    if (result == true) {
                      // Refresh addresses if work location was updated
                      _loadSavedAddresses();
                    }
                  },
                ),
                
                // Add New Location button
                UiSpacer.verticalSpace(space: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.primaryColor),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColor.primaryColor, size: 20),
                      UiSpacer.horizontalSpace(space: 8),
                      "Add New Location".tr().text.color(AppColor.primaryColor).make(),
                    ],
                  ),
                ).onTap(() {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed(AppRoutes.homeLocationRoute);
                }),
                
                UiSpacer.verticalSpace(space: 20),
                
                // Ride History
                _buildMenuCard(
                  icon: Icons.history,
                  title: "Ride History",
                  subtitle: "View your past rides and deliveries",
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(ctx).pushNamed(AppRoutes.rideHistoryRoute);
                  },
                ),
                
                // Payment Methods
                _buildMenuCard(
                  icon: Icons.payment,
                  title: "Payment Methods",
                  subtitle: "Manage your payment options",
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(ctx).pushNamed(AppRoutes.paymentMethodsRoute);
                  },
                ),
                
                // Support
                _buildMenuCard(
                  icon: Icons.support_agent,
                  title: "Support",
                  subtitle: "Get help with your account",
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pushNamed(AppRoutes.helpSupportRoute);
                  },
                ),
                
                // Settings
                _buildMenuCard(
                  icon: Icons.settings,
                  title: "Settings",
                  subtitle: "Customize your app experience",
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pushNamed(AppRoutes.settingsRoute);
                  },
                ),
                
                UiSpacer.verticalSpace(space: 20),
                
                // Sign Out
                Container(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await AuthServices.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.loginRoute,
                        (r) => false,
                      );
                    },
                    icon: Icon(Icons.logout, color: Colors.red),
                    label: "Sign Out".tr().text.color(Colors.red).make(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                UiSpacer.verticalSpace(space: 20),
                // Add extra bottom padding to prevent overflow
                UiSpacer.verticalSpace(space: 20),
              ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColor.primaryColor,
            size: 20,
          ),
        ),
        title: title.text.bold.make(),
        subtitle: subtitle.text.gray600.sm.make(),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
    }
  
  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColor.primaryColor,
              size: 20,
            ),
          ),
          UiSpacer.horizontalSpace(space: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label.text.gray600.sm.make(),
                value.text.bold.make(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: VStack([
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: AppColor.primaryColor,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ).centered(),
              UiSpacer.verticalSpace(space: 8),
              Flexible(
                child: title.text.bold.sm.maxLines(2).make().centered(),
              ),
              if (subtitle.isNotEmpty) ...[
                UiSpacer.verticalSpace(space: 2),
                Flexible(
                  child: subtitle.text.gray500.xs.maxLines(2).make().centered(),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
  
  void _showAddNewLocationModal(BuildContext context) {
    final addressController = TextEditingController();
    final nameController = TextEditingController();
    
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
                      "Add New Location".tr().text.bold.xl.make(),
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
                    
                    // Location Name Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Location Name".tr(),
                          hintText: "e.g., Home, Work, Gym",
                          prefixIcon: Icon(Icons.label, color: AppColor.primaryColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    
                    UiSpacer.verticalSpace(space: 16),
                    
                    // Address Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: "Enter Address".tr(),
                          hintText: "123 Main Street, City",
                          prefixIcon: Icon(Icons.location_on, color: AppColor.primaryColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        maxLines: 3,
                      ),
                    ),
                    
                    UiSpacer.verticalSpace(space: 20),
                    
                    // Save Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a location name'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          if (addressController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter an address'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Location "${nameController.text}" saved successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: "Save Location".tr().text.white.bold.make(),
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
  
  void _showFlightsComingSoonModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Draggable handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Airplane icon
              Icon(
                Icons.flight,
                size: 60,
                color: AppColor.primaryColor,
              ),
              
              SizedBox(height: 16),
              
              // Title
              "Flights Coming Soon!".text.bold.xl2.color(AppColor.primaryColor).make(),
              
              SizedBox(height: 12),
              
              // Description
              "We're working hard to bring you the best flight booking experience. Stay tuned for updates!".text.gray600.lg.make().centered(),
              
              SizedBox(height: 32),
              
              // Feature highlights
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureHighlight(Icons.search, "Easy Search"),
                  _buildFeatureHighlight(Icons.local_offer, "Best Prices"),
                  _buildFeatureHighlight(Icons.headset_mic, "24/7 Support"),
                ],
              ),
              
              SizedBox(height: 32),
              
              // Got it button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColor.primaryColor,
                    side: BorderSide(color: AppColor.primaryColor, width: 2),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: "Got it".text.bold.make(),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFeatureHighlight(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColor.primaryColor,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        text.text.gray600.sm.make(),
      ],
    );
  }

  Widget _buildAdsSection() {
    // TODO: Replace with dynamic ads from admin
    // For now, return empty container when no ads
    final hasAds = false; // This should be fetched from API
    
    if (!hasAds) {
      return SizedBox.shrink(); // Hide section when no ads
    }
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: VStack([
        "Special Offers".tr().text.bold.lg.make().centered(),
        UiSpacer.verticalSpace(space: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade300, Colors.orange.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: HStack([
              Icon(Icons.local_offer, color: Colors.white, size: 30),
              UiSpacer.horizontalSpace(space: 12),
              "Get 20% off on your first ride!".tr().text.white.bold.make(),
            ]),
          ),
        ),
      ]),
    ).py16();
  }
}

