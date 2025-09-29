class Country {
  final String name;
  final String code;
  final String phoneCode;
  final String flagEmoji;
  final List<String> flagColors;
  final String currency;
  final String currencySymbol;

  Country({
    required this.name,
    required this.code,
    required this.phoneCode,
    required this.flagEmoji,
    required this.flagColors,
    required this.currency,
    required this.currencySymbol,
  });

  static List<Country> get countries => [
    // Africa
    Country(
      name: "Rwanda",
      code: "RW",
      phoneCode: "+250",
      flagEmoji: "🇷🇼",
      flagColors: ["#00A1DE", "#FAD201", "#20603D"],
      currency: "RWF",
      currencySymbol: "₣",
    ),
    Country(
      name: "Uganda",
      code: "UG",
      phoneCode: "+256",
      flagEmoji: "🇺🇬",
      flagColors: ["#FFD100", "#000000", "#D90000"],
      currency: "UGX",
      currencySymbol: "USh",
    ),
    Country(
      name: "Kenya",
      code: "KE",
      phoneCode: "+254",
      flagEmoji: "🇰🇪",
      flagColors: ["#000000", "#FFFFFF", "#CE1126", "#006600"],
      currency: "KES",
      currencySymbol: "KSh",
    ),
    Country(
      name: "Tanzania",
      code: "TZ",
      phoneCode: "+255",
      flagEmoji: "🇹🇿",
      flagColors: ["#00A651", "#1EB53A", "#000000", "#FCD116"],
      currency: "TZS",
      currencySymbol: "TSh",
    ),
    Country(
      name: "Nigeria",
      code: "NG",
      phoneCode: "+234",
      flagEmoji: "🇳🇬",
      flagColors: ["#009739", "#FFFFFF"],
      currency: "NGN",
      currencySymbol: "₦",
    ),
    Country(
      name: "Ghana",
      code: "GH",
      phoneCode: "+233",
      flagEmoji: "🇬🇭",
      flagColors: ["#CE1126", "#FCD116", "#006B3F"],
      currency: "GHS",
      currencySymbol: "₵",
    ),
    Country(
      name: "South Africa",
      code: "ZA",
      phoneCode: "+27",
      flagEmoji: "🇿🇦",
      flagColors: ["#000000", "#FFB915", "#E1392D", "#007A4D", "#FFFFFF", "#002395"],
      currency: "ZAR",
      currencySymbol: "R",
    ),
    
    // Europe
    Country(
      name: "United Kingdom",
      code: "GB",
      phoneCode: "+44",
      flagEmoji: "🇬🇧",
      flagColors: ["#012169", "#FFFFFF", "#C8102E"],
      currency: "GBP",
      currencySymbol: "£",
    ),
    Country(
      name: "Germany",
      code: "DE",
      phoneCode: "+49",
      flagEmoji: "🇩🇪",
      flagColors: ["#000000", "#DD0000", "#FFCE00"],
      currency: "EUR",
      currencySymbol: "€",
    ),
    Country(
      name: "France",
      code: "FR",
      phoneCode: "+33",
      flagEmoji: "🇫🇷",
      flagColors: ["#002395", "#FFFFFF", "#ED2939"],
      currency: "EUR",
      currencySymbol: "€",
    ),
    Country(
      name: "Spain",
      code: "ES",
      phoneCode: "+34",
      flagEmoji: "🇪🇸",
      flagColors: ["#AA151B", "#F1BF00"],
      currency: "EUR",
      currencySymbol: "€",
    ),
    Country(
      name: "Italy",
      code: "IT",
      phoneCode: "+39",
      flagEmoji: "🇮🇹",
      flagColors: ["#009246", "#FFFFFF", "#CE2B37"],
      currency: "EUR",
      currencySymbol: "€",
    ),
    
    // Asia
    Country(
      name: "India",
      code: "IN",
      phoneCode: "+91",
      flagEmoji: "🇮🇳",
      flagColors: ["#FF9933", "#FFFFFF", "#138808"],
      currency: "INR",
      currencySymbol: "₹",
    ),
    Country(
      name: "China",
      code: "CN",
      phoneCode: "+86",
      flagEmoji: "🇨🇳",
      flagColors: ["#DE2910", "#FFDE00"],
      currency: "CNY",
      currencySymbol: "¥",
    ),
    Country(
      name: "Japan",
      code: "JP",
      phoneCode: "+81",
      flagEmoji: "🇯🇵",
      flagColors: ["#FFFFFF", "#BC002D"],
      currency: "JPY",
      currencySymbol: "¥",
    ),
    Country(
      name: "South Korea",
      code: "KR",
      phoneCode: "+82",
      flagEmoji: "🇰🇷",
      flagColors: ["#FFFFFF", "#CD2E3A", "#0047A0"],
      currency: "KRW",
      currencySymbol: "₩",
    ),
    
    // Americas
    Country(
      name: "United States",
      code: "US",
      phoneCode: "+1",
      flagEmoji: "🇺🇸",
      flagColors: ["#B22234", "#FFFFFF", "#3C3B6E"],
      currency: "USD",
      currencySymbol: "\$",
    ),
    Country(
      name: "Canada",
      code: "CA",
      phoneCode: "+1",
      flagEmoji: "🇨🇦",
      flagColors: ["#FF0000", "#FFFFFF"],
      currency: "CAD",
      currencySymbol: "C\$",
    ),
    Country(
      name: "Brazil",
      code: "BR",
      phoneCode: "+55",
      flagEmoji: "🇧🇷",
      flagColors: ["#009C3B", "#FFDF00", "#002776"],
      currency: "BRL",
      currencySymbol: "R\$",
    ),
    Country(
      name: "Mexico",
      code: "MX",
      phoneCode: "+52",
      flagEmoji: "🇲🇽",
      flagColors: ["#006847", "#FFFFFF", "#CE1126"],
      currency: "MXN",
      currencySymbol: "\$",
    ),
    
    // Oceania
    Country(
      name: "Australia",
      code: "AU",
      phoneCode: "+61",
      flagEmoji: "🇦🇺",
      flagColors: ["#012169", "#FFFFFF", "#C8102E"],
      currency: "AUD",
      currencySymbol: "A\$",
    ),
    Country(
      name: "New Zealand",
      code: "NZ",
      phoneCode: "+64",
      flagEmoji: "🇳🇿",
      flagColors: ["#00247D", "#FFFFFF", "#CC142B"],
      currency: "NZD",
      currencySymbol: "NZ\$",
    ),
  ];

  static Country? findByPhoneCode(String phoneCode) {
    try {
      return countries.firstWhere((country) => country.phoneCode == phoneCode);
    } catch (e) {
      return null;
    }
  }

  static Country get defaultCountry => countries.first; // Rwanda
}
