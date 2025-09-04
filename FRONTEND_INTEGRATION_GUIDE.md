# Frontend Integration Guide - Classy Unified Backend

## Overview
This guide provides step-by-step instructions for connecting the three Flutter frontend applications (Customer, Driver, Vendor) to the newly unified backend. The unified backend consolidates the functionality of both "New Owners" and "Update Owners" backends into a single, cohesive API system.

## 🎯 Current Frontend API Configuration

### Customer App
- **Current Base URL**: `http://localhost:8000/api` (development)
- **Production URL**: `https://Classy.edentech.online/api` (commented)
- **Location**: `Apps/Customer/Frontend/lib/constants/api.dart`

### Driver App
- **Current Base URL**: `https://fuodz.edentech.online/api`
- **Development URL**: `http://192.168.8.145:8000/api` (commented)
- **Location**: `Apps/Driver/Frontend/lib/constants/api.dart`

### Vendor App
- **Current Base URL**: `https://fuodz.edentech.online/api`
- **Development URL**: `http://192.168.8.145:8000/api` (commented)
- **Location**: `Apps/Vendor/Frontend/lib/constants/api.dart`

## 🔧 Integration Steps

### Step 1: Update API Base URLs

#### For Customer App
Update `Apps/Customer/Frontend/lib/constants/api.dart`:

```dart
static String get baseUrl {
  // Production - Unified Backend
  return "https://your-unified-backend-domain.com/api";
  
  // Development - Local Unified Backend
  // return "http://localhost:8000/api";
  
  // Staging - Unified Backend Staging
  // return "https://staging.your-unified-backend-domain.com/api";
}
```

#### For Driver App
Update `Apps/Driver/Frontend/lib/constants/api.dart`:

```dart
static String get baseUrl {
  // Production - Unified Backend
  return "https://your-unified-backend-domain.com/api";
  
  // Development - Local Unified Backend
  // return "http://localhost:8000/api";
  
  // Staging - Unified Backend Staging
  // return "https://staging.your-unified-backend-domain.com/api";
}
```

#### For Vendor App
Update `Apps/Vendor/Frontend/lib/constants/api.dart`:

```dart
static String get baseUrl {
  // Production - Unified Backend
  return "https://your-unified-backend-domain.com/api";
  
  // Development - Local Unified Backend
  // return "http://localhost:8000/api";
  
  // Staging - Unified Backend Staging
  // return "https://staging.your-unified-backend-domain.com/api";
}
```

### Step 2: Environment-Specific Configuration

Create environment-specific configuration files for each app:

#### Customer App - Environment Config
Create `Apps/Customer/Frontend/lib/config/environment_config.dart`:

```dart
class EnvironmentConfig {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
  
  static const String _appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Classy Customer',
  );
  
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static String get baseUrl => _baseUrl;
  static String get appName => _appName;
  static String get environment => _environment;
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
}
```

#### Driver App - Environment Config
Create `Apps/Driver/Frontend/lib/config/environment_config.dart`:

```dart
class EnvironmentConfig {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
  
  static const String _appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Classy Driver',
  );
  
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static String get baseUrl => _baseUrl;
  static String get appName => _appName;
  static String get environment => _environment;
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
}
```

#### Vendor App - Environment Config
Create `Apps/Vendor/Frontend/lib/config/environment_config.dart`:

```dart
class EnvironmentConfig {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
  
  static const String _appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Classy Vendor',
  );
  
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static String get baseUrl => _baseUrl;
  static String get appName => _appName;
  static String get environment => _environment;
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
}
```

### Step 3: Update API Constants

#### Customer App - Updated API Constants
Update `Apps/Customer/Frontend/lib/constants/api.dart`:

