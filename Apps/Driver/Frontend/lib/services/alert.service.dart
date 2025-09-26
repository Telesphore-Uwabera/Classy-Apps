import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class AlertService {
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String text,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: title,
      text: text,
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String text,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title,
      text: text,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String title,
    required String text,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: title,
      text: text,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String text,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: title,
      text: text,
    );
  }

  static void showLoading({
    required BuildContext context,
    required String text,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: text,
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}