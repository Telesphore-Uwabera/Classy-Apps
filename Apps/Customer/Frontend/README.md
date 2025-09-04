# 🚀 Classy Customer App

A modern, feature-rich mobile application built with Flutter for food delivery, taxi services, and boda boda transportation.

## ✨ Features

### 🍕 Food Delivery
- **Restaurant Discovery**: Browse restaurants by category and location
- **Menu Management**: View detailed menus with prices and descriptions
- **Order Processing**: Add items to cart, checkout, and track orders
- **Real-time Updates**: Live order status and delivery tracking

### 🚗 Transportation Services
- **Taxi Booking**: Book rides with real-time driver tracking
- **Boda Boda**: Quick motorcycle transportation services
- **Location Services**: Pickup and destination management
- **Ride History**: Complete trip records and receipts

### 👤 User Management
- **Authentication**: Phone/email login with OTP verification
- **Profile Management**: Personal information and preferences
- **Address Book**: Save work and home locations
- **Payment Methods**: Multiple payment options including wallet

### 💬 Support & Communication
- **WhatsApp Integration**: Direct contact with customer support
- **Help System**: FAQ and issue reporting
- **Emergency Contacts**: Quick access to support and emergency numbers
- **Real-time Chat**: Customer service communication

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider + Stacked
- **UI Framework**: VelocityX
- **Localization**: localize_and_translate
- **HTTP Client**: Dio with caching
- **Location Services**: Geolocator
- **URL Launcher**: WhatsApp integration
- **Local Storage**: SharedPreferences

## 📱 Screenshots

### Main Features
- **Welcome Page**: App introduction and service selection
- **Food Page**: Restaurant browsing and food ordering
- **Taxi Page**: Ride booking with location search
- **Boda Page**: Motorcycle service booking
- **Help & Support**: Customer assistance and WhatsApp contact
- **Profile Management**: User settings and preferences

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Telesphore-Uwabera/Classy-Customer-App.git
   cd Classy-Customer-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

1. **Update app settings** in `lib/constants/app_strings.dart`
2. **Configure API endpoints** in `lib/constants/api.dart`
3. **Set up Firebase** (if using backend services)

## 📁 Project Structure

```
lib/
├── constants/          # App constants and configuration
├── models/            # Data models
├── services/          # Business logic and API services
├── utils/             # Utility functions
├── view_models/       # State management
├── views/             # UI screens and pages
│   ├── pages/         # Main app pages
│   ├── widgets/       # Reusable UI components
│   └── bottomsheets/  # Modal bottom sheets
└── main.dart          # App entry point
```

## 🔧 Key Components

### Services
- **LocationService**: GPS and location management
- **HttpService**: API communication with mock data support
- **LocalStorageService**: Persistent data storage
- **NotificationService**: Push notifications

### Pages
- **Welcome Page**: Main app entry point
- **Food Page**: Restaurant and food ordering
- **Taxi/Boda Pages**: Transportation services
- **Help & Support**: Customer assistance
- **Profile Pages**: User management

## 🌟 Key Features

### WhatsApp Integration
- **Direct Contact**: One-tap WhatsApp support
- **Phone Number**: +256 759 968209
- **Fallback Options**: Copy number to clipboard
- **Modal Interface**: Consistent with other support options

### Location Management
- **Work/Home Addresses**: Save frequent locations
- **GPS Integration**: Real-time location services
- **Address Search**: Location autocomplete
- **Route Planning**: Navigation assistance

### Mock Data System
- **Development Mode**: Run without backend
- **Sample Data**: Realistic food, restaurant, and ride data
- **Easy Switching**: Toggle between mock and real API
- **Testing Support**: Comprehensive test data

## 📊 App Configuration

### Environment Variables
- **API Base URL**: Configurable endpoints
- **Mock Data**: Enable/disable for development
- **App Settings**: Dynamic configuration loading
- **Localization**: Multi-language support

### Build Variants
- **Development**: Mock data enabled
- **Production**: Real API integration
- **Testing**: Comprehensive test suite

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **WhatsApp**: +256 759 968209
- **Email**: [Your Email]
- **GitHub Issues**: [Create an issue](https://github.com/Telesphore-Uwabera/Classy-Customer-App/issues)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- VelocityX for UI utilities
- All contributors and supporters

---

**Built with ❤️ by Telesphore Uwabera**

*Classy - Making Life Easier, One App at a Time*