```dart
import '../config/environment_config.dart';

class Api {
  // Base URL from environment configuration
  static String get baseUrl => EnvironmentConfig.baseUrl;
  
  // API Version
  static const String version = "v1";
  
  // Authentication Endpoints
  static const String login = "/$version/auth/login";
  static const String register = "/$version/auth/register";
  static const String logout = "/$version/auth/logout";
  static const String refresh = "/$version/auth/refresh";
  static const String forgotPassword = "/$version/auth/forgot-password";
  static const String resetPassword = "/$version/auth/reset-password";
  
  // User Profile Endpoints
  static const String profile = "/$version/user/profile";
  static const String updateProfile = "/$version/user/profile";
  static const String changePassword = "/$version/user/change-password";
  
  // Customer-Specific Endpoints
  static const String customerOrders = "/$version/customer/orders";
  static const String customerOrderHistory = "/$version/customer/orders/history";
  static const String customerFavorites = "/$version/customer/favorites";
  static const String customerAddresses = "/$version/customer/addresses";
  
  // Vendor Endpoints
  static const String vendors = "/$version/vendors";
  static const String vendorDetails = "/$version/vendors/{id}";
  static const String vendorMenu = "/$version/vendors/{id}/menu";
  static const String vendorReviews = "/$version/vendors/{id}/reviews";
  
  // Order Endpoints
  static const String orders = "/$version/orders";
  static const String orderDetails = "/$version/orders/{id}";
  static const String createOrder = "/$version/orders";
  static const String orderStatus = "/$version/orders/{id}/status";
  
  // Payment Endpoints
  static const String payments = "/$version/payments";
  static const String paymentMethods = "/$version/payments/methods";
  static const String paymentHistory = "/$version/payments/history";
  
  // Search Endpoints
  static const String search = "/$version/search";
  static const String searchVendors = "/$version/search/vendors";
  static const String searchProducts = "/$version/search/products";
  
  // Notification Endpoints
  static const String notifications = "/$version/notifications";
  static const String notificationSettings = "/$version/notifications/settings";
  
  // Web URLs
  static String get webUrl => baseUrl.replaceAll('/api', '');
  static String get faqs => "$webUrl/faqs";
  static String get terms => "$webUrl/terms";
  static String get privacy => "$webUrl/privacy";
  static String get about => "$webUrl/about";
  static String get contact => "$webUrl/contact";
  static String get help => "$webUrl/help";
  static String get support => "$webUrl/support";
  static String get blog => "$webUrl/blog";
  static String get news => "$webUrl/news";
  static String get events => "$webUrl/events";
  static String get careers => "$webUrl/careers";
  static String get partners => "$webUrl/partners";
  static String get affiliate => "$webUrl/affiliate";
  static String get franchise => "$webUrl/franchise";
  static String get investment => "$webUrl/investment";
  static String get legal => "$webUrl/legal";
  static String get sitemap => "$webUrl/sitemap";
  static String get externalRedirect => "$webUrl/external/web/redirect";
}
```

#### Driver App - Updated API Constants
Update `Apps/Driver/Frontend/lib/constants/api.dart`:

```dart
import '../config/environment_config.dart';

class Api {
  // Base URL from environment configuration
  static String get baseUrl => EnvironmentConfig.baseUrl;
  
  // API Version
  static const String version = "v1";
  
  // Authentication Endpoints
  static const String login = "/$version/auth/login";
  static const String register = "/$version/auth/register";
  static const String logout = "/$version/auth/logout";
  static const String refresh = "/$version/auth/refresh";
  
  // Driver Profile Endpoints
  static const String driverProfile = "/$version/driver/profile";
  static const String updateDriverProfile = "/$version/driver/profile";
  static const String driverDocuments = "/$version/driver/documents";
  static const String driverVehicle = "/$version/driver/vehicle";
  
  // Driver-Specific Endpoints
  static const String driverOrders = "/$version/driver/orders";
  static const String driverOrderHistory = "/$version/driver/orders/history";
  static const String driverEarnings = "/$version/driver/earnings";
  static const String driverSchedule = "/$version/driver/schedule";
  static const String driverLocation = "/$version/driver/location";
  
  // Order Management
  static const String orders = "/$version/orders";
  static const String orderDetails = "/$version/orders/{id}";
  static const String acceptOrder = "/$version/orders/{id}/accept";
  static const String updateOrderStatus = "/$version/orders/{id}/status";
  
  // Web URLs
  static String get webUrl => baseUrl.replaceAll('/api', '');
  static String get faqs => "$webUrl/faqs";
  static String get terms => "$webUrl/terms";
  static String get privacy => "$webUrl/privacy";
  static String get about => "$webUrl/about";
  static String get contact => "$webUrl/contact";
  static String get help => "$webUrl/help";
  static String get support => "$webUrl/support";
  static String get blog => "$webUrl/blog";
  static String get news => "$webUrl/news";
  static String get events => "$webUrl/events";
  static String get careers => "$webUrl/careers";
  static String get partners => "$webUrl/partners";
  static String get affiliate => "$webUrl/affiliate";
  static String get franchise => "$webUrl/franchise";
  static String get investment => "$webUrl/investment";
  static String get legal => "$webUrl/legal";
  static String get sitemap => "$webUrl/sitemap";
}
```

