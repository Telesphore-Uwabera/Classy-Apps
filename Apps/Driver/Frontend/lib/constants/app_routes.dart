class AppRoutes {
  // Authentication Routes
  static const welcomeRoute = "welcome";
  static const loginRoute = "login";
  static const registerRoute = "register";
  static const forgotPasswordRoute = "forgot_password";
  static const otpVerificationRoute = "otp_verification";
  
  // Onboarding Routes
  static const onboardingRoute = "onboarding";
  static const serviceTypeSelectionRoute = "service_type_selection";
  
  // Main App Routes
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String bookings = '/bookings';
  static const String wallet = '/wallet';
  
  // Service & Trip Routes
  static const String ongoingService = '/ongoing-service';
  static const String serviceHistory = '/service-history';
  static const String serviceDetails = '/service-details';
  static const String acceptReject = '/accept-reject';
  
  // Profile & Settings Routes
  static const String editProfile = '/edit-profile';
  static const String myVehicles = '/my-vehicles';
  static const String myDocuments = '/my-documents';
  static const String addCar = '/add-car';
  static const String uploadDocument = '/upload-document';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  
  // Emergency & Support Routes
  static const String emergencySos = '/emergency-sos';
  static const String notifications = '/notifications';
  static const String complaints = '/complaints';
  static const String aboutUs = '/about-us';
  
  // Booking & Service Routes
  static const bookingsRoute = "bookings";
  static const walletRoute = "wallet";
  static const ongoingServiceRoute = "ongoing_service";
  static const serviceHistoryRoute = "service_history";
  static const serviceDetailsRoute = "service_details";
  static const acceptRejectRoute = "accept_reject";
  
  // Wallet & Finance Routes
  static const walletHistoryRoute = "wallet_history";
  static const withdrawRoute = "withdraw";
  static const earningsRoute = "earnings";
  static const paymentMethodsRoute = "payment_methods";
  
  // Notification Routes
  static const notificationDetailsRoute = "notification_details";
  
  // Support & Help Routes
  static const supportRoute = "support";
  static const helpCenterRoute = "help_center";
  static const faqRoute = "faq";
  
  // Chat Routes
  static const chatRoute = "chat";
  static const chatListRoute = "chat_list";
  
  // Map & Navigation Routes
  static const mapRoute = "map";
  static const navigationRoute = "navigation";
  
  // Settings Routes
  static const settingsRoute = "settings";
  static const privacyPolicyRoute = "privacy_policy";
  static const termsOfServiceRoute = "terms_of_service";
  static const aboutRoute = "about";
  
  // Welcome & Entry Routes
  static const String welcome = '/welcome';
  static const String otpVerification = '/otp-verification';
  
  // Legacy Routes (keeping for compatibility)
  static const vendorDetails = "vendor";
  static const product = "product";
  static const search = "search";
  static const checkoutRoute = "checkout";
  static const orderDetailsRoute = "order_details";
  static const deliveryAddressesRoute = "delivery_addresses";
  static const newDeliveryAddressesRoute = "new_delivery_addresses";
  static const editDeliveryAddressesRoute = "edit_delivery_addresses";
  static const favouritesRoute = "favourites";

  // Getters for compatibility
  static String get homeRoute => home;
  static String get editProfileRoute => editProfile;
  static String get changePasswordRoute => changePassword;
  static String get notificationsRoute => notifications;
}
