flutter# 🚀 Classy - Multi-App Platform

A comprehensive multi-application platform built with Flutter frontends and Firebase backend, featuring real-time notifications, Google Maps integration, and cloud-based data management. This platform provides a complete solution for food delivery, transportation services, and parcel courier delivery.

## 📱 Applications

### 🛒 Customer App
- **Purpose**: End-user application for ordering food, requesting transportation services, and parcel delivery
- **Features**: 
  - User registration and authentication (phone + password)
  - Product browsing and search with categories
  - Shopping cart management with real-time updates
  - Order placement and tracking with live status
  - Real-time delivery updates and driver tracking
  - Payment integration (PayPal, wallet, cash)
  - Rating and review system
  - Location-based services with Google Maps
  - Wallet system for cashless payments
  - Special offers and promotional content
- **Technology**: Flutter with Firebase backend
- **Port**: 3000 (Web Development)

### 🏪 Vendor App  
- **Purpose**: Business management application for restaurants and food vendors
- **Features**: 
  - Product and service management with image uploads
  - Order processing and fulfillment with status updates
  - Inventory management with stock tracking
  - Analytics dashboard with sales reports
  - Customer management and communication
  - Sales reporting and financial tracking
  - Menu/catalog management
  - Delivery zone configuration
- **Technology**: Flutter with Firebase backend
- **Port**: 3001 (Web Development)

### 🚗 Driver App
- **Purpose**: Delivery and transportation service management
- **Features**: 
  - Driver registration with service type selection (car/boda)
  - Online/offline toggle for ride availability
  - Order acceptance and management
  - Route optimization with Google Maps
  - Real-time location tracking
  - Delivery status updates
  - Earnings tracking and payout management
  - Customer communication
  - License and document management
  - Proximity-based ride matching
- **Technology**: Flutter with Firebase backend
- **Port**: 3002 (Web Development)

### 🎛️ Admin Dashboard
- **Purpose**: Comprehensive administrative control panel for platform management
- **Features**:
  - User management (customers, vendors, driversYeah )
  - Order management and status tracking
  - Content management (FAQs, policies, categories)
  - Analytics and reporting dashboard
  - Payment and payout management
  - Notification and messaging system
  - System configuration and settings
  - Restaurant and driver approval workflows
  - Coupon and promotional management
  - Quick picks and featured content management
- **Technology**: React + TypeScript with Tailwind CSS
- **Port**: 3003 (Development)

## 🏗️ Architecture

```
📁 Classy Platform
├── 📱 Apps/ (Flutter Frontends)
│   ├── Customer/Frontend/ (Flutter app for end users)
│   ├── Vendor/Frontend/ (Flutter app for business owners)
│   ├── Driver/Frontend/ (Flutter app for delivery drivers)
│   └── Admin/ (React + TypeScript admin dashboard)
├── 🔥 Firebase/ (Cloud Backend)
│   ├── Authentication (User management)
│   ├── Firestore (Database)
│   ├── Storage (File management)
│   ├── Cloud Functions (Serverless logic)
│   └── Cloud Messaging (Notifications)
├── 📚 Documentation/
│   ├── FRONTEND_INTEGRATION_GUIDE.md
│   ├── NOTIFICATION_UI_README.md
│   ├── QUICK_START_GUIDE.md
│   └── COMPLETE_INTEGRATION_SUMMARY.md
└── 🔐 Configuration/
    ├── Firebase setup files
    ├── Google Maps configuration
    └── Environment templates
```

## 🔥 Firebase Integration

### Database Collections
- **Users**: Customer, vendor, and driver accounts with role-based access
- **Products**: Food products and menu items
- **Orders**: Service and delivery orders with status tracking
- **Services**: Vendor service offerings and categories
- **Notifications**: Real-time app notifications and updates
- **Driver Locations**: GPS tracking data for delivery optimization
- **Payments**: Transaction records and payment history
- **Ratings**: User feedback and review system
- **Messages**: In-app chat system for customer support
- **Categories**: Product and service categorization

### Authentication
- **Phone + Password** based authentication
- **Firebase Authentication** for secure access
- **Real-time user sessions** across all apps
- **Role-based access control** (Customer, Vendor, Driver, Admin)

## 🗺️ Google Maps Integration

