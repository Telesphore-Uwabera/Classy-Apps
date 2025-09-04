import 'package:flutter/material.dart';
import 'package:fuodz/services/country.service.dart';

class CountryPickerWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onCountrySelected;
  final String? initialCountryCode;

  const CountryPickerWidget({
    Key? key,
    required this.onCountrySelected,
    this.initialCountryCode,
  }) : super(key: key);

  @override
  State<CountryPickerWidget> createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  late Map<String, dynamic> selectedCountry;
  List<Map<String, dynamic>> filteredCountries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial country
    if (widget.initialCountryCode != null) {
      selectedCountry = CountryService.getCountryByCode(widget.initialCountryCode!);
    } else {
      selectedCountry = CountryService.getAllCountries().first; // Uganda by default
    }
    filteredCountries = CountryService.getAllCountries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      filteredCountries = CountryService.searchCountries(query);
    });
  }

  void _selectCountry(Map<String, dynamic> country) {
    setState(() {
      selectedCountry = country;
    });
    widget.onCountrySelected(country);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive mobile design - adapts to actual screen size
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    return Container(
      width: screenWidth * 0.32, // 32% of screen width
      height: screenWidth * 0.13, // 13% of screen width (maintains aspect ratio)
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: 150,
        minHeight: 40,
        maxHeight: 60,
      ),
      child: InkWell(
        onTap: () => _showCountryPicker(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.015, // 1.5% of screen width
            vertical: screenWidth * 0.01, // 1% of screen width
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedCountry['flag'],
                style: TextStyle(fontSize: screenWidth * 0.045), // 4.5% of screen width
              ),
              SizedBox(width: screenWidth * 0.008), // 0.8% of screen width
              Flexible(
                child: Text(
                  selectedCountry['phoneCode'],
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.028, // 2.8% of screen width
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
                size: screenWidth * 0.04, // 4% of screen width
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Select Country',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCountries,
                decoration: InputDecoration(
                  hintText: 'Search countries...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            
            // Countries List
            Expanded(
              child: ListView.builder(
                itemCount: filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = filteredCountries[index];
                  final isSelected = country['code'] == selectedCountry['code'];
                  
                  return ListTile(
                    leading: Text(
                      country['flag'],
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country['name'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Color(0xFFE91E63) : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      country['phoneCode'],
                      style: TextStyle(
                        color: isSelected ? Color(0xFFE91E63) : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Color(0xFFE91E63),
                            size: 24,
                          )
                        : null,
                    onTap: () => _selectCountry(country),
                    tileColor: isSelected ? Color(0xFFE91E63).withValues(alpha: 0.1) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
