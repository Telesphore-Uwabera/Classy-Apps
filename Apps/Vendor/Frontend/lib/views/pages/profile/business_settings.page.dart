import 'package:flutter/material.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({Key? key}) : super(key: key);

  @override
  _BusinessSettingsPageState createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final TextEditingController _businessNameController = TextEditingController(text: "Yiiliba Foods");
  final TextEditingController _descriptionController = TextEditingController(text: "We deal in yummy foods");
  final TextEditingController _phoneController = TextEditingController(text: "0709965848");

  final TextEditingController _addressController = TextEditingController(text: "Kampala");
  final TextEditingController _openTimeController = TextEditingController(text: "8:00 AM");
  final TextEditingController _closeTimeController = TextEditingController(text: "6:00 PM");
  
  List<bool> _workingDays = [true, true, true, true, true, false, false]; // Mon-Sun
  List<String> _selectedCategories = ["Pizza", "Bakery", "Ice Cream", "Meat"];
  List<String> _allCategories = [
    "Pizza", "Bakery", "Ice Cream", "Meat", "Burgers", "Drinks", 
    "Snacks", "Groceries", "Fruits", "Vegetables", "Seafood", 
    "Breakfast", "Coffee", "Desserts", "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: "Business Settings",
      body: SafeArea(
        child: VStack([
          // Header Image
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/images/placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Business Information Form
          VStack([
            _buildInputField("Business Name", _businessNameController, Icons.store),
            _buildInputField("Description", _descriptionController, Icons.info),
            _buildInputField("Phone Number", _phoneController, Icons.phone),
            
            _buildInputField("Address", _addressController, Icons.location_on),
            
            // Working Hours
            "Working Hours".text.lg.bold.make().py12(),
            HStack([
              Expanded(child: _buildInputField("", _openTimeController, Icons.access_time)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField("", _closeTimeController, Icons.access_time)),
            ]),
            
            // Working Days
            "Working Days".text.lg.bold.make().py12(),
            HStack([
              _buildDayButton("Mon", 0),
              _buildDayButton("Tue", 1),
              _buildDayButton("Wed", 2),
              _buildDayButton("Thu", 3),
              _buildDayButton("Fri", 4),
              _buildDayButton("Sat", 5),
              _buildDayButton("Sun", 6),
            ], spacing: 8),
            
            // Categories
            "Categories".text.lg.bold.make().py12(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allCategories.map((category) {
                bool isSelected = _selectedCategories.contains(category);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategories.remove(category);
                      } else {
                        _selectedCategories.add(category);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE91E63) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ]).px20(),

          const SizedBox(height: 40),
          
          // Save Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Save business settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Business settings saved!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: HStack([
                const Icon(Icons.save, color: Colors.white, size: 20),
                "Save".text.white.xl.bold.make(),
              ]),
            ),
          ),
        ]).scrollVertical(),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label.text.lg.bold.make().py8(),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFFE91E63)),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayButton(String day, int index) {
    bool isSelected = _workingDays[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          _workingDays[index] = !_workingDays[index];
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
