class Api {
  static const String baseUrl = "https://api.classy.com";
  static const String apiUrl = "$baseUrl/api";
  static const String driverApiUrl = "$apiUrl/driver";
  
  // Auth endpoints
  static const String login = "$driverApiUrl/login";
  static const String loginUrl = "$driverApiUrl/login";
  static const String registerUrl = "$driverApiUrl/register";
  static const String driverRegister = "$driverApiUrl/register";
  static const String forgotPassword = "$driverApiUrl/forgot-password";
  static const String forgotPasswordUrl = "$driverApiUrl/forgot-password";
  static const String resetPasswordUrl = "$driverApiUrl/reset-password";
  static const String logout = "$driverApiUrl/logout";
  static const String logoutUrl = "$driverApiUrl/logout";
  static const String verifyFirebaseOtp = "$driverApiUrl/verify-firebase-otp";
  static const String qrlogin = "$driverApiUrl/qr-login";
  static const String updateProfile = "$driverApiUrl/profile/update";
  static const String updatePassword = "$driverApiUrl/change-password";
  static const String verifyPhoneAccount = "$driverApiUrl/verify-phone";
  static const String sendOtp = "$driverApiUrl/send-otp";
  static const String verifyOtp = "$driverApiUrl/verify-otp";
  static const String myProfile = "$driverApiUrl/profile";
  static const String accountDelete = "$driverApiUrl/delete-account";
  static const String documentSubmission = "$driverApiUrl/documents";
  
  // Settings endpoints
  static const String settingsUrl = "$apiUrl/settings";
  
  // Driver endpoints
  static const String profileUrl = "$driverApiUrl/profile";
  static const String updateProfileUrl = "$driverApiUrl/profile/update";
  static const String changePasswordUrl = "$driverApiUrl/change-password";
  
  // Orders endpoints
  static const String ordersUrl = "$driverApiUrl/orders";
  static const String orderDetailsUrl = "$driverApiUrl/orders";
  
  // Earnings endpoints
  static const String earningsUrl = "$driverApiUrl/earnings";
  
  // Location endpoints
  static const String updateLocationUrl = "$driverApiUrl/location/update";
  static const String updateStatusUrl = "$driverApiUrl/status/update";
}