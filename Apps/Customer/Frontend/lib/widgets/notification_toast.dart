import 'package:flutter/material.dart';
import 'package:Classy/models/app_notification.dart';
import 'dart:async';

class NotificationToast extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final Duration duration;
  final bool autoDismiss;

  const NotificationToast({
    Key? key,
    required this.notification,
    this.onAction,
    this.onDismiss,
    this.duration = const Duration(seconds: 4),
    this.autoDismiss = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getToastColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (notification.isActionable && onAction != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    notification.actionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        IconData(
          int.parse('0xe${_getIconCode()}'),
          fontFamily: 'MaterialIcons',
        ),
        color: Colors.white,
        size: 20,
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

  Color _getToastColor(BuildContext context) {
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
        return Theme.of(context).primaryColor;
      case 'secondary':
        return Colors.grey;
      default:
        return Theme.of(context).primaryColor;
    }
  }
}

class NotificationToastOverlay {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    AppNotification notification, {
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    hide();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: NotificationToast(
          notification: notification,
          onAction: onAction,
          onDismiss: hide,
          duration: duration,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    if (duration.inMilliseconds > 0) {
      _timer = Timer(duration, hide);
    }
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
