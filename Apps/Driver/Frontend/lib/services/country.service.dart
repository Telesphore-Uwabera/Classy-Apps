import 'package:flutter/material.dart';

class CountryService {
  static const List<Map<String, dynamic>> countries = [
    {
      'name': 'Uganda',
      'code': 'UG',
      'phoneCode': '+256',
      'flag': '🇺🇬',
      'phoneFormat': '### ### ###',
    },
    {
      'name': 'Kenya',
      'code': 'KE',
      'phoneCode': '+254',
      'flag': '🇰🇪',
      'phoneFormat': '### ### ###',
    },
    {
      'name': 'Tanzania',
      'code': 'TZ',
      'phoneCode': '+255',
      'flag': '🇹🇿',
      'phoneFormat': '### ### ###',
    },
    {
      'name': 'Nigeria',
      'code': 'NG',
      'phoneCode': '+234',
      'flag': '🇳🇬',
      'phoneFormat': '### ### ####',
    },
    {
      'name': 'Ghana',
      'code': 'GH',
      'phoneCode': '+233',
      'flag': '🇬🇭',
      'phoneFormat': '### ### ###',
    },
    {
      'name': 'South Africa',
      'code': 'ZA',
      'phoneCode': '+27',
      'flag': '🇿🇦',
      'phoneFormat': '## ### ####',
    },
    {
      'name': 'Ethiopia',
      'code': 'ET',
      'phoneCode': '+251',
      'flag': '🇪🇹',
      'phoneFormat': '## ### ####',
    },
    {
      'name': 'Egypt',
      'code': 'EG',
      'phoneCode': '+20',
      'flag': '🇪🇬',
      'phoneFormat': '## ### ####',
    },
    {
      'name': 'Morocco',
      'code': 'MA',
      'phoneCode': '+212',
      'flag': '🇲🇦',
      'phoneFormat': '## ### ####',
    },
    {
      'name': 'Algeria',
      'code': 'DZ',
      'phoneCode': '+213',
      'flag': '🇩🇿',
      'phoneFormat': '## ### ####',
    },
    {
      'name': 'United States',
      'code': 'US',
      'phoneCode': '+1',
      'flag': '🇺🇸',
      'phoneFormat': '### ### ####',
    },
    {
      'name': 'United Kingdom',
      'code': 'GB',
      'phoneCode': '+44',
      'flag': '🇬🇧',
      'phoneFormat': '#### ######',
    },
    {
      'name': 'Germany',
      'code': 'DE',
      'phoneCode': '+49',
      'flag': '🇩🇪',
      'phoneFormat': '### #######',
    },
    {
      'name': 'France',
      'code': 'FR',
      'phoneCode': '+33',
      'flag': '🇫🇷',
      'phoneFormat': '# ## ## ## ##',
    },
    {
      'name': 'India',
      'code': 'IN',
      'phoneCode': '+91',
      'flag': '🇮🇳',
      'phoneFormat': '##### #####',
    },
    {
      'name': 'China',
      'code': 'CN',
      'phoneCode': '+86',
      'flag': '🇨🇳',
      'phoneFormat': '### #### ####',
    },
    {
      'name': 'Japan',
      'code': 'JP',
      'phoneCode': '+81',
      'flag': '🇯🇵',
      'phoneFormat': '## #### ####',
    },
    {
      'name': 'South Korea',
      'code': 'KR',
      'phoneCode': '+82',
      'flag': '🇰🇷',
      'phoneFormat': '## #### ####',
    },
    {
      'name': 'Australia',
      'code': 'AU',
      'phoneCode': '+61',
      'flag': '🇦🇺',
      'phoneFormat': '### ### ###',
    },
    {
      'name': 'Canada',
      'code': 'CA',
      'phoneCode': '+1',
      'flag': '🇨🇦',
      'phoneFormat': '### ### ####',
    },
  ];

  static Map<String, dynamic> getCountryByCode(String countryCode) {
    return countries.firstWhere(
      (country) => country['code'] == countryCode,
      orElse: () => countries.first, // Default to first country (Uganda)
    );
  }

  static Map<String, dynamic> getCountryByPhoneCode(String phoneCode) {
    return countries.firstWhere(
      (country) => country['phoneCode'] == phoneCode,
      orElse: () => countries.first, // Default to first country (Uganda)
    );
  }

  static List<Map<String, dynamic>> getAllCountries() {
    return countries;
  }

  static List<Map<String, dynamic>> searchCountries(String query) {
    if (query.isEmpty) return countries;
    
    return countries.where((country) {
      final name = country['name'].toString().toLowerCase();
      final code = country['code'].toString().toLowerCase();
      final phoneCode = country['phoneCode'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      
      return name.contains(searchQuery) || 
             code.contains(searchQuery) || 
             phoneCode.contains(searchQuery);
    }).toList();
  }
}
