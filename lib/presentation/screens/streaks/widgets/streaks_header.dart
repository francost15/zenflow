import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StreaksHeader extends StatelessWidget {
  const StreaksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RENDIMIENTO',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rachas y Foco',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
