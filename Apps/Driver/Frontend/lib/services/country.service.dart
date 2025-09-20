import 'package:flutter/material.dart';

class CountryService {
  static const List<Map<String, dynamic>> countries = [
    // Africa
    {'name': 'Uganda', 'code': 'UG', 'phoneCode': '+256', 'flag': '🇺🇬', 'phoneFormat': '### ### ###'},
    {'name': 'Kenya', 'code': 'KE', 'phoneCode': '+254', 'flag': '🇰🇪', 'phoneFormat': '### ### ###'},
    {'name': 'Tanzania', 'code': 'TZ', 'phoneCode': '+255', 'flag': '🇹🇿', 'phoneFormat': '### ### ###'},
    {'name': 'Nigeria', 'code': 'NG', 'phoneCode': '+234', 'flag': '🇳🇬', 'phoneFormat': '### ### ####'},
    {'name': 'Ghana', 'code': 'GH', 'phoneCode': '+233', 'flag': '🇬🇭', 'phoneFormat': '### ### ###'},
    {'name': 'South Africa', 'code': 'ZA', 'phoneCode': '+27', 'flag': '🇿🇦', 'phoneFormat': '## ### ####'},
    {'name': 'Ethiopia', 'code': 'ET', 'phoneCode': '+251', 'flag': '🇪🇹', 'phoneFormat': '## ### ####'},
    {'name': 'Egypt', 'code': 'EG', 'phoneCode': '+20', 'flag': '🇪🇬', 'phoneFormat': '## ### ####'},
    {'name': 'Morocco', 'code': 'MA', 'phoneCode': '+212', 'flag': '🇲🇦', 'phoneFormat': '## ### ####'},
    {'name': 'Algeria', 'code': 'DZ', 'phoneCode': '+213', 'flag': '🇩🇿', 'phoneFormat': '## ### ####'},
    {'name': 'Rwanda', 'code': 'RW', 'phoneCode': '+250', 'flag': '🇷🇼', 'phoneFormat': '### ### ###'},
    {'name': 'Burundi', 'code': 'BI', 'phoneCode': '+257', 'flag': '🇧🇮', 'phoneFormat': '## ### ###'},
    {'name': 'Tunisia', 'code': 'TN', 'phoneCode': '+216', 'flag': '🇹🇳', 'phoneFormat': '## ### ###'},
    {'name': 'Libya', 'code': 'LY', 'phoneCode': '+218', 'flag': '🇱🇾', 'phoneFormat': '## ### ###'},
    {'name': 'Sudan', 'code': 'SD', 'phoneCode': '+249', 'flag': '🇸🇩', 'phoneFormat': '## ### ####'},
    {'name': 'South Sudan', 'code': 'SS', 'phoneCode': '+211', 'flag': '🇸🇸', 'phoneFormat': '## ### ####'},
    {'name': 'Chad', 'code': 'TD', 'phoneCode': '+235', 'flag': '🇹🇩', 'phoneFormat': '## ## ## ##'},
    {'name': 'Niger', 'code': 'NE', 'phoneCode': '+227', 'flag': '🇳🇪', 'phoneFormat': '## ## ## ##'},
    {'name': 'Mali', 'code': 'ML', 'phoneCode': '+223', 'flag': '🇲🇱', 'phoneFormat': '## ## ## ##'},
    {'name': 'Burkina Faso', 'code': 'BF', 'phoneCode': '+226', 'flag': '🇧🇫', 'phoneFormat': '## ## ## ##'},
    {'name': 'Senegal', 'code': 'SN', 'phoneCode': '+221', 'flag': '🇸🇳', 'phoneFormat': '## ### ## ##'},
    {'name': 'Guinea', 'code': 'GN', 'phoneCode': '+224', 'flag': '🇬🇳', 'phoneFormat': '## ## ## ##'},
    {'name': 'Sierra Leone', 'code': 'SL', 'phoneCode': '+232', 'flag': '🇸🇱', 'phoneFormat': '## ### ###'},
    {'name': 'Liberia', 'code': 'LR', 'phoneCode': '+231', 'flag': '🇱🇷', 'phoneFormat': '## ### ####'},
    {'name': 'Ivory Coast', 'code': 'CI', 'phoneCode': '+225', 'flag': '🇨🇮', 'phoneFormat': '## ## ## ##'},
    {'name': 'Togo', 'code': 'TG', 'phoneCode': '+228', 'flag': '🇹🇬', 'phoneFormat': '## ## ## ##'},
    {'name': 'Benin', 'code': 'BJ', 'phoneCode': '+229', 'flag': '🇧🇯', 'phoneFormat': '## ## ## ##'},
    {'name': 'Cameroon', 'code': 'CM', 'phoneCode': '+237', 'flag': '🇨🇲', 'phoneFormat': '## ## ## ##'},
    {'name': 'Central African Republic', 'code': 'CF', 'phoneCode': '+236', 'flag': '🇨🇫', 'phoneFormat': '## ## ## ##'},
    {'name': 'Equatorial Guinea', 'code': 'GQ', 'phoneCode': '+240', 'flag': '🇬🇶', 'phoneFormat': '## ### ###'},
    {'name': 'Gabon', 'code': 'GA', 'phoneCode': '+241', 'flag': '🇬🇦', 'phoneFormat': '## ## ## ##'},
    {'name': 'Republic of the Congo', 'code': 'CG', 'phoneCode': '+242', 'flag': '🇨🇬', 'phoneFormat': '## ### ####'},
    {'name': 'Democratic Republic of the Congo', 'code': 'CD', 'phoneCode': '+243', 'flag': '🇨🇩', 'phoneFormat': '## ### ####'},
    {'name': 'Angola', 'code': 'AO', 'phoneCode': '+244', 'flag': '🇦🇴', 'phoneFormat': '## ### ####'},
    {'name': 'Zambia', 'code': 'ZM', 'phoneCode': '+260', 'flag': '🇿🇲', 'phoneFormat': '## ### ####'},
    {'name': 'Zimbabwe', 'code': 'ZW', 'phoneCode': '+263', 'flag': '🇿🇼', 'phoneFormat': '## ### ####'},
    {'name': 'Botswana', 'code': 'BW', 'phoneCode': '+267', 'flag': '🇧🇼', 'phoneFormat': '## ### ###'},
    {'name': 'Namibia', 'code': 'NA', 'phoneCode': '+264', 'flag': '🇳🇦', 'phoneFormat': '## ### ####'},
    {'name': 'Lesotho', 'code': 'LS', 'phoneCode': '+266', 'flag': '🇱🇸', 'phoneFormat': '## ### ####'},
    {'name': 'Swaziland', 'code': 'SZ', 'phoneCode': '+268', 'flag': '🇸🇿', 'phoneFormat': '## ### ####'},
    {'name': 'Madagascar', 'code': 'MG', 'phoneCode': '+261', 'flag': '🇲🇬', 'phoneFormat': '## ## ### ##'},
    {'name': 'Mauritius', 'code': 'MU', 'phoneCode': '+230', 'flag': '🇲🇺', 'phoneFormat': '### ####'},
    {'name': 'Seychelles', 'code': 'SC', 'phoneCode': '+248', 'flag': '🇸🇨', 'phoneFormat': '## ## ##'},
    {'name': 'Comoros', 'code': 'KM', 'phoneCode': '+269', 'flag': '🇰🇲', 'phoneFormat': '## ## ##'},
    {'name': 'Djibouti', 'code': 'DJ', 'phoneCode': '+253', 'flag': '🇩🇯', 'phoneFormat': '## ## ## ##'},
    {'name': 'Somalia', 'code': 'SO', 'phoneCode': '+252', 'flag': '🇸🇴', 'phoneFormat': '## ### ###'},
    {'name': 'Eritrea', 'code': 'ER', 'phoneCode': '+291', 'flag': '🇪🇷', 'phoneFormat': '## ### ###'},
    {'name': 'Malawi', 'code': 'MW', 'phoneCode': '+265', 'flag': '🇲🇼', 'phoneFormat': '## ### ####'},
    {'name': 'Mozambique', 'code': 'MZ', 'phoneCode': '+258', 'flag': '🇲🇿', 'phoneFormat': '## ### ####'},
    {'name': 'Cape Verde', 'code': 'CV', 'phoneCode': '+238', 'flag': '🇨🇻', 'phoneFormat': '### ####'},
    {'name': 'São Tomé and Príncipe', 'code': 'ST', 'phoneCode': '+239', 'flag': '🇸🇹', 'phoneFormat': '## ### ###'},
    {'name': 'Guinea-Bissau', 'code': 'GW', 'phoneCode': '+245', 'flag': '🇬🇼', 'phoneFormat': '## ### ###'},
    {'name': 'Gambia', 'code': 'GM', 'phoneCode': '+220', 'flag': '🇬🇲', 'phoneFormat': '### ####'},
    {'name': 'Mauritania', 'code': 'MR', 'phoneCode': '+222', 'flag': '🇲🇷', 'phoneFormat': '## ## ## ##'},

    // North America
    {'name': 'United States', 'code': 'US', 'phoneCode': '+1', 'flag': '🇺🇸', 'phoneFormat': '### ### ####'},
    {'name': 'Canada', 'code': 'CA', 'phoneCode': '+1', 'flag': '🇨🇦', 'phoneFormat': '### ### ####'},
    {'name': 'Mexico', 'code': 'MX', 'phoneCode': '+52', 'flag': '🇲🇽', 'phoneFormat': '## #### ####'},
    {'name': 'Guatemala', 'code': 'GT', 'phoneCode': '+502', 'flag': '🇬🇹', 'phoneFormat': '#### ####'},
    {'name': 'Belize', 'code': 'BZ', 'phoneCode': '+501', 'flag': '🇧🇿', 'phoneFormat': '### ####'},
    {'name': 'El Salvador', 'code': 'SV', 'phoneCode': '+503', 'flag': '🇸🇻', 'phoneFormat': '#### ####'},
    {'name': 'Honduras', 'code': 'HN', 'phoneCode': '+504', 'flag': '🇭🇳', 'phoneFormat': '#### ####'},
    {'name': 'Nicaragua', 'code': 'NI', 'phoneCode': '+505', 'flag': '🇳🇮', 'phoneFormat': '#### ####'},
    {'name': 'Costa Rica', 'code': 'CR', 'phoneCode': '+506', 'flag': '🇨🇷', 'phoneFormat': '#### ####'},
    {'name': 'Panama', 'code': 'PA', 'phoneCode': '+507', 'flag': '🇵🇦', 'phoneFormat': '#### ####'},

    // South America
    {'name': 'Brazil', 'code': 'BR', 'phoneCode': '+55', 'flag': '🇧🇷', 'phoneFormat': '## ##### ####'},
    {'name': 'Argentina', 'code': 'AR', 'phoneCode': '+54', 'flag': '🇦🇷', 'phoneFormat': '## #### ####'},
    {'name': 'Chile', 'code': 'CL', 'phoneCode': '+56', 'flag': '🇨🇱', 'phoneFormat': '# #### ####'},
    {'name': 'Colombia', 'code': 'CO', 'phoneCode': '+57', 'flag': '🇨🇴', 'phoneFormat': '### ### ####'},
    {'name': 'Peru', 'code': 'PE', 'phoneCode': '+51', 'flag': '🇵🇪', 'phoneFormat': '### ### ###'},
    {'name': 'Venezuela', 'code': 'VE', 'phoneCode': '+58', 'flag': '🇻🇪', 'phoneFormat': '### ### ####'},
    {'name': 'Ecuador', 'code': 'EC', 'phoneCode': '+593', 'flag': '🇪🇨', 'phoneFormat': '## ### ####'},
    {'name': 'Bolivia', 'code': 'BO', 'phoneCode': '+591', 'flag': '🇧🇴', 'phoneFormat': '### ### ###'},
    {'name': 'Paraguay', 'code': 'PY', 'phoneCode': '+595', 'flag': '🇵🇾', 'phoneFormat': '### ### ###'},
    {'name': 'Uruguay', 'code': 'UY', 'phoneCode': '+598', 'flag': '🇺🇾', 'phoneFormat': '### ### ###'},
    {'name': 'Guyana', 'code': 'GY', 'phoneCode': '+592', 'flag': '🇬🇾', 'phoneFormat': '### ####'},
    {'name': 'Suriname', 'code': 'SR', 'phoneCode': '+597', 'flag': '🇸🇷', 'phoneFormat': '### ####'},

    // Europe
    {'name': 'United Kingdom', 'code': 'GB', 'phoneCode': '+44', 'flag': '🇬🇧', 'phoneFormat': '#### ######'},
    {'name': 'Germany', 'code': 'DE', 'phoneCode': '+49', 'flag': '🇩🇪', 'phoneFormat': '### #######'},
    {'name': 'France', 'code': 'FR', 'phoneCode': '+33', 'flag': '🇫🇷', 'phoneFormat': '# ## ## ## ##'},
    {'name': 'Italy', 'code': 'IT', 'phoneCode': '+39', 'flag': '🇮🇹', 'phoneFormat': '### ### ####'},
    {'name': 'Spain', 'code': 'ES', 'phoneCode': '+34', 'flag': '🇪🇸', 'phoneFormat': '### ## ## ##'},
    {'name': 'Netherlands', 'code': 'NL', 'phoneCode': '+31', 'flag': '🇳🇱', 'phoneFormat': '## ### ####'},
    {'name': 'Belgium', 'code': 'BE', 'phoneCode': '+32', 'flag': '🇧🇪', 'phoneFormat': '### ## ## ##'},
    {'name': 'Switzerland', 'code': 'CH', 'phoneCode': '+41', 'flag': '🇨🇭', 'phoneFormat': '## ### ## ##'},
    {'name': 'Austria', 'code': 'AT', 'phoneCode': '+43', 'flag': '🇦🇹', 'phoneFormat': '### ### ####'},
    {'name': 'Sweden', 'code': 'SE', 'phoneCode': '+46', 'flag': '🇸🇪', 'phoneFormat': '## ### ####'},
    {'name': 'Norway', 'code': 'NO', 'phoneCode': '+47', 'flag': '🇳🇴', 'phoneFormat': '### ## ###'},
    {'name': 'Denmark', 'code': 'DK', 'phoneCode': '+45', 'flag': '🇩🇰', 'phoneFormat': '## ## ## ##'},
    {'name': 'Finland', 'code': 'FI', 'phoneCode': '+358', 'flag': '🇫🇮', 'phoneFormat': '## ### ####'},
    {'name': 'Poland', 'code': 'PL', 'phoneCode': '+48', 'flag': '🇵🇱', 'phoneFormat': '### ### ###'},
    {'name': 'Czech Republic', 'code': 'CZ', 'phoneCode': '+420', 'flag': '🇨🇿', 'phoneFormat': '### ### ###'},
    {'name': 'Hungary', 'code': 'HU', 'phoneCode': '+36', 'flag': '🇭🇺', 'phoneFormat': '## ### ####'},
    {'name': 'Romania', 'code': 'RO', 'phoneCode': '+40', 'flag': '🇷🇴', 'phoneFormat': '### ### ###'},
    {'name': 'Bulgaria', 'code': 'BG', 'phoneCode': '+359', 'flag': '🇧🇬', 'phoneFormat': '### ### ###'},
    {'name': 'Croatia', 'code': 'HR', 'phoneCode': '+385', 'flag': '🇭🇷', 'phoneFormat': '## ### ####'},
    {'name': 'Serbia', 'code': 'RS', 'phoneCode': '+381', 'flag': '🇷🇸', 'phoneFormat': '## ### ####'},
    {'name': 'Slovenia', 'code': 'SI', 'phoneCode': '+386', 'flag': '🇸🇮', 'phoneFormat': '## ### ###'},
    {'name': 'Slovakia', 'code': 'SK', 'phoneCode': '+421', 'flag': '🇸🇰', 'phoneFormat': '### ### ###'},
    {'name': 'Lithuania', 'code': 'LT', 'phoneCode': '+370', 'flag': '🇱🇹', 'phoneFormat': '### #####'},
    {'name': 'Latvia', 'code': 'LV', 'phoneCode': '+371', 'flag': '🇱🇻', 'phoneFormat': '#### ####'},
    {'name': 'Estonia', 'code': 'EE', 'phoneCode': '+372', 'flag': '🇪🇪', 'phoneFormat': '#### ####'},
    {'name': 'Ireland', 'code': 'IE', 'phoneCode': '+353', 'flag': '🇮🇪', 'phoneFormat': '## ### ####'},
    {'name': 'Portugal', 'code': 'PT', 'phoneCode': '+351', 'flag': '🇵🇹', 'phoneFormat': '### ### ###'},
    {'name': 'Greece', 'code': 'GR', 'phoneCode': '+30', 'flag': '🇬🇷', 'phoneFormat': '### ### ####'},
    {'name': 'Turkey', 'code': 'TR', 'phoneCode': '+90', 'flag': '🇹🇷', 'phoneFormat': '### ### ####'},
    {'name': 'Russia', 'code': 'RU', 'phoneCode': '+7', 'flag': '🇷🇺', 'phoneFormat': '### ### ####'},
    {'name': 'Ukraine', 'code': 'UA', 'phoneCode': '+380', 'flag': '🇺🇦', 'phoneFormat': '## ### ####'},
    {'name': 'Belarus', 'code': 'BY', 'phoneCode': '+375', 'flag': '🇧🇾', 'phoneFormat': '## ### ####'},
    {'name': 'Moldova', 'code': 'MD', 'phoneCode': '+373', 'flag': '🇲🇩', 'phoneFormat': '### ### ###'},

    // Asia
    {'name': 'India', 'code': 'IN', 'phoneCode': '+91', 'flag': '🇮🇳', 'phoneFormat': '##### #####'},
    {'name': 'China', 'code': 'CN', 'phoneCode': '+86', 'flag': '🇨🇳', 'phoneFormat': '### #### ####'},
    {'name': 'Japan', 'code': 'JP', 'phoneCode': '+81', 'flag': '🇯🇵', 'phoneFormat': '## #### ####'},
    {'name': 'South Korea', 'code': 'KR', 'phoneCode': '+82', 'flag': '🇰🇷', 'phoneFormat': '## #### ####'},
    {'name': 'North Korea', 'code': 'KP', 'phoneCode': '+850', 'flag': '🇰🇵', 'phoneFormat': '### ### ####'},
    {'name': 'Thailand', 'code': 'TH', 'phoneCode': '+66', 'flag': '🇹🇭', 'phoneFormat': '## ### ####'},
    {'name': 'Vietnam', 'code': 'VN', 'phoneCode': '+84', 'flag': '🇻🇳', 'phoneFormat': '### ### ####'},
    {'name': 'Philippines', 'code': 'PH', 'phoneCode': '+63', 'flag': '🇵🇭', 'phoneFormat': '### ### ####'},
    {'name': 'Indonesia', 'code': 'ID', 'phoneCode': '+62', 'flag': '🇮🇩', 'phoneFormat': '### ### ####'},
    {'name': 'Malaysia', 'code': 'MY', 'phoneCode': '+60', 'flag': '🇲🇾', 'phoneFormat': '## ### ####'},
    {'name': 'Singapore', 'code': 'SG', 'phoneCode': '+65', 'flag': '🇸🇬', 'phoneFormat': '#### ####'},
    {'name': 'Brunei', 'code': 'BN', 'phoneCode': '+673', 'flag': '🇧🇳', 'phoneFormat': '### ####'},
    {'name': 'Cambodia', 'code': 'KH', 'phoneCode': '+855', 'flag': '🇰🇭', 'phoneFormat': '## ### ###'},
    {'name': 'Laos', 'code': 'LA', 'phoneCode': '+856', 'flag': '🇱🇦', 'phoneFormat': '## ### ###'},
    {'name': 'Myanmar', 'code': 'MM', 'phoneCode': '+95', 'flag': '🇲🇲', 'phoneFormat': '## ### ####'},
    {'name': 'Bangladesh', 'code': 'BD', 'phoneCode': '+880', 'flag': '🇧🇩', 'phoneFormat': '#### ### ###'},
    {'name': 'Pakistan', 'code': 'PK', 'phoneCode': '+92', 'flag': '🇵🇰', 'phoneFormat': '### ### ####'},
    {'name': 'Afghanistan', 'code': 'AF', 'phoneCode': '+93', 'flag': '🇦🇫', 'phoneFormat': '## ### ####'},
    {'name': 'Sri Lanka', 'code': 'LK', 'phoneCode': '+94', 'flag': '🇱🇰', 'phoneFormat': '## ### ####'},
    {'name': 'Maldives', 'code': 'MV', 'phoneCode': '+960', 'flag': '🇲🇻', 'phoneFormat': '### ####'},
    {'name': 'Nepal', 'code': 'NP', 'phoneCode': '+977', 'flag': '🇳🇵', 'phoneFormat': '### ### ####'},
    {'name': 'Bhutan', 'code': 'BT', 'phoneCode': '+975', 'flag': '🇧🇹', 'phoneFormat': '## ### ###'},
    {'name': 'Mongolia', 'code': 'MN', 'phoneCode': '+976', 'flag': '🇲🇳', 'phoneFormat': '## ## ####'},
    {'name': 'Kazakhstan', 'code': 'KZ', 'phoneCode': '+7', 'flag': '🇰🇿', 'phoneFormat': '### ### ####'},
    {'name': 'Uzbekistan', 'code': 'UZ', 'phoneCode': '+998', 'flag': '🇺🇿', 'phoneFormat': '## ### ####'},
    {'name': 'Kyrgyzstan', 'code': 'KG', 'phoneCode': '+996', 'flag': '🇰🇬', 'phoneFormat': '### ### ###'},
    {'name': 'Tajikistan', 'code': 'TJ', 'phoneCode': '+992', 'flag': '🇹🇯', 'phoneFormat': '## ### ####'},
    {'name': 'Turkmenistan', 'code': 'TM', 'phoneCode': '+993', 'flag': '🇹🇲', 'phoneFormat': '## ### ###'},
    {'name': 'Iran', 'code': 'IR', 'phoneCode': '+98', 'flag': '🇮🇷', 'phoneFormat': '### ### ####'},
    {'name': 'Iraq', 'code': 'IQ', 'phoneCode': '+964', 'flag': '🇮🇶', 'phoneFormat': '### ### ####'},
    {'name': 'Syria', 'code': 'SY', 'phoneCode': '+963', 'flag': '🇸🇾', 'phoneFormat': '### ### ###'},
    {'name': 'Lebanon', 'code': 'LB', 'phoneCode': '+961', 'flag': '🇱🇧', 'phoneFormat': '## ### ###'},
    {'name': 'Jordan', 'code': 'JO', 'phoneCode': '+962', 'flag': '🇯🇴', 'phoneFormat': '## ### ####'},
    {'name': 'Israel', 'code': 'IL', 'phoneCode': '+972', 'flag': '🇮🇱', 'phoneFormat': '## ### ####'},
    {'name': 'Palestine', 'code': 'PS', 'phoneCode': '+970', 'flag': '🇵🇸', 'phoneFormat': '## ### ####'},
    {'name': 'Saudi Arabia', 'code': 'SA', 'phoneCode': '+966', 'flag': '🇸🇦', 'phoneFormat': '## ### ####'},
    {'name': 'United Arab Emirates', 'code': 'AE', 'phoneCode': '+971', 'flag': '🇦🇪', 'phoneFormat': '## ### ####'},
    {'name': 'Qatar', 'code': 'QA', 'phoneCode': '+974', 'flag': '🇶🇦', 'phoneFormat': '#### ####'},
    {'name': 'Bahrain', 'code': 'BH', 'phoneCode': '+973', 'flag': '🇧🇭', 'phoneFormat': '#### ####'},
    {'name': 'Kuwait', 'code': 'KW', 'phoneCode': '+965', 'flag': '🇰🇼', 'phoneFormat': '#### ####'},
    {'name': 'Oman', 'code': 'OM', 'phoneCode': '+968', 'flag': '🇴🇲', 'phoneFormat': '#### ####'},
    {'name': 'Yemen', 'code': 'YE', 'phoneCode': '+967', 'flag': '🇾🇪', 'phoneFormat': '### ### ###'},

    // Oceania
    {'name': 'Australia', 'code': 'AU', 'phoneCode': '+61', 'flag': '🇦🇺', 'phoneFormat': '### ### ###'},
    {'name': 'New Zealand', 'code': 'NZ', 'phoneCode': '+64', 'flag': '🇳🇿', 'phoneFormat': '## ### ####'},
    {'name': 'Fiji', 'code': 'FJ', 'phoneCode': '+679', 'flag': '🇫🇯', 'phoneFormat': '### ####'},
    {'name': 'Papua New Guinea', 'code': 'PG', 'phoneCode': '+675', 'flag': '🇵🇬', 'phoneFormat': '### ####'},
    {'name': 'Solomon Islands', 'code': 'SB', 'phoneCode': '+677', 'flag': '🇸🇧', 'phoneFormat': '### ####'},
    {'name': 'Vanuatu', 'code': 'VU', 'phoneCode': '+678', 'flag': '🇻🇺', 'phoneFormat': '### ####'},
    {'name': 'New Caledonia', 'code': 'NC', 'phoneCode': '+687', 'flag': '🇳🇨', 'phoneFormat': '## ## ##'},
    {'name': 'French Polynesia', 'code': 'PF', 'phoneCode': '+689', 'flag': '🇵🇫', 'phoneFormat': '## ## ##'},
    {'name': 'Samoa', 'code': 'WS', 'phoneCode': '+685', 'flag': '🇼🇸', 'phoneFormat': '### ####'},
    {'name': 'Tonga', 'code': 'TO', 'phoneCode': '+676', 'flag': '🇹🇴', 'phoneFormat': '### ####'},
    {'name': 'Kiribati', 'code': 'KI', 'phoneCode': '+686', 'flag': '🇰🇮', 'phoneFormat': '### ####'},
    {'name': 'Tuvalu', 'code': 'TV', 'phoneCode': '+688', 'flag': '🇹🇻', 'phoneFormat': '### ####'},
    {'name': 'Nauru', 'code': 'NR', 'phoneCode': '+674', 'flag': '🇳🇷', 'phoneFormat': '### ####'},
    {'name': 'Palau', 'code': 'PW', 'phoneCode': '+680', 'flag': '🇵🇼', 'phoneFormat': '### ####'},
    {'name': 'Marshall Islands', 'code': 'MH', 'phoneCode': '+692', 'flag': '🇲🇭', 'phoneFormat': '### ####'},
    {'name': 'Micronesia', 'code': 'FM', 'phoneCode': '+691', 'flag': '🇫🇲', 'phoneFormat': '### ####'},
    {'name': 'Cook Islands', 'code': 'CK', 'phoneCode': '+682', 'flag': '🇨🇰', 'phoneFormat': '### ####'},
    {'name': 'Niue', 'code': 'NU', 'phoneCode': '+683', 'flag': '🇳🇺', 'phoneFormat': '### ####'},
    {'name': 'Tokelau', 'code': 'TK', 'phoneCode': '+690', 'flag': '🇹🇰', 'phoneFormat': '### ####'},
  ];