#### Vendor App - Updated API Constants
Update `Apps/Vendor/Frontend/lib/constants/api.dart`:

```dart
import '../config/environment_config.dart';

class Api {
  // Base URL from environment configuration
  static String get baseUrl => EnvironmentConfig.baseUrl;
  
  // API Version
  static const String version = "v1";
  
  // Authentication Endpoints
  static const String login = "/$version/auth/login";
  static const String register = "/$version/auth/register";
  static const String logout = "/$version/auth/logout";
  static const String refresh = "/$version/auth/refresh";
  
  // Vendor Profile Endpoints
  static const String vendorProfile = "/$version/vendor/profile";
  static const String updateVendorProfile = "/$version/vendor/profile";
  static const String vendorDocuments = "/$version/vendor/documents";
  static const String vendorSettings = "/$version/vendor/settings";
  
  // Vendor-Specific Endpoints
  static const String vendorOrders = "/$version/vendor/orders";
  static const String vendorOrderHistory = "/$version/vendor/orders/history";
  static const String vendorProducts = "/$version/vendor/products";
  static const String vendorAnalytics = "/$version/vendor/analytics";
  static const String vendorEarnings = "/$version/vendor/earnings";
  
  // Product Management
  static const String products = "/$version/products";
  static const String productDetails = "/$version/products/{id}";
  static const String createProduct = "/$version/products";
  static const String updateProduct = "/$version/products/{id}";
  static const String deleteProduct = "/$version/products/{id}";
  
  // Order Management
  static const String orders = "/$version/orders";
  static const String orderDetails = "/$version/orders/{id}";
  static const String updateOrderStatus = "/$version/orders/{id}/status";
  
  // Web URLs
  static String get webUrl => baseUrl.replaceAll('/api', '');
  static String get faqs => "$webUrl/faqs";
  static String get terms => "$webUrl/terms";
  static String get privacy => "$webUrl/privacy";
  static String get about => "$webUrl/about";
  static String get contact => "$webUrl/contact";
  static String get help => "$webUrl/help";
  static String get support => "$webUrl/support";
  static String get blog => "$webUrl/blog";
  static String get news => "$webUrl/news";
  static String get events => "$webUrl/events";
  static String get careers => "$webUrl/careers";
  static String get partners => "$webUrl/partners";
  static String get affiliate => "$webUrl/affiliate";
  static String get franchise => "$webUrl/franchise";
  static String get investment => "$webUrl/investment";
  static String get legal => "$webUrl/legal";
  static String get sitemap => "$webUrl/sitemap";
}
```

### Step 4: Build Scripts

#### Customer App - Build Scripts
Create `Apps/Customer/Frontend/build_scripts/build.sh`:

```bash
#!/bin/bash

# Customer App Build Scripts

echo "Building Customer App..."

# Development Build
echo "Building for Development..."
flutter build apk --debug --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://localhost:8000/api --dart-define=APP_NAME="Classy Customer Dev"

# Staging Build
echo "Building for Staging..."
flutter build apk --release --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging.your-unified-backend-domain.com/api --dart-define=APP_NAME="Classy Customer Staging"

# Production Build
echo "Building for Production..."
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://your-unified-backend-domain.com/api --dart-define=APP_NAME="Classy Customer"

echo "Customer App builds completed!"
```

#### Driver App - Build Scripts
Create `Apps/Driver/Frontend/build_scripts/build.sh`:

```bash
#!/bin/bash

# Driver App Build Scripts

echo "Building Driver App..."

# Development Build
echo "Building for Development..."
flutter build apk --debug --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://localhost:8000/api --dart-define=APP_NAME="Classy Driver Dev"

# Staging Build
echo "Building for Staging..."
flutter build apk --release --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging.your-unified-backend-domain.com/api --dart-define=APP_NAME="Classy Driver Staging"

# Production Build
echo "Building for Production..."
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://your-unified-backend-domain.com/api --dart-define=APP_NAME="Classy Driver"

echo "Driver App builds completed!"
```