### API Configuration
- **API Key**: Configured for geocoding, distance matrix, and places API
- **Services**: 
  - Geocoding for address conversion
  - Distance Matrix for delivery fee calculation
  - Places API for location search
  - Geolocation for user positioning
- **Features**: 
  - Real-time location tracking for drivers
  - Route optimization for deliveries
  - Delivery zone validation
  - Address autocomplete and validation

## 🚀 Getting Started

### Prerequisites
- **Flutter**: 3.0+ for mobile and web development
- **Firebase Project**: Configured with Firestore and Authentication
- **Google Maps API**: Enabled with billing and proper quotas
- **Node.js**: For frontend build tools

### Firebase Setup

#### 1. Firebase Project Configuration
Create a Firebase project and configure the following services:

```bash
# Firebase services to enable:
- Authentication (Phone + Email)
- Firestore Database
- Cloud Storage
- Cloud Messaging
- Cloud Functions (optional)
```

#### 2. Firebase Configuration
Each app needs proper Firebase configuration:
- Copy `google-services.json` to `android/app/` for Android
- Copy `GoogleService-Info.plist` to `ios/Runner/` for iOS
- Update `lib/firebase_options.dart` with your Firebase project details

### Frontend Setup

#### 1. Install Dependencies
```bash
# Customer App
cd Apps/Customer/Frontend
flutter pub get

# Vendor App
cd Apps/Vendor/Frontend
flutter pub get

# Driver App
cd Apps/Driver/Frontend
flutter pub get

# Admin Dashboard
cd Apps/Admin
npm install
```

#### 2. Configure Firebase
Each app needs proper Firebase configuration:
- Update `lib/firebase_options.dart` with your Firebase project details
- Configure Firestore security rules
- Set up Firebase Authentication providers

#### 3. Run Applications
```bash
# Customer App
cd Apps/Customer/Frontend
flutter run -d chrome --web-port=3000

# Vendor App
cd Apps/Vendor/Frontend
flutter run -d chrome --web-port=3001

# Driver App
cd Apps/Driver/Frontend
flutter run -d chrome --web-port=3002

# Admin Dashboard
cd Apps/Admin
npm run dev
```

## 👥 Role-Based System

### 🛒 Customer Role
**Purpose**: End-users who place orders and use delivery services

**Key Features**:
- **Registration**: Phone number + password authentication
- **Ordering**: Browse products, add to cart, place orders
- **Payment**: Multiple payment methods (PayPal, wallet, cash on delivery)
- **Tracking**: Real-time order and delivery tracking
- **Wallet**: Add money, view balance, make cashless payments
- **Location**: Set delivery addresses with Google Maps integration
- **Reviews**: Rate and review vendors and drivers

**Workflow**:
1. Register with phone number and password
2. Browse products by category or search
3. Add items to cart and proceed to checkout
4. Select delivery address and payment method
5. Place order and track in real-time
6. Receive notifications for order updates
7. Rate and review after delivery

### 🏪 Vendor Role
**Purpose**: Business owners managing products and fulfilling orders

**Key Features**:
- **Registration**: Business registration with documents
- **Product Management**: Add, edit, delete products with images
- **Order Management**: View, accept, and fulfill orders
- **Inventory**: Track stock levels and manage availability
- **Analytics**: Sales reports and performance metrics
- **Settings**: Configure delivery zones and business hours

**Workflow**:
1. Register business with required documents
2. Wait for admin approval
3. Add products and set up catalog
4. Receive order notifications
5. Accept and prepare orders
6. Update order status (preparing, ready, completed)
7. View earnings and analytics

### 🚗 Driver Role
**Purpose**: Delivery personnel providing transportation and delivery services

**Key Features**:
- **Registration**: Driver registration with service type (car/boda)
- **Online/Offline Toggle**: Control availability for ride requests
- **Order Management**: Accept, navigate to, and complete deliveries
- **Location Tracking**: Real-time GPS tracking for customers
- **Earnings**: Track payments and view payout history
- **Documents**: Manage licenses and vehicle documents

**Workflow**:
1. Register as driver with service type selection
2. Upload required documents (license, vehicle registration)
3. Wait for admin approval
4. Go online to receive ride requests
5. Accept nearby delivery requests
6. Navigate to pickup location using Google Maps
7. Complete delivery and update status
8. Receive payment and track earnings

