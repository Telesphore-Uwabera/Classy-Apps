import 'package:flutter/cupertino.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/models/app_notification.dart';
import 'package:Classy/services/notification.service.dart';
import 'package:Classy/view_models/base.view_model.dart';

class NotificationsViewModel extends MyBaseViewModel {
  //
  List<AppNotification> notifications = [];

  NotificationsViewModel(BuildContext context) {
    this.viewContext = context;
  }

  @override
  void initialise() async {
    super.initialise();

    //getting notifications
    getNotifications();
  }

  //
  void getNotifications() async {
    final response = await NotificationService().getNotifications();
    if (response.code == 200 && response.body != null) {
      final data = response.body;
      notifications = (data['notifications'] as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    }
    notifyListeners();
  }

  //
  void showNotificationDetails(AppNotification notificationModel) async {
    //
    // Mark as read using the new notification service
    await NotificationService().markAsRead(notificationModel.id);

    //
    await Navigator.pushNamed(
      viewContext,
      AppRoutes.notificationDetailsRoute,
      arguments: notificationModel,
    );

    //
    getNotifications();
  }
}
