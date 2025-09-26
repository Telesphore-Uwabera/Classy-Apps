import 'package:intl/intl.dart';

class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String type;
  final DateTime? readAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isRead => readAt != null;
  String get timeAgo => _getTimeAgo();
  String get formattedTime => _getFormattedTime();
  String get icon => _getIcon();
  String get color => _getColor();
  bool get isActionable => _isActionable();
  String get actionText => _getActionText();
  String? get actionUrl => _getActionUrl();
  bool get showAsBanner => _showAsBanner();
  bool get showAsToast => _showAsToast();
  String get priority => _getPriority();
  bool get autoDismiss => _autoDismiss();
  int? get autoDismissDelay => _autoDismissDelay();

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
    required this.type,
    this.readAt,
    this.sentAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] ?? {},
      type: json['type'] ?? 'general',
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'data': data,
      'type': type,
      'read_at': readAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? type,
    DateTime? readAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      type: type ?? this.type,
      readAt: readAt ?? this.readAt,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getFormattedTime() {
    return DateFormat('MMM dd, yyyy HH:mm').format(createdAt);
  }

  String _getIcon() {
    switch (type) {
      case 'order':
        return 'shopping_cart';
      case 'transport':
        return 'local_taxi';
      case 'promotional':
        return 'local_offer';
      case 'system':
        return 'system_update';
      default:
        return 'notifications';
    }
  }

  String _getColor() {
    switch (type) {
      case 'order':
        return 'primary';
      case 'transport':
        return 'info';
      case 'promotional':
        return 'warning';
      case 'system':
        return 'secondary';
      default:
        return 'primary';
    }
  }

  bool _isActionable() {
    return type == 'order' || type == 'transport';
  }

  String _getActionText() {
    switch (type) {
      case 'order':
        return 'View Order';
      case 'transport':
        return 'Track Ride';
      default:
        return 'View Details';
    }
  }

  String? _getActionUrl() {
    switch (type) {
      case 'order':
        return '/orders/${data['order_id'] ?? ''}';
      case 'transport':
        return '/transport/${data['ride_id'] ?? ''}';
      default:
        return null;
    }
  }

  bool _showAsBanner() {
    return type == 'order' || type == 'transport';
  }

  bool _showAsToast() {
    return type == 'promotional' || type == 'system';
  }

  String _getPriority() {
    switch (type) {
      case 'order':
        return 'high';
      case 'transport':
        return 'high';
      case 'promotional':
        return 'normal';
      case 'system':
        return 'low';
      default:
        return 'normal';
    }
  }

  bool _autoDismiss() {
    return type == 'promotional';
  }

  int? _autoDismissDelay() {
    return type == 'promotional' ? 5000 : null;
  }
}
