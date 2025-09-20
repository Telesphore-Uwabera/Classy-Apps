import 'package:flutter/material.dart';
import 'services/notification.service.dart';

class NotificationBadge extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showZero;

  const NotificationBadge({
    Key? key,
    this.size = 24.0,
    this.backgroundColor,
    this.textColor,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: NotificationService().unreadCountStream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        if (count == 0 && !showZero) {
          return const SizedBox.shrink();
        }

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.error,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? Theme.of(context).colorScheme.error).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class NotificationBadgeWithIcon extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double badgeSize;
  final Color? badgeColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const NotificationBadgeWithIcon({
    Key? key,
    required this.icon,
    this.iconSize = 24.0,
    this.badgeSize = 20.0,
    this.badgeColor,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? Theme.of(context).iconTheme.color,
          ),
          Positioned(
            right: 0,
            top: 0,
            child: NotificationBadge(
              size: badgeSize,
              backgroundColor: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
