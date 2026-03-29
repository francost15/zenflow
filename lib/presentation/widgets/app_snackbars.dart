import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppSnackbars {
  static void showNotice(
    BuildContext context,
    String message, {
    Color backgroundColor = AppColors.courseAmber,
  }) {
    _show(
      context,
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  static void _show(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