### 🎛️ Admin Role
**Purpose**: Platform administrators managing the entire ecosystem

**Key Features**:
- **User Management**: Approve/reject vendors and drivers
- **Order Oversight**: Monitor all orders and resolve issues
- **Content Management**: Manage FAQs, policies, categories
- **Analytics**: Platform-wide statistics and reports
- **Payment Management**: Handle payouts and transactions
- **System Configuration**: App settings and feature toggles

**Workflow**:
1. Review vendor registration requests
2. Approve/reject driver applications
3. Monitor order flow and resolve disputes
4. Manage platform content and policies
5. Configure system settings and features
6. Generate reports and analytics
7. Handle customer support and complaints

## 🔄 Inter-Role Communication

### Customer ↔ Vendor
- **Order Placement**: Customer places order → Vendor receives notification
- **Order Updates**: Vendor updates status → Customer receives notification
- **Communication**: In-app messaging for order clarifications

### Customer ↔ Driver
- **Delivery Assignment**: System assigns driver → Customer gets driver details
- **Real-time Tracking**: Driver location shared with customer
- **Delivery Updates**: Driver updates status → Customer gets notifications

### Vendor ↔ Driver
- **Order Handoff**: Vendor marks ready → Driver gets pickup notification
- **Delivery Confirmation**: Driver confirms delivery → Vendor gets completion

### Admin ↔ All Roles
- **Approval Process**: Admin approves vendors/drivers → They can start operating
- **Dispute Resolution**: Admin mediates conflicts between all parties
- **Platform Management**: Admin configures features affecting all users

## 🔐 Authentication System

### User Registration
- **Required Fields**: Name, Phone, Password, User Type
- **Optional Fields**: Email, Referral Code, Profile Picture
- **User Types**: Customer, Vendor, Driver, Admin
- **Firebase Integration**: Automatic user creation in Firestore
- **Phone Verification**: SMS-based phone number verification

### User Login
- **Phone + Password** authentication
- **Firebase Authentication** for security
- **Cross-app session** management
- **Real-time authentication** status updates
- **Role-based access** control

## 📡 Firebase Services

### Authentication
- Phone number authentication
- Email/password authentication
- Custom token authentication
- Role-based access control
- Session management

### Firestore Database
- Real-time data synchronization
- Offline support
- Automatic scaling
- Security rules for data access
- Complex queries and indexing

### Cloud Storage
- File upload and download
- Image optimization
- Secure file access
- CDN integration
- Automatic backup

### Cloud Messaging
- Push notifications
- In-app messaging
- Real-time updates
- Cross-platform support
- Delivery tracking

## 🗄️ Database Schema

### Firestore Collections
```javascript
// Users collection
users: {
  [userId]: {
    name: string,
    email: string,
    phone: string,
    userType: 'customer' | 'vendor' | 'driver' | 'admin',
    status: 'active' | 'inactive' | 'pending',
    createdAt: timestamp,
    updatedAt: timestamp
  }
}

// Products collection
products: {
  [productId]: {
    vendorId: string,
    name: string,
    description: string,
    price: number,
    categoryId: string,
    stock: number,
    status: 'active' | 'inactive',
    images: string[],
    createdAt: timestamp,
    updatedAt: timestamp
  }
}

// Orders collection
orders: {
  [orderId]: {
    userId: string,
    vendorId: string,
    driverId: string,
    totalAmount: number,
    status: 'pending' | 'confirmed' | 'preparing' | 'ready' | 'delivering' | 'completed' | 'cancelled',
    deliveryAddress: object,
    items: array,
    createdAt: timestamp,
    updatedAt: timestamp
  }
}

// Categories collection
categories: {
  [categoryId]: {
    name: string,
    description: string,
    parentId: string,
    image: string,
    createdAt: timestamp,
    updatedAt: timestamp
  }
}
```

## 🔧 Development

### Frontend Development
- **Framework**: Flutter 3.0+ for cross-platform development
- **State Management**: Provider pattern with proper separation of concerns
- **Maps**: Google Maps Flutter integration
- **Notifications**: Firebase Cloud Messaging for push notifications
- **Authentication**: Firebase Auth Flutter plugin
- **UI Components**: Custom Material Design components

