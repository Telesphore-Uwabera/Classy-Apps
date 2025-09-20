import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/app_notification.dart';
import 'firebase_service.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  final FirebaseService _firebaseService = FirebaseService.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(initSettings);
      
      // Request permission for notifications
      await _requestPermission();
      
      // Configure Firebase messaging
      await _configureFirebaseMessaging();
      
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  // Request notification permission
  Future<bool> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  // Configure Firebase messaging
  Future<void> _configureFirebaseMessaging() async {
    try {
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
    } catch (e) {
      print('Error configuring Firebase messaging: $e');
    }
  }

  // Get notifications for vendor
  Future<List<AppNotification>> getNotifications(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.getCollectionWhere('notifications', 'vendorId', vendorId);
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return AppNotification.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firebaseService.updateDocument('notifications', notificationId, {
        'isRead': true,
        'readAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead(String vendorId) async {
    try {
      final notifications = await getNotifications(vendorId);
      final unreadNotifications = notifications.where((n) => !n.isRead).toList();
      
      for (final notification in unreadNotifications) {
        await markAsRead(notification.id);
      }
      
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firebaseService.deleteDocument('notifications', notificationId);
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String vendorId) async {
    try {
      final notifications = await getNotifications(vendorId);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Stream notifications for real-time updates
  Stream<List<AppNotification>> streamNotifications(String vendorId) {
    return _firebaseService.firestore
        .collection('notifications')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AppNotification.fromMap(data);
      }).toList();
    });
  }

  // Send local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'vendor_channel',
        'Vendor Notifications',
        channelDescription: 'Notifications for vendor app',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // Create notification
  Future<bool> createNotification(AppNotification notification) async {
    try {
      await _firebaseService.setDocument('notifications', notification.id, notification.toMap());
      return true;
    } catch (e) {
      print('Error creating notification: $e');
      return false;
    }
  }

  // Subscribe to vendor topic
  Future<void> subscribeToVendorTopic(String vendorId) async {
    try {
      await _firebaseMessaging.subscribeToTopic('vendor_$vendorId');
    } catch (e) {
      print('Error subscribing to vendor topic: $e');
    }
  }

  // Unsubscribe from vendor topic
  Future<void> unsubscribeFromVendorTopic(String vendorId) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('vendor_$vendorId');
    } catch (e) {
      print('Error unsubscribing from vendor topic: $e');
    }
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? 'You have a new notification';
      
      showLocalNotification(
        title: title,
        body: body,
        payload: message.data.toString(),
      );
    } catch (e) {
      print('Error handling foreground message: $e');
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    try {
      // Handle notification tap - navigate to relevant screen
      print('Notification tapped: ${message.data}');
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    print('Handling background message: ${message.messageId}');
  } catch (e) {
    print('Error handling background message: $e');
  }
}
