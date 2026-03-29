import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(
                  primary: AppColors.accent,
                  surface: AppColors.darkSurface,
                )
              : const ColorScheme.light(primary: AppColors.accent),
        ),
        child: child!,
      );
    },
  );
}
