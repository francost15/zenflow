import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CoursesHeader extends StatelessWidget {
  const CoursesHeader({super.key, required this.onCreateCourse});

  final VoidCallback onCreateCourse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            size: 30,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ACADÉMICO',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hub de cursos',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tus materias, horarios y pendientes en una sola vista más clara.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onCreateCourse,
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text('Nueva materia'),
        ),
      ],
    );
  }
}
