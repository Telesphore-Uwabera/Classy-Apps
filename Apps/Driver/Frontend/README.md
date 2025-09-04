# Classy Driver App

A comprehensive driver application built with Flutter, designed to connect service providers with opportunities.

## 🚗 Features

### Core Functionality
- **Multi-Service Support**: Car drivers, Boda riders, and Food vendors
- **Real-time Ride Management**: Accept/reject ride requests, track ongoing services
- **Location Services**: GPS tracking, navigation, and route optimization
- **Wallet Management**: Track earnings, withdrawals, and transaction history
- **Document Management**: Upload and verify driver documents
- **Emergency SOS**: Quick access to emergency support

### User Experience
- **Clean, Modern UI**: Classy's signature pink/magenta design system
- **Intuitive Navigation**: Bottom navigation with Home, Bookings, Wallet, and Profile
- **Responsive Design**: Optimized for various screen sizes
- **Dark/Light Themes**: Adaptive theme support

## 🎨 Design System

### Colors
- **Primary**: Vibrant Pink (#E91E63)
- **Secondary**: Purple (#9C27B0)
- **Success**: Green (#4CAF50)
- **Warning**: Orange (#FF9800)
- **Error**: Red (#F44336)
- **Info**: Blue (#2196F3)

### Typography
- **Font Family**: Nunito (Google Fonts)
- **Weight Scale**: Normal, Medium, Semi-Bold, Bold
- **Size Scale**: 12px to 32px

### Components
- **Cards**: Rounded corners (12px), subtle shadows
- **Buttons**: Rounded corners (8-12px), consistent padding
- **Inputs**: Filled style with rounded corners
- **Navigation**: Bottom navigation with active states

## 📱 App Structure

### Pages
- **Splash**: Brand introduction with gradient background
- **Onboarding**: Service type selection (Car, Boda, Food)
- **Service Type Selection**: Choose your service category
- **Home**: Main dashboard with ride requests and status
- **Bookings**: Active, completed, and cancelled services
- **Wallet**: Balance, transactions, and withdrawal options
- **Profile**: Quick actions, vehicle info, and settings

### Navigation
- **Bottom Navigation**: 4 main tabs with active states
- **Tab Navigation**: Within pages for different content sections
- **Modal Dialogs**: For confirmations and alerts

## 🛠 Technical Stack

### Frontend
- **Framework**: Flutter 3.7.2+
- **Language**: Dart
- **State Management**: Stacked architecture
- **UI Components**: Material Design 3
- **Navigation**: Custom routing system

### Dependencies
- **Maps**: Google Maps Flutter
- **Notifications**: Firebase Cloud Messaging
- **Authentication**: Firebase Auth
- **Storage**: Local storage, Firebase Firestore
- **Real-time**: WebSocket, Pusher support

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.2+
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase credentials
4. Set up Google Maps API key
5. Run the app: `flutter run`

### Configuration
- Update `lib/constants/app_strings.dart` for app branding
- Configure Firebase in `android/app/google-services.json`
- Set Google Maps API key in environment variables

## 📁 Project Structure

```
lib/
├── constants/           # App configuration
│   ├── app_colors.dart     # Color scheme
│   ├── app_strings.dart    # App strings and branding
│   ├── app_theme.dart      # Theme configuration
│   └── app_routes.dart     # Route definitions
├── views/              # UI screens
│   └── pages/             # Main app pages
│       ├── splash.page.dart
│       ├── onboarding.page.dart
│       ├── service_type_selection.page.dart
│       ├── home.page.dart
│       ├── bookings.page.dart
│       ├── wallet.page.dart
│       └── profile.page.dart
├── widgets/            # Reusable components
├── services/           # Business logic
├── models/             # Data models
└── main.dart          # App entry point
```

## 🔧 Customization

### Branding
- Update colors in `app_colors.dart`
- Modify app strings in `app_strings.dart`
- Change theme in `app_theme.dart`

### Features
- Add new service types in onboarding
- Extend wallet functionality
- Implement additional profile sections

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Responsive web support
- **Desktop**: Windows, macOS, Linux

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the terms specified in the license file.

## 🆘 Support

For support and questions:
- **Support Hotline**: +256 700 123456
- **Email**: support@classyprovider.com
- **Documentation**: [Link to docs]

---

**Classy Provider** - Connecting Providers to Opportunities
