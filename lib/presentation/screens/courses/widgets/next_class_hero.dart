import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/course/course_overview.dart';
import 'package:app/presentation/screens/courses/widgets/course_subject_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextClassHero extends StatelessWidget {
  const NextClassHero({super.key, required this.nextClass});

  final UpcomingCourseClass? nextClass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: nextClass == null
          ? _EmptyHero(theme: theme)
          : _PopulatedHero(nextClass: nextClass!, theme: theme),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.event_busy_rounded,
            color: AppColors.accent,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'PRÓXIMA CLASE',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Aún no tienes horarios cargados',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Edita una materia para registrar sus bloques semanales y volver esta sección más útil.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PopulatedHero extends StatelessWidget {
  const _PopulatedHero({required this.nextClass, required this.theme});

  final UpcomingCourseClass nextClass;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CourseSubjectBadge(
          courseName: nextClass.course.name,
          color: nextClass.course.color,
        ),
        const SizedBox(height: 14),
        Text(
          'PRÓXIMA CLASE',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          nextClass.course.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE d MMM · HH:mm', 'es_ES').format(nextClass.startAt),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          nextClass.isOngoing
              ? 'En curso ahora'
              : 'Preparada para tu siguiente sesión',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
