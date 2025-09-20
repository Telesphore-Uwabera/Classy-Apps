import 'package:flutter/material.dart';
import 'package:Classy/models/app_notification.dart';

class NotificationListItem extends StatelessWidget {
  final AppNotification notification;
  final void Function(AppNotification)? onTap;
  final void Function(AppNotification)? onAction;
  final void Function(AppNotification)? onDelete;
  final bool showDeleteButton;

  const NotificationListItem({
    Key? key,
    required this.notification,
    this.onTap,
    this.onAction,
    this.onDelete,
    this.showDeleteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? Colors.grey.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead 
              ? Colors.grey.withOpacity(0.2)
              : _getBorderColor(context),
          width: 1,
        ),
        boxShadow: notification.isRead 
            ? []
            : [
                BoxShadow(
                  color: _getBorderColor(context).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? () => onTap!(notification) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead 
                                    ? FontWeight.normal 
                                    : FontWeight.bold,
                                fontSize: 16,
                                color: notification.isRead 
                                    ? Colors.grey 
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getBorderColor(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: notification.isRead 
                              ? Colors.grey 
                              : Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                                                     if (notification.isActionable && onAction != null)
                             TextButton(
                               onPressed: () => onAction!(notification),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                notification.actionText,
                                style: TextStyle(
                                  color: _getBorderColor(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                                 if (showDeleteButton && onDelete != null)
                   IconButton(
                     onPressed: () => onDelete!(notification),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getBorderColor(null).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        Icons.notifications,
        color: _getBorderColor(null),
        size: 24,
      ),
    );
  }

  String _getIconCode() {
    switch (notification.icon) {
      case 'shopping_cart':
        return '156';
      case 'local_taxi':
        return 'e531';
      case 'local_offer':
        return 'e54e';
      case 'notifications':
        return '7f4e';
      default:
        return '7f4e';
    }
  }

  Color _getBorderColor(BuildContext? context) {
    switch (notification.color) {
      case 'success':
        return Colors.green;
      case 'danger':
        return Colors.red;
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'primary':
        return context != null 
            ? Theme.of(context).primaryColor 
            : Colors.blue;
      case 'secondary':
        return Colors.grey;
      default:
        return context != null 
            ? Theme.of(context).primaryColor 
            : Colors.blue;
    }
  }
}

class NotificationList extends StatelessWidget {
  final List<AppNotification> notifications;
  final void Function(AppNotification)? onNotificationTap;
  final void Function(AppNotification)? onNotificationAction;
  final void Function(AppNotification)? onNotificationDelete;
  final bool showDeleteButton;
  final ScrollController? scrollController;

  const NotificationList({
    Key? key,
    required this.notifications,
    this.onNotificationTap,
    this.onNotificationAction,
    this.onNotificationDelete,
    this.showDeleteButton = true,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationListItem(
          notification: notification,
          onTap: onNotificationTap,
          onAction: onNotificationAction,
          onDelete: onNotificationDelete,
          showDeleteButton: showDeleteButton,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see important updates here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
