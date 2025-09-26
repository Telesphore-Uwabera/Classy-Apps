import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseService {
  static FirebaseService? _instance;
  FirebaseMessaging? _firebaseMessaging;
  
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }
  
  FirebaseService._();
  
  FirebaseMessaging get firebaseMessaging {
    _firebaseMessaging ??= FirebaseMessaging.instance;
    return _firebaseMessaging!;
  }
  
  Future<void> setUpFirebaseMessaging() async {
    if (kIsWeb) return;
    
    try {
      // Request permission for notifications
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print("🔔 Notification permission status: ${settings.authorizationStatus}");
      
      // Get FCM token
      String? token = await firebaseMessaging.getToken();
      print("🔔 FCM Token: $token");
      
    } catch (e) {
      print("❌ Firebase messaging setup error: $e");
    }
  }
  
  Future<void> saveNewNotification(RemoteMessage message) async {
    print("📱 Saving new notification: ${message.messageId}");
  }
  
  Future<void> showNotification(RemoteMessage message) async {
    print("📱 Showing notification: ${message.notification?.title}");
  }
  
  void selectNotification(String payload) {
    print("📱 Notification selected with payload: $payload");
  }
  
  Map<String, dynamic>? notificationPayloadData;
}