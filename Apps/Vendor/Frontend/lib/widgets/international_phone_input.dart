import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:velocity_x/velocity_x.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class InternationalPhoneInput extends StatefulWidget {
  final String? initialCountryCode;
  final String? initialPhoneNumber;
  final Function(String) onChanged;
  final Function(String?)? onValidate;
  final String? hintText;
  final bool enabled;
  final TextEditingController? controller;

  const InternationalPhoneInput({
    Key? key,
    this.initialCountryCode = 'UG',
    this.initialPhoneNumber,
    required this.onChanged,
    this.onValidate,
    this.hintText = 'Phone Number',
    this.enabled = true,
    this.controller,
  }) : super(key: key);

  @override
  State<InternationalPhoneInput> createState() => _InternationalPhoneInputState();
}

class _InternationalPhoneInputState extends State<InternationalPhoneInput> {
  late TextEditingController _controller;
  String completePhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialPhoneNumber != null) {
      _controller.text = widget.initialPhoneNumber!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntlPhoneField(
        controller: _controller,
        enabled: widget.enabled,
        initialCountryCode: widget.initialCountryCode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyle.h4TitleTextStyle(
            color: Colors.grey[500],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          counterText: '', // Remove character counter
        ),
        style: AppTextStyle.h4TitleTextStyle(
          color: AppColor.primaryColor,
        ),
        dropdownTextStyle: AppTextStyle.h4TitleTextStyle(
          color: AppColor.primaryColor,
        ),
        flagsButtonPadding: const EdgeInsets.only(left: 16),
        dropdownIconPosition: IconPosition.trailing,
        dropdownIcon: Icon(
          Icons.arrow_drop_down,
          color: AppColor.primaryColor,
        ),
        keyboardType: TextInputType.phone,
        onChanged: (phone) {
          completePhoneNumber = phone.completeNumber;
          widget.onChanged(completePhoneNumber);
        },
        validator: (phone) {
          if (widget.onValidate != null) {
            return widget.onValidate!(phone?.completeNumber);
          }
          
          if (phone == null || phone.completeNumber.isEmpty) {
            return 'Phone number is required';
          }
          
          // Basic validation for international numbers
          if (phone.completeNumber.length < 10) {
            return 'Please enter a valid phone number';
          }
          
          return null;
        },
        countries: const [
          // Popular countries first
          'UG', 'KE', 'TZ', 'RW', 'NG', 'GH', 'ZA', 'US', 'GB', 'CA',
          // Then all others alphabetically
          'AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'AO', 'AQ', 'AR', 'AS', 'AT',
          'AU', 'AW', 'AX', 'AZ', 'BA', 'BB', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI',
          'BJ', 'BL', 'BM', 'BN', 'BO', 'BQ', 'BR', 'BS', 'BT', 'BV', 'BW', 'BY',
          'BZ', 'CC', 'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN', 'CO',
          'CR', 'CU', 'CV', 'CW', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM', 'DO',
          'DZ', 'EC', 'EE', 'EG', 'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FK', 'FM',
          'FO', 'FR', 'GA', 'GD', 'GE', 'GF', 'GG', 'GI', 'GL', 'GM', 'GN', 'GP',
          'GQ', 'GR', 'GS', 'GT', 'GU', 'GW', 'GY', 'HK', 'HM', 'HN', 'HR', 'HT',
          'HU', 'ID', 'IE', 'IL', 'IM', 'IN', 'IO', 'IQ', 'IR', 'IS', 'IT', 'JE',
          'JM', 'JO', 'JP', 'KG', 'KH', 'KI', 'KM', 'KN', 'KP', 'KR', 'KW', 'KY',
          'KZ', 'LA', 'LB', 'LC', 'LI', 'LK', 'LR', 'LS', 'LT', 'LU', 'LV', 'LY',
          'MA', 'MC', 'MD', 'ME', 'MF', 'MG', 'MH', 'MK', 'ML', 'MM', 'MN', 'MO',
          'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW', 'MX', 'MY', 'MZ', 'NA',
          'NC', 'NE', 'NF', 'NI', 'NL', 'NO', 'NP', 'NR', 'NU', 'NZ', 'OM', 'PA',
          'PE', 'PF', 'PG', 'PH', 'PK', 'PL', 'PM', 'PN', 'PR', 'PS', 'PT', 'PW',
          'PY', 'QA', 'RE', 'RO', 'RS', 'RU', 'SA', 'SB', 'SC', 'SD', 'SE', 'SG',
          'SH', 'SI', 'SJ', 'SK', 'SL', 'SM', 'SN', 'SO', 'SR', 'SS', 'ST', 'SV',
          'SX', 'SY', 'SZ', 'TC', 'TD', 'TF', 'TG', 'TH', 'TJ', 'TK', 'TL', 'TM',
          'TN', 'TO', 'TR', 'TT', 'TV', 'TW', 'UA', 'UM', 'US', 'UY', 'UZ', 'VA',
          'VC', 'VE', 'VG', 'VI', 'VN', 'VU', 'WF', 'WS', 'YE', 'YT', 'ZM', 'ZW',
        ],
        showCountryFlag: true,
        showDropdownIcon: true,
        searchText: 'Search country',
      ),
    );
  }
}

