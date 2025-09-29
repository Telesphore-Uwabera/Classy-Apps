import 'package:flutter/material.dart';
import 'package:Classy/models/app_notification.dart';

class NotificationBanner extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final bool showCloseButton;

  const NotificationBanner({
    Key? key,
    required this.notification,
    this.onAction,
    this.onDismiss,
    this.showCloseButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _getBannerColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    if (notification.isActionable && onAction != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: onAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _getBannerColor(context),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              notification.actionText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: onDismiss,
                            child: const Text(
                              'Dismiss',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (showCloseButton && onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 24,
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        IconData(
          int.parse('0xe${_getIconCode()}'),
          fontFamily: 'MaterialIcons',
        ),
        color: Colors.white,
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

  Color _getBannerColor(BuildContext context) {
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

class NotificationBannerOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context,
    AppNotification notification, {
    VoidCallback? onAction,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 8),
  }) {
    hide();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: NotificationBanner(
          notification: notification,
          onAction: onAction,
          onDismiss: () {
            hide();
            onDismiss?.call();
          },
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    if (duration.inMilliseconds > 0) {
      Future.delayed(duration, hide);
    }
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
