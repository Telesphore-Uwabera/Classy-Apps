# Firebase Setup for Classy Driver App

## 🔥 **Firebase Configuration Required**

The app is currently running with placeholder Firebase configuration. To enable full Firebase functionality (notifications, crashlytics, etc.), you need to:

### 1. **Create a Firebase Project**
- Go to [Firebase Console](https://console.firebase.google.com/)
- Create a new project named "classy-driver-app"
- Enable Authentication, Cloud Firestore, Cloud Messaging, and Crashlytics

### 2. **Add Web App to Firebase**
- In your Firebase project, click "Add app" → "Web"
- Register app with name "Classy Driver Web"
- Copy the configuration object

### 3. **Update Configuration Files**

#### Update `lib/firebase_options.dart`:
Replace the placeholder values with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  authDomain: 'YOUR_ACTUAL_AUTH_DOMAIN',
  storageBucket: 'YOUR_ACTUAL_STORAGE_BUCKET',
  measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID',
);
```

#### Update `web/index.html`:
Replace the placeholder Firebase config with your actual values:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",
  authDomain: "YOUR_ACTUAL_AUTH_DOMAIN",
  projectId: "YOUR_ACTUAL_PROJECT_ID",
  storageBucket: "YOUR_ACTUAL_STORAGE_BUCKET",
  messagingSenderId: "YOUR_ACTUAL_SENDER_ID",
  appId: "YOUR_ACTUAL_APP_ID"
};
```

### 4. **Enable Services**
- **Cloud Messaging**: Enable FCM for notifications
- **Crashlytics**: Enable for crash reporting
- **Authentication**: Set up sign-in methods if needed
- **Firestore**: Create database rules

### 5. **Test Configuration**
After updating the config:
1. Stop the current app
2. Run `flutter clean`
3. Run `flutter pub get`
4. Start the app again

## 🚀 **Current Status**
✅ App is running and showing splash screen  
✅ Basic Firebase structure is in place  
⚠️ Firebase needs real configuration to work properly  
⚠️ Placeholder values will cause Firebase errors  

## 📱 **Features Working**
- Splash screen with Classy branding
- Basic app structure
- Navigation framework
- UI components

## 🔧 **Features Pending Firebase**
- Push notifications
- Crash reporting
- User authentication
- Real-time data sync

---

**Note**: The app will continue to work for development and testing without Firebase, but notifications and crash reporting won't function.