/// Phone validation service for international numbers
class PhoneValidationService {
  /// Validate international phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;
    
    // Remove all non-digit and non-plus characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Must start with + and have at least 10 digits
    if (!cleaned.startsWith('+') || cleaned.length < 10) {
      return false;
    }
    
    // Must not exceed 15 digits (international standard)
    if (cleaned.length > 16) { // +15 digits max
      return false;
    }
    
    return true;
  }

  /// Format phone number for API calls
  static String formatPhoneForAPI(String phoneNumber) {
    // Remove all non-digit and non-plus characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it starts with +
    if (!cleaned.startsWith('+')) {
      // If it doesn't start with +, assume it's a local number and add Uganda code
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1); // Remove leading 0
      }
      cleaned = '+256$cleaned';
    }
    
    return cleaned;
  }

  /// Get country code from phone number
  static String? getCountryCode(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) return null;
    
    // Common country codes
    Map<String, String> countryCodes = {
      '+256': 'UG', // Uganda
      '+254': 'KE', // Kenya
      '+255': 'TZ', // Tanzania
      '+250': 'RW', // Rwanda
      '+234': 'NG', // Nigeria
      '+233': 'GH', // Ghana
      '+27': 'ZA',  // South Africa
      '+1': 'US',   // United States/Canada
      '+44': 'GB',  // United Kingdom
      '+33': 'FR',  // France
      '+49': 'DE',  // Germany
    };
    
    for (String code in countryCodes.keys) {
      if (phoneNumber.startsWith(code)) {
        return countryCodes[code];
      }
    }
    
    return null;
  }

  /// Extract local number from international format
  static String getLocalNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) return phoneNumber;
    
    // Remove country code for Uganda numbers
    if (phoneNumber.startsWith('+256')) {
      return '0${phoneNumber.substring(4)}';
    }
    
    // For other countries, return without + and country code
    return phoneNumber.substring(1);
  }

  /// Validate Uganda phone number specifically
  static bool isValidUgandaNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check if it's Uganda format
    if (cleaned.startsWith('+256')) {
      String localPart = cleaned.substring(4);
      // Uganda mobile numbers start with 7 or 3 and are 9 digits total
      return localPart.length == 9 && (localPart.startsWith('7') || localPart.startsWith('3'));
    }
    
    // Check local format (0XXXXXXXXX)
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      String localPart = cleaned.substring(1);
      return localPart.startsWith('7') || localPart.startsWith('3');
    }
    
    return false;
  }

  /// Get display format for phone number
  static String getDisplayFormat(String phoneNumber) {
    if (phoneNumber.startsWith('+256')) {
      // Format Uganda numbers as: +256 7XX XXX XXX
      String localPart = phoneNumber.substring(4);
      if (localPart.length >= 9) {
        return '+256 ${localPart.substring(0, 3)} ${localPart.substring(3, 6)} ${localPart.substring(6)}';
      }
    }
    
    return phoneNumber;
  }
}
