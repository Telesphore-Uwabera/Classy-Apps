import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart' hide NotificationModel;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../models/notification.dart';
import 'auth.service.dart';
import 'local_storage.service.dart';
import 'package:singleton/singleton.dart';

class DriverNotificationService {
  /// Factory method that reuse same instance automatically
  factory DriverNotificationService() => Singleton.lazy(() => DriverNotificationService._());

  /// Private constructor
  DriverNotificationService._() {}

  /// Static instance getter
  static DriverNotificationService get instance => DriverNotificationService();

  static const platform = MethodChannel('awesome_notifications');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final DriverFirebaseService _driverFirebaseService = DriverFirebaseService(); // Unused for now

  // ========================================
  // NOTIFICATION INITIALIZATION
  // ========================================

  /// Initialize notification system
  static Future<void> initializeDriverNotifications() async {
    // Don't initialize on web
    if (kIsWeb) return;
    
    try {
      await AwesomeNotifications().initialize(
        null, // null for default app icon
        [
          _appNotificationChannel(),
          _newOrderNotificationChannel(),
          _earningsNotificationChannel(),
          _emergencyNotificationChannel(),
        ],
      );
    } catch (e) {
      print('Error initializing driver notifications: $e');
    }
  }

  /// Request notification permissions
  static Future<void> requestNotificationPermissions() async {
    // Don't request permissions on web
    if (kIsWeb) return;
    
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  // ========================================
  // NOTIFICATION CHANNELS
  // ========================================

  static NotificationChannel _appNotificationChannel() {
    return NotificationChannel(
      channelKey: 'driver_basic_channel',
      channelName: 'Driver App Notifications',
      channelDescription: 'General notifications for driver app',
      importance: NotificationImportance.High,
      playSound: true,
    );
  }

  static NotificationChannel _newOrderNotificationChannel() {
    return NotificationChannel(
      channelKey: 'driver_new_order_channel',
      channelName: 'New Order Notifications',
      channelDescription: 'Notifications for new order assignments',
      importance: NotificationImportance.Max,
      playSound: true,
    );
  }

  static NotificationChannel _earningsNotificationChannel() {
    return NotificationChannel(
      channelKey: 'driver_earnings_channel',
      channelName: 'Earnings Notifications',
      channelDescription: 'Notifications about earnings and payouts',
      importance: NotificationImportance.High,
      playSound: true,
    );
  }

  static NotificationChannel _emergencyNotificationChannel() {
    return NotificationChannel(
      channelKey: 'driver_emergency_channel',
      channelName: 'Emergency Notifications',
      channelDescription: 'Emergency and safety notifications',
      importance: NotificationImportance.Max,
      playSound: true,
    );
  }

  // ========================================
  // FIREBASE MESSAGING SETUP
  // ========================================

  /// Set up Firebase messaging for driver
  Future<void> setupFirebaseMessaging() async {
    if (kIsWeb) return;

    try {
      // Request permission
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Set foreground notification presentation options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Subscribe to driver-specific topics
      await _subscribeToDriverTopics();

      // Set up message handlers
      _setupMessageHandlers();
    } catch (e) {
      print('Error setting up Firebase messaging: $e');
    }
  }

  /// Subscribe to driver-specific topics
  Future<void> _subscribeToDriverTopics() async {
    try {
      final user = await AuthServices.getCurrentUser();
      if (user != null) {
        // Subscribe to general topics
        await _firebaseMessaging.subscribeToTopic('all');
        await _firebaseMessaging.subscribeToTopic('drivers');
        await _firebaseMessaging.subscribeToTopic('driver_${user.id}');
        
        // Subscribe to service type specific topics
        if (user.role != null) {
          await _firebaseMessaging.subscribeToTopic('driver_${user.role}');
        }
      }
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  /// Set up message handlers
  void _setupMessageHandlers() {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    _handleInitialMessage();
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    // Save notification to local storage
    await _saveNotification(message);
    
    // Show notification
    await _showNotification(message);
    
    // Handle specific notification types
    await _handleNotificationData(message.data);
  }

  /// Handle notification tap
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.messageId}');
    await _handleNotificationData(message.data);
  }

  /// Handle initial message (app was terminated)
  Future<void> _handleInitialMessage() async {
    final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      await _handleNotificationData(initialMessage.data);
    }
  }

