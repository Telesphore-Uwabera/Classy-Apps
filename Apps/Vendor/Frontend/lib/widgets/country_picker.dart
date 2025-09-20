import 'package:flutter/material.dart';
import 'models/country.dart';

class CountryPicker extends StatefulWidget {
  final Country selectedCountry;
  final Function(Country) onCountryChanged;
  final bool showFlag;
  final bool showName;
  final bool showPhoneCode;

  const CountryPicker({
    Key? key,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.showFlag = true,
    this.showName = true,
    this.showPhoneCode = true,
  }) : super(key: key);

  @override
  _CountryPickerState createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showFlag) ...[
              _buildFlag(widget.selectedCountry),
              const SizedBox(width: 8),
            ],
            if (widget.showPhoneCode)
              Text(
                widget.selectedCountry.phoneCode,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            if (widget.showName && widget.showPhoneCode) ...[
              const SizedBox(width: 8),
              Text(
                "(${widget.selectedCountry.name})",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag(Country country) {
    // Use real country flag emojis for authentic representation
    return Text(
      country.flagEmoji,
      style: const TextStyle(fontSize: 20),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFFE91E63)),
                  const SizedBox(width: 12),
                  Text(
                    "Select Country",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search countries...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE91E63)),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
            
            // Countries list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: Country.countries.length,
                itemBuilder: (context, index) {
                  final country = Country.countries[index];
                  final isSelected = country.phoneCode == widget.selectedCountry.phoneCode;
                  
                  return ListTile(
                    leading: _buildFlag(country),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFE91E63) : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      "${country.phoneCode} • ${country.currency} (${country.currencySymbol})",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: const Color(0xFFE91E63),
                          )
                        : null,
                    onTap: () {
                      widget.onCountryChanged(country);
                      Navigator.pop(context);
                    },
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