### Key Services
- **FirebaseDataService**: Centralized data management and synchronization
- **NotificationService**: Real-time notifications and updates
- **GoogleMapsService**: Maps and location services integration
- **AuthService**: User authentication and session management
- **OrderService**: Order processing and management
- **ProductService**: Product catalog and management

## 🚨 Troubleshooting

### Common Issues

#### Firebase Connection Errors
- Verify Firebase project configuration in `firebase_options.dart`
- Check if Firebase project is active and billing is enabled
- Ensure Firestore security rules are properly configured
- Verify Firebase Authentication providers are enabled

#### Frontend Compilation Errors
- Run `flutter clean` and `flutter pub get` to refresh dependencies
- Verify Firebase configuration in `firebase_options.dart`
- Check Google Maps API key configuration
- Ensure all required permissions are set in Android/iOS configs

#### Authentication Issues
- Verify Firebase project ID matches configuration
- Check if user collections exist in Firestore
- Verify phone number format (with country code)
- Check Firebase Authentication rules and settings

### Debug Commands
```bash
# Flutter doctor
flutter doctor -v

# Check Firebase connection
firebase projects:list

# Check Firestore data
firebase firestore:get

# Flutter clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📊 Monitoring & Analytics

### Firebase Console
- **Project Dashboard**: Overview of all services
- **Authentication**: User management and sessions
- **Firestore**: Database collections and documents
- **Analytics**: App usage and performance metrics
- **Crashlytics**: Error tracking and reporting

### App Monitoring
- **Firebase Analytics**: User behavior and app performance
- **Crashlytics**: Error tracking and reporting
- **Performance Monitoring**: App performance metrics
- **User Activity**: Authentication and usage patterns

## 🔒 Security

### Firebase Security Rules
- **User Data**: Users can only access their own data
- **Vendor Data**: Vendors can access their products, orders, and analytics
- **Driver Data**: Drivers can access their location and assigned orders
- **Admin Access**: System-wide data access for administrators
- **Data Validation**: Input sanitization and validation

### API Security
- **Firebase Authentication**: Secure user authentication
- **Firestore Security Rules**: Database access control
- **Cloud Functions**: Server-side validation and processing
- **Input Validation**: Request data sanitization and validation

## 🚀 Deployment

### Production Environment
- **Frontend**: Build and deploy to app stores (Google Play, App Store)
- **Firebase**: Production project with proper billing and quotas
- **Google Maps**: Production API key with appropriate quotas
- **Web**: Deploy to Firebase Hosting or other web hosting services

### Environment Variables
- **Firebase**: Production project configuration
- **Google Maps**: Production API key with billing
- **Notifications**: Production FCM configuration

### Build Commands
```bash
# Flutter Web Build
flutter build web --release

# Flutter Android Build
flutter build apk --release

# Flutter iOS Build
flutter build ios --release

# Deploy to Firebase Hosting
firebase deploy
```

## 📚 Additional Resources

### Documentation
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Platform](https://developers.google.com/maps)
- [Flutter Documentation](https://flutter.dev/docs)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)

### Support
- **Issues**: Check existing GitHub issues and create new ones
- **Documentation**: Review project documentation files
- **Firebase Support**: Google Firebase support portal
- **Google Maps Support**: Google Cloud support
- **Flutter Community**: Flutter forums and community

## 🤝 Contributing

### Development Guidelines
1. **Use Flutter best practices** for frontend development
2. **Maintain Firebase security rules** for data protection
3. **Test thoroughly** before submitting changes
4. **Document new features** and API endpoints
5. **Follow coding standards** and style guides

### Code Standards
- **Dart**: Flutter style guide and best practices
- **Firebase**: Security rules and data structure best practices
- **Database**: Firestore best practices and optimization
- **Security**: Firebase security guidelines

### Testing
- **Frontend**: Flutter widget tests and integration tests
- **Firebase**: Firestore security rules testing
- **Database**: Database structure and query testing

## 📄 License

This project is proprietary software developed by Telesphore Uwabera. All rights reserved.

## 📞 Contact

- **Developer**: Telesphore Uwabera
- **GitHub**: [@Telesphore-Uwabera](https://github.com/Telesphore-Uwabera)
- **Project**: [Classy-Apps](https://github.com/Telesphore-Uwabera/Classy-Apps)

---

**Last Updated**: January 2025  
**Version**: 2.0.0  
**Platform**: Flutter + Firebase  
**Status**: Active Development