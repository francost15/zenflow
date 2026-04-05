import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.focusedWeekStart,
    required this.onMoveWeek,
  });

  final DateTime focusedWeekStart;
  final ValueChanged<int> onMoveWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AGENDA',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  color: isDark ? AppColors.stone : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat(
                  'MMMM yyyy',
                  'es_ES',
                ).format(focusedWeekStart).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            isDark: isDark,
            onPressed: () => onMoveWeek(-1),
          ),
          const SizedBox(width: 8),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            isDark: isDark,
            onPressed: () => onMoveWeek(1),
          ),
        ],
      ),
    );
  }
}

class CalendarWeekStrip extends StatelessWidget {
  const CalendarWeekStrip({
    super.key,
    required this.focusedWeekStart,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime focusedWeekStart;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.obsidian : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.monolithBorder : Colors.black12,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final date = focusedWeekStart.add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF18181B) : Colors.black12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdayLetter(date.weekday),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? AppColors.accent
                            : isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                        fontSize: 14,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    if (isToday && !isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 3,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: AppColors.accent,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}

String _weekdayLetter(int weekday) {
  const letters = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  return letters[weekday - 1];
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
