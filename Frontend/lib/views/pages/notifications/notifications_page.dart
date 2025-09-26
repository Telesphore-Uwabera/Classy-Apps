import 'package:flutter/material.dart';
import 'package:Classy/services/notification.service.dart';
import 'package:Classy/models/app_notification.dart';
import 'package:Classy/widgets/notification_list_item.dart';
import 'package:Classy/widgets/notification_badge.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();
  
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _hasMore = false;
  int _currentOffset = 0;
  static const int _limit = 20;
  
  String? _selectedType;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentOffset = 0;
        _notifications.clear();
      });
    }

    setState(() => _isLoading = true);

    try {
      final response = await _notificationService.getNotifications(
        limit: _limit,
        offset: _currentOffset,
        type: _selectedType,
        unreadOnly: _showUnreadOnly,
      );

      if (response.code == 200 && response.body != null) {
        final data = response.body;
        final newNotifications = (data['notifications'] as List)
            .map((json) => AppNotification.fromJson(json))
            .toList();

        setState(() {
          if (refresh) {
            _notifications = newNotifications;
          } else {
            _notifications.addAll(newNotifications);
          }
          _hasMore = data['has_more'] ?? false;
          _currentOffset = _notifications.length;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to load notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreNotifications() async {
    await _loadNotifications(refresh: false);
  }

  Future<void> _markAsRead(AppNotification notification) async {
    try {
      final response = await _notificationService.markAsRead(notification.id);
      if (response.code == 200) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(
              readAt: DateTime.now(),
            );
          }
        });
      }
    } catch (e) {
      _showSnackBar('Failed to mark as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _notificationService.markAllAsRead();
      if (response.code == 200) {
        setState(() {
          for (int i = 0; i < _notifications.length; i++) {
            if (_notifications[i].readAt == null) {
              _notifications[i] = _notifications[i].copyWith(
                readAt: DateTime.now(),
              );
            }
          }
        });
        _showSnackBar('All notifications marked as read');
      }
    } catch (e) {
      _showSnackBar('Failed to mark all as read: $e');
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    try {
      final response = await _notificationService.deleteNotification(notification.id);
      if (response.code == 200) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        _showSnackBar('Notification deleted');
      }
    } catch (e) {
      _showSnackBar('Failed to delete notification: $e');
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _notificationService.clearAllNotifications();
        if (response.code == 200) {
          setState(() {
            _notifications.clear();
            _hasMore = false;
            _currentOffset = 0;
          });
          _showSnackBar('All notifications cleared');
        }
      } catch (e) {
        _showSnackBar('Failed to clear notifications: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _markAsRead(notification);
    }
    
    // Handle navigation based on notification type
    if (notification.actionUrl != null) {
      // Navigate to the action URL
      // This would typically use your app's navigation system
      print('Navigate to: ${notification.actionUrl}');
    }
  }

  void _onNotificationAction(AppNotification notification) {
    if (notification.actionUrl != null) {
      // Navigate to the action URL
      print('Action: ${notification.actionUrl}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'clear_all':
                  _clearAllNotifications();
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/notification-settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 8),
                    Text('Mark All as Read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadNotifications(refresh: true),
              child: _isLoading && _notifications.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationList(
                      notifications: _notifications,
                      onNotificationTap: _onNotificationTap,
                      onNotificationAction: _onNotificationAction,
                      onNotificationDelete: _deleteNotification,
                      scrollController: _scrollController,
                    ),
            ),
          ),
          if (_isLoading && _notifications.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                const DropdownMenuItem(value: 'order', child: Text('Orders')),
                const DropdownMenuItem(value: 'transport', child: Text('Transport')),
                const DropdownMenuItem(value: 'promotional', child: Text('Promotional')),
                const DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                _loadNotifications(refresh: true);
              },
            ),
          ),
          const SizedBox(width: 16),
          FilterChip(
            label: const Text('Unread Only'),
            selected: _showUnreadOnly,
            onSelected: (value) {
              setState(() => _showUnreadOnly = value);
              _loadNotifications(refresh: true);
            },
          ),
        ],
      ),
    );
  }
}
