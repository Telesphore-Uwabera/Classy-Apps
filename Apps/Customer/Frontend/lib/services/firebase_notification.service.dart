import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Classy/models/api_response.dart';
import 'package:Classy/models/app_notification.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase_data.service.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDataService _firebaseDataService = FirebaseDataService();

  // Stream controllers for real-time notifications
  final StreamController<List<AppNotification>> _notificationsController = StreamController<List<AppNotification>>.broadcast();
  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();
  final StreamController<AppNotification> _newNotificationController = StreamController<AppNotification>.broadcast();

  // Streams for listening to notifications
  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  Stream<AppNotification> get newNotificationStream => _newNotificationController.stream;

  // Cache for notifications
  List<AppNotification> _cachedNotifications = [];
  int _cachedUnreadCount = 0;

  // Stream subscription for real-time updates
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;

  /// Initialize notification service
  void initialize() {
    _startRealTimeUpdates();
  }

  /// Start real-time updates for notifications
  void _startRealTimeUpdates() {
    final currentUser = AuthServices.currentUser;
    if (currentUser?.id == null) return;

    _notificationsSubscription?.cancel();
    _notificationsSubscription = _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: currentUser!.id.toString())
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _cachedNotifications = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data()))
          .toList();
      
      _notificationsController.add(_cachedNotifications);
      
      // Update unread count
      _cachedUnreadCount = _cachedNotifications.where((n) => !n.isRead).length;
      _unreadCountController.add(_cachedUnreadCount);
    });
  }

  /// Get user notifications
  Future<ApiResponse> getNotifications({
    int limit = 20,
    int offset = 0,
    String? type,
    bool unreadOnly = false,
  }) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      Query query = _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: currentUser!.id.toString())
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (unreadOnly) {
        query = query.where('is_read', isEqualTo: false);
      }

      final snapshot = await query.get();
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return ApiResponse(
        code: 200,
        message: 'Notifications fetched successfully',
        body: {'notifications': notifications},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch notifications: $e',
        body: null,
        errors: ['Failed to fetch notifications: $e'],
      );
    }
  }

  /// Get unread notifications count
  Future<ApiResponse> getUnreadCount() async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final snapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: currentUser!.id.toString())
          .where('is_read', isEqualTo: false)
          .get();

      final unreadCount = snapshot.docs.length;

      return ApiResponse(
        code: 200,
        message: 'Unread count fetched successfully',
        body: {'unread_count': unreadCount},
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch unread count: $e',
        body: null,
        errors: ['Failed to fetch unread count: $e'],
      );
    }
  }

  /// Mark notification as read
  Future<ApiResponse> markAsRead(int notificationId) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      await _firestore
          .collection('notifications')
          .doc(notificationId.toString())
          .update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      });

      // Update local cache
      _updateNotificationReadStatus(notificationId, true);

      return ApiResponse(
        code: 200,
        message: 'Notification marked as read',
        body: null,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to mark notification as read: $e',
        body: null,
        errors: ['Failed to mark notification as read: $e'],
      );
    }
  }

  /// Mark multiple notifications as read
  Future<ApiResponse> markMultipleAsRead(List<int> notificationIds) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final batch = _firestore.batch();
      for (final id in notificationIds) {
        batch.update(
          _firestore.collection('notifications').doc(id.toString()),
          {
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          },
        );
      }
      await batch.commit();

      // Update local cache
      for (final id in notificationIds) {
        _updateNotificationReadStatus(id, true);
      }

      return ApiResponse(
        code: 200,
        message: 'Notifications marked as read',
        body: null,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to mark notifications as read: $e',
        body: null,
        errors: ['Failed to mark notifications as read: $e'],
      );
    }
  }

  /// Mark all notifications as read
  Future<ApiResponse> markAllAsRead() async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final snapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: currentUser!.id.toString())
          .where('is_read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();

      // Update local cache
      for (int i = 0; i < _cachedNotifications.length; i++) {
        _cachedNotifications[i] = _cachedNotifications[i].copyWith(
          readAt: DateTime.now(),
        );
      }

      // Update streams
      _notificationsController.add(_cachedNotifications);
      _unreadCountController.add(0);

      return ApiResponse(
        code: 200,
        message: 'All notifications marked as read',
        body: null,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to mark all notifications as read: $e',
        body: null,
        errors: ['Failed to mark all notifications as read: $e'],
      );
    }
  }

  /// Delete notification
  Future<ApiResponse> deleteNotification(int notificationId) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      await _firestore
          .collection('notifications')
          .doc(notificationId.toString())
          .delete();

      // Update local cache
      _cachedNotifications.removeWhere((n) => n.id == notificationId);
      _notificationsController.add(_cachedNotifications);

      // Refresh unread count
      _cachedUnreadCount = _cachedNotifications.where((n) => !n.isRead).length;
      _unreadCountController.add(_cachedUnreadCount);

      return ApiResponse(
        code: 200,
        message: 'Notification deleted successfully',
        body: null,
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to delete notification: $e',
        body: null,
        errors: ['Failed to delete notification: $e'],
      );
    }
  }

  /// Create notification
  Future<ApiResponse> createNotification({
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) {
        return ApiResponse(code: 401, message: "User not authenticated");
      }

      final notification = await _firebaseDataService.createNotification({
        'user_id': currentUser!.id.toString(),
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
      });

      return ApiResponse(
        code: 200,
        message: 'Notification created successfully',
        body: notification.toJson(),
        errors: null,
      );
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to create notification: $e',
        body: null,
        errors: ['Failed to create notification: $e'],
      );
    }
  }

  /// Update notification read status in cache
  void _updateNotificationReadStatus(int notificationId, bool isRead) {
    final index = _cachedNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _cachedNotifications[index] = _cachedNotifications[index].copyWith(
        readAt: isRead ? DateTime.now() : null,
      );
      _notificationsController.add(_cachedNotifications);
    }
  }

  /// Add new notification to stream (for real-time updates)
  void addNewNotification(AppNotification notification) {
    _cachedNotifications.insert(0, notification);
    _notificationsController.add(_cachedNotifications);
    
    if (!notification.isRead) {
      _cachedUnreadCount++;
      _unreadCountController.add(_cachedUnreadCount);
    }
    
    // Emit new notification event
    _newNotificationController.add(notification);
  }

  /// Get cached notifications
  List<AppNotification> get cachedNotifications => _cachedNotifications;

  /// Get cached unread count
  int get cachedUnreadCount => _cachedUnreadCount;

  /// Dispose resources
  void dispose() {
    _notificationsSubscription?.cancel();
    _notificationsController.close();
    _unreadCountController.close();
    _newNotificationController.close();
  }
}
