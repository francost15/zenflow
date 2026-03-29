import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CoursesHeader extends StatelessWidget {
  const CoursesHeader({
    super.key,
    required this.onCreateCourse,
  });

  final VoidCallback onCreateCourse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACADÉMICO',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hub de cursos',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCreateCourse,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
