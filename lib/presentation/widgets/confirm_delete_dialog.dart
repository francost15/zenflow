import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable confirmation dialog for delete actions.
Future<bool> showConfirmDeleteDialog({
  required BuildContext context,
  required String title,
  required String itemName,
  String? message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightSurface,
      title: Text(title),
      content: Text(
        message ?? '¿Estás seguro de que quieres eliminar "$itemName"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return result ?? false;
}
