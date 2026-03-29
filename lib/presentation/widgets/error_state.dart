import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable error state widget with icon, message, and optional retry action.
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final EdgeInsetsGeometry padding;
  final MainAxisAlignment alignment;

  const ErrorState({
    super.key,
    this.title = 'Ocurrió un error',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Reintentar',
    this.icon = Icons.error_outline,
    this.padding = const EdgeInsets.all(24),
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: alignment,
          children: [
            Icon(icon, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.error.withValues(alpha: 0.8),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
