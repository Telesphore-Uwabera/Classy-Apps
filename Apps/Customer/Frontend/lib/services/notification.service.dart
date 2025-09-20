import 'package:Classy/models/api_response.dart';
import 'package:Classy/models/app_notification.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase_notification.service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Base URL for notification endpoints
  static const String _baseUrl = 'http://localhost:8000/api/notifications';

  // Firebase notification service
  final FirebaseNotificationService _firebaseService = FirebaseNotificationService();

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

  // Timer for periodic updates
  Timer? _updateTimer;

  /// Initialize notification service
  void initialize() {
    // Initialize Firebase service
    _firebaseService.initialize();
    
    // Connect Firebase streams to local streams
    _firebaseService.notificationsStream.listen((notifications) {
      _cachedNotifications = notifications;
      _notificationsController.add(notifications);
    });
    
    _firebaseService.unreadCountStream.listen((count) {
      _cachedUnreadCount = count;
      _unreadCountController.add(count);
    });
    
    _firebaseService.newNotificationStream.listen((notification) {
      _newNotificationController.add(notification);
    });
    
    // Start periodic updates as fallback
    _startPeriodicUpdates();
    
    // Load initial data
    _loadInitialData();
  }

  /// Start periodic updates for notifications
  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshNotifications();
      _refreshUnreadCount();
    });
  }

  /// Load initial notification data
  Future<void> _loadInitialData() async {
    await Future.wait([
      _refreshNotifications(),
      _refreshUnreadCount(),
    ]);
  }

  /// Get user notifications
  Future<ApiResponse> getNotifications({
    int limit = 20,
    int offset = 0,
    String? type,
    bool unreadOnly = false,
  }) async {
    try {
      // Try Firebase first
      final firebaseResponse = await _firebaseService.getNotifications(
        limit: limit,
        offset: offset,
        type: type,
        unreadOnly: unreadOnly,
      );
      
      if (firebaseResponse.code == 200) {
        return firebaseResponse;
      }
      
      // Fallback to HTTP API
      final token = await AuthServices.getAuthBearerToken();
      
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (type != null) queryParams['type'] = type;
      if (unreadOnly) queryParams['unread_only'] = 'true';
      
      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: queryParams),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apiResponse = ApiResponse(
          code: 200,
          message: data['message'] ?? 'Notifications fetched successfully',
          body: data,
          errors: null,
        );
        
        // Update cache and streams
        if (offset == 0) {
          _cachedNotifications = _parseNotifications(data['body']['notifications'] ?? []);
          _notificationsController.add(_cachedNotifications);
        }
        
        return apiResponse;
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to fetch notifications',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
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
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/unread-count'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apiResponse = ApiResponse(
          code: 200,
          message: data['message'] ?? 'Unread count fetched successfully',
          body: data,
          errors: null,
        );
        
        // Update cache and stream
        _cachedUnreadCount = data['body']['unread_count'] ?? 0;
        _unreadCountController.add(_cachedUnreadCount);
        
        return apiResponse;
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to fetch unread count',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
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
      // Try Firebase first
      final firebaseResponse = await _firebaseService.markAsRead(notificationId);
      if (firebaseResponse.code == 200) {
        return firebaseResponse;
      }
      
      // Fallback to HTTP API
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/$notificationId/read'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        // Update local cache
        _updateNotificationReadStatus(notificationId, true);
        
        // Refresh unread count
        _refreshUnreadCount();
        
        return ApiResponse(
          code: 200,
          message: 'Notification marked as read',
          body: jsonDecode(response.body),
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to mark notification as read',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
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
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/mark-multiple-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'notification_ids': notificationIds}),
      );
      
      if (response.statusCode == 200) {
        // Update local cache
        for (final id in notificationIds) {
          _updateNotificationReadStatus(id, true);
        }
        
        // Refresh unread count
        _refreshUnreadCount();
        
        return ApiResponse(
          code: 200,
          message: 'Notifications marked as read',
          body: jsonDecode(response.body),
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to mark notifications as read',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
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
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/mark-all-read'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
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
          body: jsonDecode(response.body),
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to mark all notifications as read',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
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
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/$notificationId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        // Update local cache
        _cachedNotifications.removeWhere((n) => n.id == notificationId);
        _notificationsController.add(_cachedNotifications);
        
        // Refresh unread count
        _refreshUnreadCount();
        
        return ApiResponse(
          code: 200,
          message: 'Notification deleted successfully',
          body: jsonDecode(response.body),
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to delete notification',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to delete notification: $e',
        body: null,
        errors: ['Failed to delete notification: $e'],
      );
    }
  }

  /// Delete multiple notifications
  Future<ApiResponse> deleteMultipleNotifications(List<int> notificationIds) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete-multiple'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'notification_ids': notificationIds}),
      );
      
      if (response.statusCode == 200) {
        // Update local cache
        _cachedNotifications.removeWhere((n) => notificationIds.contains(n.id));
        _notificationsController.add(_cachedNotifications);
        
        // Refresh unread count
        _refreshUnreadCount();
        
        return ApiResponse(
          code: 200,
          message: 'Notifications deleted successfully',
          body: jsonDecode(response.body),
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to delete notifications',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to delete notifications: $e',
        body: null,
        errors: ['Failed to delete notifications: $e'],
      );
    }
  }

  /// Clear all notifications
  Future<ApiResponse> clearAllNotifications() async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/clear-all'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        // Update local cache
        _cachedNotifications.clear();
        _notificationsController.add(_cachedNotifications);
        _unreadCountController.add(0);
        
        return ApiResponse(
          code: 200,
          message: 'All notifications cleared successfully',
          body: jsonDecode(response.body),
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to clear notifications',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to clear notifications: $e',
        body: null,
        errors: ['Failed to clear notifications: $e'],
      );
    }
  }

  /// Get notification settings
  Future<ApiResponse> getNotificationSettings() async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/settings'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Settings fetched successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to fetch settings',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch settings: $e',
        body: null,
        errors: ['Failed to fetch settings: $e'],
      );
    }
  }

  /// Update notification settings
  Future<ApiResponse> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.put(
        Uri.parse('$_baseUrl/settings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(settings),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Settings updated successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to update settings',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to update settings: $e',
        body: null,
        errors: ['Failed to update settings: $e'],
      );
    }
  }

  /// Test notification
  Future<ApiResponse> testNotification() async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/test'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Test notification sent successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to send test notification',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to send test notification: $e',
        body: null,
        errors: ['Failed to send test notification: $e'],
      );
    }
  }

  /// Get notification statistics
  Future<ApiResponse> getNotificationStats() async {
    try {
      final token = await AuthServices.getAuthBearerToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          code: 200,
          message: data['message'] ?? 'Statistics fetched successfully',
          body: data,
          errors: null,
        );
      } else {
        return ApiResponse(
          code: response.statusCode,
          message: 'Failed to fetch statistics',
          body: null,
          errors: ['HTTP ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse(
        code: 500,
        message: 'Failed to fetch statistics: $e',
        body: null,
        errors: ['Failed to fetch statistics: $e'],
      );
    }
  }

  /// Refresh notifications from server
  Future<void> _refreshNotifications() async {
    try {
      final response = await getNotifications(limit: 20, offset: 0);
      if (response.code == 200) {
        // Data already updated in getNotifications method
      }
    } catch (e) {
      print('Failed to refresh notifications: $e');
    }
  }

  /// Refresh unread count from server
  Future<void> _refreshUnreadCount() async {
    try {
      final response = await getUnreadCount();
      if (response.code == 200) {
        // Data already updated in getUnreadCount method
      }
    } catch (e) {
      print('Failed to refresh unread count: $e');
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

  /// Parse notifications from JSON
  List<AppNotification> _parseNotifications(List<dynamic> jsonList) {
    return jsonList.map((json) => AppNotification.fromJson(json)).toList();
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
    _updateTimer?.cancel();
    _notificationsController.close();
    _unreadCountController.close();
    _newNotificationController.close();
  }
}