#### Vendor App - Build Scripts
Create `Apps/Vendor/Frontend/build_scripts/build.sh`:

```bash
#!/bin/bash

# Vendor App Build Scripts

echo "Building Vendor App..."

# Development Build
echo "Building for Development..."
flutter build apk --debug --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://localhost:8000/api --dart-define=APP_NAME="Classy Vendor Dev"

# Staging Build
echo "Building for Staging..."
flutter build apk --release --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging.your-unified-backend-domain.com/api --dart-define=APP_NAME="Classy Vendor Staging"

# Production Build
echo "Building for Production..."
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://your-unified-backend-domain.com/api --dart-define=APP_NAME="Classy Vendor"

echo "Vendor App builds completed!"
```

### Step 5: Environment Configuration Files

#### Development Environment
Create `.env.development` files for each app:

**Customer App** - `Apps/Customer/Frontend/.env.development`:
```env
ENVIRONMENT=development
API_BASE_URL=http://localhost:8000/api
APP_NAME=Classy Customer Dev
DEBUG=true
LOG_LEVEL=debug
```

**Driver App** - `Apps/Driver/Frontend/.env.development`:
```env
ENVIRONMENT=development
API_BASE_URL=http://localhost:8000/api
APP_NAME=Classy Driver Dev
DEBUG=true
LOG_LEVEL=debug
```

**Vendor App** - `Apps/Vendor/Frontend/.env.development`:
```env
ENVIRONMENT=development
API_BASE_URL=http://localhost:8000/api
APP_NAME=Classy Vendor Dev
DEBUG=true
LOG_LEVEL=debug
```

#### Staging Environment
Create `.env.staging` files for each app:

**Customer App** - `Apps/Customer/Frontend/.env.staging`:
```env
ENVIRONMENT=staging
API_BASE_URL=https://staging.your-unified-backend-domain.com/api
APP_NAME=Classy Customer Staging
DEBUG=false
LOG_LEVEL=info
```

**Driver App** - `Apps/Driver/Frontend/.env.staging`:
```env
ENVIRONMENT=staging
API_BASE_URL=https://staging.your-unified-backend-domain.com/api
APP_NAME=Classy Driver Staging
DEBUG=false
LOG_LEVEL=info
```

**Vendor App** - `Apps/Vendor/Frontend/.env.staging`:
```env
ENVIRONMENT=staging
API_BASE_URL=https://staging.your-unified-backend-domain.com/api
APP_NAME=Classy Vendor Staging
DEBUG=false
LOG_LEVEL=info
```

#### Production Environment
Create `.env.production` files for each app:

**Customer App** - `Apps/Customer/Frontend/.env.production`:
```env
ENVIRONMENT=production
API_BASE_URL=https://your-unified-backend-domain.com/api
APP_NAME=Classy Customer
DEBUG=false
LOG_LEVEL=warning
```

**Driver App** - `Apps/Driver/Frontend/.env.production`:
```env
ENVIRONMENT=production
API_BASE_URL=https://your-unified-backend-domain.com/api
APP_NAME=Classy Driver
DEBUG=false
LOG_LEVEL=warning
```

**Vendor App** - `Apps/Vendor/Frontend/.env.production`:
```env
ENVIRONMENT=production
API_BASE_URL=https://your-unified-backend-domain.com/api
APP_NAME=Classy Vendor
DEBUG=false
LOG_LEVEL=warning
```

### Step 6: Update Main App Files

#### Customer App - Main App
Update `Apps/Customer/Frontend/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/environment_config.dart';
import 'constants/api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EnvironmentConfig.appName,
      debugShowCheckedModeBanner: EnvironmentConfig.isDevelopment,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EnvironmentConfig.appName),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to ${EnvironmentConfig.appName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Environment: ${EnvironmentConfig.environment}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'API Base URL: ${EnvironmentConfig.baseUrl}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            if (EnvironmentConfig.isDevelopment)
              ElevatedButton(
                onPressed: () {
                  // Test API connection
                  _testApiConnection();
                },
                child: Text('Test API Connection'),
              ),
          ],
        ),
      ),
    );
  }
  
  void _testApiConnection() {
    // Implement API connection test
    print('Testing API connection to: ${Api.baseUrl}');
  }
}
```