  static Map<String, dynamic> getCountryByCode(String countryCode) {
    return countries.firstWhere(
      (country) => country['code'] == countryCode,
      orElse: () => countries.first, // Default to first country if not found
    );
  }

  static Map<String, dynamic> getCountryByPhoneCode(String phoneCode) {
    return countries.firstWhere(
      (country) => country['phoneCode'] == phoneCode,
      orElse: () => countries.first, // Default to first country if not found
    );
  }

  static List<Map<String, dynamic>> searchCountries(String query) {
    if (query.isEmpty) return countries;
    
    return countries.where((country) {
      final name = country['name'].toString().toLowerCase();
      final code = country['code'].toString().toLowerCase();
      final phoneCode = country['phoneCode'].toString();
      final searchQuery = query.toLowerCase();
      
      return name.contains(searchQuery) || 
             code.contains(searchQuery) || 
             phoneCode.contains(searchQuery);
    }).toList();
  }

  static List<Map<String, dynamic>> getCountriesByRegion(String region) {
    // This is a simplified region mapping - you can expand this
    switch (region.toLowerCase()) {
      case 'africa':
        return countries.where((country) => 
          ['UG', 'KE', 'TZ', 'NG', 'GH', 'ZA', 'ET', 'EG', 'MA', 'DZ', 'RW', 'BI', 'TN', 'LY', 'SD', 'SS', 'TD', 'NE', 'ML', 'BF', 'SN', 'GN', 'SL', 'LR', 'CI', 'TG', 'BJ', 'CM', 'CF', 'GQ', 'GA', 'CG', 'CD', 'AO', 'ZM', 'ZW', 'BW', 'NA', 'LS', 'SZ', 'MG', 'MU', 'SC', 'KM', 'DJ', 'SO', 'ER', 'MW', 'MZ', 'CV', 'ST', 'GW', 'GM', 'MR'].contains(country['code'])).toList();
      case 'europe':
        return countries.where((country) => 
          ['GB', 'DE', 'FR', 'IT', 'ES', 'NL', 'BE', 'CH', 'AT', 'SE', 'NO', 'DK', 'FI', 'PL', 'CZ', 'HU', 'RO', 'BG', 'HR', 'RS', 'SI', 'SK', 'LT', 'LV', 'EE', 'IE', 'PT', 'GR', 'TR', 'RU', 'UA', 'BY', 'MD'].contains(country['code'])).toList();
      case 'asia':
        return countries.where((country) => 
          ['IN', 'CN', 'JP', 'KR', 'KP', 'TH', 'VN', 'PH', 'ID', 'MY', 'SG', 'BN', 'KH', 'LA', 'MM', 'BD', 'PK', 'AF', 'LK', 'MV', 'NP', 'BT', 'MN', 'KZ', 'UZ', 'KG', 'TJ', 'TM', 'IR', 'IQ', 'SY', 'LB', 'JO', 'IL', 'PS', 'SA', 'AE', 'QA', 'BH', 'KW', 'OM', 'YE'].contains(country['code'])).toList();
      case 'americas':
        return countries.where((country) => 
          ['US', 'CA', 'MX', 'GT', 'BZ', 'SV', 'HN', 'NI', 'CR', 'PA', 'BR', 'AR', 'CL', 'CO', 'PE', 'VE', 'EC', 'BO', 'PY', 'UY', 'GY', 'SR'].contains(country['code'])).toList();
      case 'oceania':
        return countries.where((country) => 
          ['AU', 'NZ', 'FJ', 'PG', 'SB', 'VU', 'NC', 'PF', 'WS', 'TO', 'KI', 'TV', 'NR', 'PW', 'MH', 'FM', 'CK', 'NU', 'TK'].contains(country['code'])).toList();
      default:
        return countries;
    }
  }

  static List<Map<String, dynamic>> getAllCountries() {
    return countries;
  }
}