  /// Handle notification data
  Future<void> _handleNotificationData(Map<String, dynamic> data) async {
    try {
      final notificationType = data['type'] ?? 'general';
      
      switch (notificationType) {
        case 'new_order':
          await _handleNewOrderNotification(data);
          break;
        case 'order_update':
          await _handleOrderUpdateNotification(data);
          break;
        case 'earnings':
          await _handleEarningsNotification(data);
          break;
        case 'emergency':
          await _handleEmergencyNotification(data);
          break;
        case 'chat':
          await _handleChatNotification(data);
          break;
        default:
          await _handleGeneralNotification(data);
      }
    } catch (e) {
      print('Error handling notification data: $e');
    }
  }

  // ========================================
  // NOTIFICATION TYPE HANDLERS
  // ========================================

  /// Handle new order notification
  Future<void> _handleNewOrderNotification(Map<String, dynamic> data) async {
    try {
      final orderId = data['order_id'];
      if (orderId != null) {
        // Navigate to order details or show order acceptance dialog
        print('New order notification: $orderId');
        // Implementation would depend on your navigation system
      }
    } catch (e) {
      print('Error handling new order notification: $e');
    }
  }

  /// Handle order update notification
  Future<void> _handleOrderUpdateNotification(Map<String, dynamic> data) async {
    try {
      final orderId = data['order_id'];
      final status = data['status'];
      print('Order update notification: $orderId - $status');
      // Refresh order list or navigate to updated order
    } catch (e) {
      print('Error handling order update notification: $e');
    }
  }

  /// Handle earnings notification
  Future<void> _handleEarningsNotification(Map<String, dynamic> data) async {
    try {
      final amount = data['amount'];
      final type = data['earning_type'];
      print('Earnings notification: $type - $amount');
      // Navigate to earnings page or show earnings summary
    } catch (e) {
      print('Error handling earnings notification: $e');
    }
  }

  /// Handle emergency notification
  Future<void> _handleEmergencyNotification(Map<String, dynamic> data) async {
    try {
      final message = data['message'];
      print('Emergency notification: $message');
      // Show emergency alert or navigate to emergency screen
    } catch (e) {
      print('Error handling emergency notification: $e');
    }
  }

  /// Handle chat notification
  Future<void> _handleChatNotification(Map<String, dynamic> data) async {
    try {
      final chatId = data['chat_id'];
      final senderId = data['sender_id'];
      print('Chat notification: $chatId from $senderId');
      // Navigate to chat screen
    } catch (e) {
      print('Error handling chat notification: $e');
    }
  }

  /// Handle general notification
  Future<void> _handleGeneralNotification(Map<String, dynamic> data) async {
    try {
      final title = data['title'];
      final body = data['body'];
      print('General notification: $title - $body');
      // Navigate to notifications page
    } catch (e) {
      print('Error handling general notification: $e');
    }
  }

  // ========================================
  // NOTIFICATION DISPLAY
  // ========================================

