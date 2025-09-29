import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/utils/ui_spacer.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/location_preferences.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WorkLocationPage extends StatefulWidget {
  const WorkLocationPage({super.key});

  @override
  _WorkLocationPageState createState() => _WorkLocationPageState();
}

class _WorkLocationPageState extends State<WorkLocationPage> {
  final TextEditingController _workAddressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _currentWorkAddress;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentWorkAddress();
  }

  @override
  void dispose() {
    _workAddressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadCurrentWorkAddress() async {
    final address = await LocationPreferencesService().getFormattedWorkAddress();
    setState(() {
      _currentWorkAddress = address;
    });
  }

  void _saveWorkAddress() async {
    if (_workAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Please enter a work address".text.white.make(),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save to local storage
      final success = await LocationPreferencesService().setWorkAddress(_workAddressController.text.trim());
      
      if (success) {
        setState(() {
          _currentWorkAddress = _workAddressController.text.trim();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to save address');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Work address saved successfully!".text.white.make(),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Failed to save work address".text.white.make(),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _searchLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // TODO: Implement real location search API
    // For now, show sample results
    setState(() {
      _searchResults = [
        {
          'name': 'Kampala Industrial Park',
          'address': 'Kampala, Uganda',
          'type': 'Industrial Area',
        },
        {
          'name': 'Nakawa Business Park',
          'address': 'Nakawa, Kampala, Uganda',
          'type': 'Business District',
        },
        {
          'name': 'Kololo Airstrip',
          'address': 'Kololo, Kampala, Uganda',
          'type': 'Office Complex',
        },
        {
          'name': 'Garden City Mall',
          'address': 'Garden City, Kampala, Uganda',
          'type': 'Shopping Center',
        },
      ].where((location) => 
        location['name']?.toString().toLowerCase().contains(query.toLowerCase()) == true ||
        location['address']?.toString().toLowerCase().contains(query.toLowerCase()) == true
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: 'Work Location'.tr(),
      appBarColor: AppColor.primaryColor,
      appBarItemColor: Colors.white,
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: VStack([
            // Current Work Address Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                HStack([
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      color: AppColor.primaryColor,
                      size: 24,
                    ),
                  ),
                  UiSpacer.horizontalSpace(space: 16),
                  Expanded(
                    child: VStack([
                      "Current Work Address".text.bold.xl.make(),
                      UiSpacer.verticalSpace(space: 4),
                      (_currentWorkAddress ?? "Not set").text.gray600.make(),
                    ]),
                  ),
                ]),
              ]),
            ),

            UiSpacer.verticalSpace(space: 24),

            // Set New Work Address Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                "Set New Work Address".text.bold.xl.make(),
                UiSpacer.verticalSpace(space: 16),

                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchLocations,
                    decoration: InputDecoration(
                      hintText: "Search for your work location...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                UiSpacer.verticalSpace(space: 16),

                // Manual Address Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _workAddressController,
                    decoration: InputDecoration(
                      hintText: "Or enter address manually...",
                      prefixIcon: Icon(Icons.location_on, color: Colors.grey.shade600),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                UiSpacer.verticalSpace(space: 20),

                // Save Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveWorkAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : "Save Work Address".text.white.bold.make(),
                  ),
                ),
              ]),
            ),

            UiSpacer.verticalSpace(space: 16),

            // Search Results
            if (_searchResults.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                  "Suggested Locations".text.bold.lg.make(),
                  UiSpacer.verticalSpace(space: 16),
                  ...(_searchResults.map((location) => _buildLocationItem(location))),
                ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> location) {
    return GestureDetector(
      onTap: () {
        _workAddressController.text = "${location['name'] ?? ''}, ${location['address'] ?? ''}";
        _searchController.clear();
        setState(() {
          _searchResults = [];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: HStack([
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.location_on,
              color: AppColor.primaryColor,
              size: 20,
            ),
          ),
          UiSpacer.horizontalSpace(space: 12),
          Expanded(
            child: VStack([
              (location['name'] ?? '').toString().text.bold.make(),
              UiSpacer.verticalSpace(space: 4),
              (location['address'] ?? '').toString().text.gray600.sm.make(),
              UiSpacer.verticalSpace(space: 2),
              (location['type'] ?? '').toString().text.gray500.xs.make(),
            ]),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ]),
      ),
    );
  }
}
