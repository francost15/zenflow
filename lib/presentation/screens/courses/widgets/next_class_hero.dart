import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/course/course_overview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextClassHero extends StatelessWidget {
  const NextClassHero({
    super.key,
    required this.nextClass,
  });

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRÓXIMA CLASE',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Aún no tienes horarios cargados',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Edita una materia para registrar sus bloques semanales y volver esta sección más útil.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PopulatedHero extends StatelessWidget {
  const _PopulatedHero({
    required this.nextClass,
    required this.theme,
  });

  final UpcomingCourseClass nextClass;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRÓXIMA CLASE',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          nextClass.course.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE d MMM · HH:mm', 'es_ES').format(nextClass.startAt),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          nextClass.isOngoing
              ? 'En curso ahora'
              : 'Preparada para tu siguiente sesión',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
