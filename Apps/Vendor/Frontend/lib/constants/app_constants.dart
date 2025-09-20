class AppConstants {
  // App Information
  static const String appName = 'Class Vendor';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Class Platform';
  
  // Currency
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';
  
  // API Configuration
  static const String baseUrl = 'https://api.classy.com';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Firebase Configuration
  static const String firebaseProjectId = 'classy-vendor-app';
  
  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusDelivering = 'delivering';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCancelled = 'cancelled';
  
  // Product Status
  static const String productStatusActive = 'active';
  static const String productStatusInactive = 'inactive';
  static const String productStatusOutOfStock = 'out_of_stock';
  
  // Vendor Status
  static const String vendorStatusOnline = 'online';
  static const String vendorStatusOffline = 'offline';
  static const String vendorStatusBusy = 'busy';
  
  // Notification Types
  static const String notificationTypeOrder = 'order';
  static const String notificationTypePayment = 'payment';
  static const String notificationTypeSystem = 'system';
  static const String notificationTypePromotion = 'promotion';
  
  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImagesPerProduct = 10;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxProductDescriptionLength = 1000;
  static const double minProductPrice = 0.01;
  static const double maxProductPrice = 999999.99;
  
  // Timeouts
  static const int splashScreenDelay = 2000; // 2 seconds
  static const int autoLogoutDelay = 30 * 60 * 1000; // 30 minutes
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyVendorData = 'vendor_data';
  static const String keyAppSettings = 'app_settings';
  static const String keyNotifications = 'notifications';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // Error Messages
  static const String errorNetworkConnection = 'No internet connection';
  static const String errorServerError = 'Server error occurred';
  static const String errorUnknown = 'An unknown error occurred';
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorEmailAlreadyExists = 'Email already exists';
  static const String errorWeakPassword = 'Password is too weak';
  static const String errorUserNotFound = 'User not found';
  static const String errorTooManyRequests = 'Too many requests. Please try again later';
  
  // Success Messages
  static const String successLogin = 'Login successful';
  static const String successLogout = 'Logout successful';
  static const String successProductAdded = 'Product added successfully';
  static const String successProductUpdated = 'Product updated successfully';
  static const String successProductDeleted = 'Product deleted successfully';
  static const String successOrderUpdated = 'Order updated successfully';
  static const String successProfileUpdated = 'Profile updated successfully';
  static const String successPasswordChanged = 'Password changed successfully';
  
  // Default Values
  static const double defaultDeliveryFee = 5.00;
  static const double defaultMinOrderAmount = 10.00;
  static const int defaultEstimatedDeliveryTime = 30; // minutes
  static const int defaultStockAlertThreshold = 10;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Chart Colors
  static const List<int> chartColors = [
    0xFFE91E63, // Primary Pink
    0xFF9C27B0, // Purple
    0xFF3F51B5, // Indigo
    0xFF2196F3, // Blue
    0xFF00BCD4, // Cyan
    0xFF4CAF50, // Green
    0xFF8BC34A, // Light Green
    0xFFFFC107, // Amber
    0xFFFF9800, // Orange
    0xFF795548, // Brown
  ];
}
