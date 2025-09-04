import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';
  
  String _currentLanguage = _defaultLanguage;
  
  String get currentLanguage => _currentLanguage;
  
  // Available languages with their display names
  static const Map<String, Map<String, String>> languages = {
    'en': {
      'name': 'English',
      'flag': '🇬🇧',
      'nativeName': 'English',
    },
    'ar': {
      'name': 'Arabic',
      'flag': '🇦🇪',
      'nativeName': 'العربية',
    },
    'fr': {
      'name': 'French',
      'flag': '🇫🇷',
      'nativeName': 'Français',
    },
    'es': {
      'name': 'Spanish',
      'flag': '🇪🇸',
      'nativeName': 'Español',
    },
    'ko': {
      'name': 'Korean',
      'flag': '🇰🇷',
      'nativeName': '한국어',
    },
    'de': {
      'name': 'German',
      'flag': '🇩🇪',
      'nativeName': 'Deutsch',
    },
    'pt': {
      'name': 'Portuguese',
      'flag': '🇵🇹',
      'nativeName': 'Português',
    },
    'hi': {
      'name': 'Hindi',
      'flag': '🇮🇳',
      'nativeName': 'हिन्दी',
    },
    'tr': {
      'name': 'Turkish',
      'flag': '🇹🇷',
      'nativeName': 'Türkçe',
    },
    'ru': {
      'name': 'Russian',
      'flag': '🇷🇺',
      'nativeName': 'Русский',
    },
    'my': {
      'name': 'Myanmar',
      'flag': '🇲🇲',
      'nativeName': 'မြန်မာ',
    },
    'zh': {
      'name': 'Chinese',
      'flag': '🇨🇳',
      'nativeName': '中文',
    },
    'ja': {
      'name': 'Japanese',
      'flag': '🇯🇵',
      'nativeName': '日本語',
    },
    'ro': {
      'name': 'Romanian',
      'flag': '🇷🇴',
      'nativeName': 'Română',
    },
  };
  
  // Translations for common UI elements
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'welcome_back': 'Welcome Back',
      'login_to_provider_account': 'Login to your provider account',
      'phone_number': 'Phone Number',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'login': 'Login',
      'forgot_password': 'Forgot Password?',
      'dont_have_account': "Don't have an account?",
      'register': 'Register',
      'create_account': 'Create Account',
      'register_as_provider': 'Register as a service provider',
      'select_service_type': 'Select Service Type',
      'car_driver': 'Car Driver',
      'boda_rider': 'Boda Rider',
      'full_name': 'Full Name',
      'location': 'Location',
      'reset_password': 'Reset Password',
      'enter_phone_reset': 'Enter your phone number to receive password reset instructions',
      'back_to_login': 'Back to Login',
      'select_language': 'Select your preferred language',
      'change_language_later': 'You can change language later from the settings menu',
      'save': 'SAVE',
      'loading': 'Loading...',
      'classy_provider': 'Classy Provider',
      'connecting_providers': 'Connecting Providers to Opportunities',
      'already_have_account': 'Already have an account?',
    },
    'ar': {
      'welcome_back': 'مرحباً بعودتك',
      'login_to_provider_account': 'تسجيل الدخول إلى حساب المزود',
      'phone_number': 'رقم الهاتف',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'login': 'تسجيل الدخول',
      'forgot_password': 'نسيت كلمة المرور؟',
      'dont_have_account': 'ليس لديك حساب؟',
      'register': 'تسجيل',
      'create_account': 'إنشاء حساب',
      'register_as_provider': 'التسجيل كمزود خدمة',
      'select_service_type': 'اختر نوع الخدمة',
      'car_driver': 'سائق سيارة',
      'boda_rider': 'سائق دراجة نارية',
      'full_name': 'الاسم الكامل',
      'location': 'الموقع',
      'reset_password': 'إعادة تعيين كلمة المرور',
      'enter_phone_reset': 'أدخل رقم هاتفك لتلقي تعليمات إعادة تعيين كلمة المرور',
      'back_to_login': 'العودة إلى تسجيل الدخول',
      'select_language': 'اختر لغتك المفضلة',
      'change_language_later': 'يمكنك تغيير اللغة لاحقاً من قائمة الإعدادات',
      'save': 'حفظ',
      'loading': 'جاري التحميل...',
      'classy_provider': 'كلاسي بروفايدر',
      'connecting_providers': 'ربط المزودين بالفرص',
      'already_have_account': 'لديك حساب بالفعل؟',
    },
    'fr': {
      'welcome_back': 'Bon Retour',
      'login_to_provider_account': 'Connectez-vous à votre compte fournisseur',
      'phone_number': 'Numéro de téléphone',
      'password': 'Mot de passe',
      'confirm_password': 'Confirmer le mot de passe',
      'login': 'Se connecter',
      'forgot_password': 'Mot de passe oublié ?',
      'dont_have_account': "Vous n'avez pas de compte ?",
      'register': 'S\'inscrire',
      'create_account': 'Créer un compte',
      'register_as_provider': 'S\'inscrire en tant que fournisseur de service',
      'select_service_type': 'Sélectionner le type de service',
      'car_driver': 'Chauffeur de voiture',
      'boda_rider': 'Motocycliste',
      'full_name': 'Nom complet',
      'location': 'Emplacement',
      'reset_password': 'Réinitialiser le mot de passe',
      'enter_phone_reset': 'Entrez votre numéro de téléphone pour recevoir les instructions de réinitialisation',
      'back_to_login': 'Retour à la connexion',
      'select_language': 'Sélectionnez votre langue préférée',
      'change_language_later': 'Vous pouvez changer de langue plus tard dans les paramètres',
      'save': 'ENREGISTRER',
      'loading': 'Chargement...',
      'classy_provider': 'Fournisseur Classy',
      'connecting_providers': 'Connecter les fournisseurs aux opportunités',
      'already_have_account': 'Vous avez déjà un compte ?',
    },
  };
  
  // Get translation for current language
  String t(String key) {
    final langTranslations = translations[_currentLanguage];
    if (langTranslations != null && langTranslations.containsKey(key)) {
      return langTranslations[key]!;
    }
    
    // Fallback to English
    final enTranslations = translations['en'];
    if (enTranslations != null && enTranslations.containsKey(key)) {
      return enTranslations[key]!;
    }
    
    return key; // Return key if no translation found
  }
  
  // Initialize language from preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
    notifyListeners();
  }
  
  // Change language and save to preferences
  Future<void> changeLanguage(String languageCode) async {
    if (languages.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }
  
  // Get language info by code
  Map<String, String>? getLanguageInfo(String code) {
    return languages[code];
  }
  
  // Get all available languages
  Map<String, Map<String, String>> get allLanguages => languages;
}
