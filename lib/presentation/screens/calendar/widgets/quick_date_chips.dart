import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Horizontal row of quick date selection chips.
class QuickDateChips extends StatelessWidget {
  const QuickDateChips({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final tomorrow = todayNormalized.add(const Duration(days: 1));
    final nextMonday = _nextMonday(todayNormalized);

    final chips = [
      _QuickChipData(
        label: 'Hoy',
        date: todayNormalized,
        isSelected: _isSameDay(selectedDate, todayNormalized),
      ),
      _QuickChipData(
        label: 'Mañana',
        date: tomorrow,
        isSelected: _isSameDay(selectedDate, tomorrow),
      ),
      _QuickChipData(
        label: 'Próxima semana',
        date: nextMonday,
        isSelected: _isSameDay(selectedDate, nextMonday),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: chips.map((chip) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _QuickDateChip(
              label: chip.label,
              date: chip.date,
              isSelected: chip.isSelected,
              onTap: () => onDateSelected(chip.date),
            ),
          );
        }).toList(),
      ),
    );
  }

  DateTime _nextMonday(DateTime from) {
    final daysUntilMonday = (DateTime.monday - from.weekday + 7) % 7;
    final nextMonday = daysUntilMonday == 0
        ? from.add(const Duration(days: 7))
        : from.add(Duration(days: daysUntilMonday));
    return DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _QuickChipData {
  const _QuickChipData({
    required this.label,
    required this.date,
    required this.isSelected,
  });

  final String label;
  final DateTime date;
  final bool isSelected;
}

class _QuickDateChip extends StatelessWidget {
  const _QuickDateChip({
    required this.label,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              DateFormat('d/M').format(date),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.85)
                    : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