  /// Show notification
  Future<void> _showNotification(RemoteMessage message) async {
    if (kIsWeb) return;

    try {
      final notification = message.notification;
      if (notification == null) return;

      final channelKey = _getChannelKey(message.data['type'] ?? 'general');
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: channelKey,
          title: notification.title ?? 'Driver App',
          body: notification.body ?? '',
          payload: Map<String, String>.from(message.data),
          bigPicture: notification.android?.imageUrl,
          notificationLayout: notification.android?.imageUrl != null 
              ? NotificationLayout.BigPicture 
              : NotificationLayout.Default,
        ),
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  /// Get channel key based on notification type
  String _getChannelKey(String type) {
    switch (type) {
      case 'new_order':
        return 'driver_new_order_channel';
      case 'earnings':
        return 'driver_earnings_channel';
      case 'emergency':
        return 'driver_emergency_channel';
      default:
        return 'driver_basic_channel';
    }
  }

  // ========================================
  // NOTIFICATION STORAGE
  // ========================================

  /// Save notification to local storage
  Future<void> _saveNotification(RemoteMessage message) async {
    try {
      final notification = NotificationModel(
        index: DateTime.now().millisecondsSinceEpoch,
        title: message.notification?.title ?? message.data['title'] ?? '',
        body: message.notification?.body ?? message.data['body'] ?? '',
        timeStamp: DateTime.now().millisecondsSinceEpoch,
        read: false,
      );

      await _addNotificationToStorage(notification);
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  /// Add notification to local storage
  Future<void> _addNotificationToStorage(NotificationModel notification) async {
    try {
      final notifications = await getStoredNotifications();
      notifications.insert(0, notification);

      await LocalStorageService.prefs!.setString(
        'driver_notifications',
        jsonEncode(notifications.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      print('Error adding notification to storage: $e');
    }
  }

  /// Get stored notifications
  Future<List<NotificationModel>> getStoredNotifications() async {
    try {
      final notificationsString = LocalStorageService.prefs!.getString('driver_notifications');
      if (notificationsString == null) return [];

      final List<dynamic> notificationsJson = jsonDecode(notificationsString);
      return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting stored notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(int index) async {
    try {
      final notifications = await getStoredNotifications();
      if (index < notifications.length) {
        notifications[index].read = true;
        await LocalStorageService.prefs!.setString(
          'driver_notifications',
          jsonEncode(notifications.map((n) => n.toJson()).toList()),
        );
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await LocalStorageService.prefs!.remove('driver_notifications');
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // ========================================
  // NOTIFICATION ACTIONS
  // ========================================

  /// Set up notification action listeners
  static void setupNotificationActions() {
    if (kIsWeb) return;

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
    );
  }

  /// Handle notification action
  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(ReceivedAction receivedAction) async {
    try {
      final payload = receivedAction.payload;
      if (payload == null) return;

      final actionType = payload['action_type'] ?? 'default';
      
      switch (actionType) {
        case 'accept_order':
          await _handleAcceptOrderAction(payload);
          break;
        case 'reject_order':
          await _handleRejectOrderAction(payload);
          break;
        case 'view_order':
          await _handleViewOrderAction(payload);
          break;
        case 'open_chat':
          await _handleOpenChatAction(payload);
          break;
        default:
          await _handleDefaultAction(payload);
      }
    } catch (e) {
      print('Error handling notification action: $e');
    }
  }

  /// Handle accept order action
  static Future<void> _handleAcceptOrderAction(Map<String, String?> payload) async {
    try {
      final orderId = payload['order_id'];
      if (orderId != null) {
        // Implement order acceptance logic
        print('Accept order action: $orderId');
      }
    } catch (e) {
      print('Error handling accept order action: $e');
    }
  }

  /// Handle reject order action
  static Future<void> _handleRejectOrderAction(Map<String, String?> payload) async {
    try {
      final orderId = payload['order_id'];
      if (orderId != null) {
        // Implement order rejection logic
        print('Reject order action: $orderId');
      }
    } catch (e) {
      print('Error handling reject order action: $e');
    }
  }

  /// Handle view order action
  static Future<void> _handleViewOrderAction(Map<String, String?> payload) async {
    try {
      final orderId = payload['order_id'];
      if (orderId != null) {
        // Navigate to order details
        print('View order action: $orderId');
      }
    } catch (e) {
      print('Error handling view order action: $e');
    }
  }

  /// Handle open chat action
  static Future<void> _handleOpenChatAction(Map<String, String?> payload) async {
    try {
      final chatId = payload['chat_id'];
      if (chatId != null) {
        // Navigate to chat screen
        print('Open chat action: $chatId');
      }
    } catch (e) {
      print('Error handling open chat action: $e');
    }
  }

  /// Handle default action
  static Future<void> _handleDefaultAction(Map<String, String?> payload) async {
    try {
      // Navigate to notifications page or main screen
      print('Default action: ${payload.toString()}');
    } catch (e) {
      print('Error handling default action: $e');
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getStoredNotifications();
      return notifications.where((n) => !n.read).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Stream for unread notification count
  Stream<int> get unreadCountStream {
    return Stream.periodic(Duration(seconds: 5), (_) => getUnreadCount()).asyncMap((_) async => await getUnreadCount());
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    if (kIsWeb) return;

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'driver_basic_channel',
          title: 'Test Notification',
          body: 'This is a test notification for the driver app',
        ),
      );
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Handle background message processing here
}
