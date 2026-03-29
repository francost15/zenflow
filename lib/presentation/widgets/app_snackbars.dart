import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppSnackbars {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
    Color backgroundColor = AppColors.courseAmber,
  }) {
    return _show(
      context,
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        action: SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
  }

  static void showNotice(
    BuildContext context,
    String message, {
    Color backgroundColor = AppColors.courseAmber,
  }) {
    _show(
      context,
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _show(
    BuildContext context,
    SnackBar snackBar,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(snackBar);
  }
}