### Step 7: API Service Updates

#### Customer App - API Service
Update `Apps/Customer/Frontend/lib/services/api_service.dart`:

```dart
import 'package:dio/dio.dart';
import '../constants/api.dart';
import '../config/environment_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: Api.baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Classy-Customer-App/${EnvironmentConfig.environment}',
      },
    ));

    // Add interceptors for logging in development
    if (EnvironmentConfig.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ));
    }

    // Add authentication interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        // options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Handle unauthorized
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  // Generic GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
```

### Step 8: Testing and Validation

#### API Connection Test
Create a test script to validate the connection:

```dart
// Test API connection
Future<void> testApiConnection() async {
  try {
    final apiService = ApiService();
    apiService.initialize();
    
    // Test basic connectivity
    final response = await apiService.get('/v1/health');
    print('✅ API Connection Successful: ${response.statusCode}');
    
    // Test authentication endpoint
    final authResponse = await apiService.get('/v1/auth/status');
    print('✅ Authentication Endpoint Accessible: ${authResponse.statusCode}');
    
  } catch (e) {
    print('❌ API Connection Failed: $e');
  }
}
```

## 🚀 Deployment Commands

### Development
```bash
# Customer App
cd Apps/Customer/Frontend
flutter run --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://localhost:8000/api

# Driver App
cd Apps/Driver/Frontend
flutter run --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://localhost:8000/api

# Vendor App
cd Apps/Vendor/Frontend
flutter run --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://localhost:8000/api
```

### Staging
```bash
# Customer App
cd Apps/Customer/Frontend
flutter build apk --release --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging.your-unified-backend-domain.com/api

# Driver App
cd Apps/Driver/Frontend
flutter build apk --release --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging.your-unified-backend-domain.com/api

# Vendor App
cd Apps/Vendor/Frontend
flutter build apk --release --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging.your-unified-backend-domain.com/api
```

### Production
```bash
# Customer App
cd Apps/Customer/Frontend
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://your-unified-backend-domain.com/api

# Driver App
cd Apps/Driver/Frontend
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://your-unified-backend-domain.com/api

# Vendor App
cd Apps/Vendor/Frontend
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://your-unified-backend-domain.com/api
```

## 🔍 Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check if the unified backend is running
   - Verify the base URL is correct
   - Check network connectivity
   - Verify firewall settings

2. **Authentication Errors**
   - Ensure the unified backend has the correct authentication endpoints
   - Check if the API version matches (v1)
   - Verify token format and expiration

3. **Build Errors**
   - Ensure all environment variables are properly defined
   - Check Flutter version compatibility
   - Verify all dependencies are installed

### Debug Mode
Enable debug logging in development:

```dart
if (EnvironmentConfig.isDevelopment) {
  print('🔍 Debug Mode Enabled');
  print('📍 API Base URL: ${Api.baseUrl}');
  print('🌍 Environment: ${EnvironmentConfig.environment}');
  print('📱 App Name: ${EnvironmentConfig.appName}');
}
```

## 📋 Checklist

- [ ] Update API base URLs in all three apps
- [ ] Create environment configuration files
- [ ] Update API constants with unified endpoints
- [ ] Create build scripts for different environments
- [ ] Update main app files
- [ ] Update API services
- [ ] Test API connections
- [ ] Validate authentication flows
- [ ] Test order management
- [ ] Test payment processing
- [ ] Test notifications
- [ ] Deploy to staging environment
- [ ] Deploy to production environment

## 🎉 Success Indicators

- All three apps successfully connect to the unified backend
- Authentication works across all apps
- Order management functions properly
- Payment processing is functional
- Real-time notifications work
- All API endpoints respond correctly
- Apps can switch between environments seamlessly

## 📞 Support

For technical support or questions about the integration:

1. Check the unified backend logs
2. Verify API endpoint responses
3. Test with Postman or similar tools
4. Review the unified backend documentation
5. Check the deployment guide for backend setup

---

**Note**: This guide assumes the unified backend is properly configured and running. Please ensure the backend is set up according to the `DEPLOYMENT_GUIDE.md` before attempting frontend integration.
