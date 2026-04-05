import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/auth/auth.dart';
import 'package:app/presentation/blocs/calendar/calendar.dart';
import 'package:app/presentation/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeProtocolHeader extends StatelessWidget {
  const HomeProtocolHeader({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.onSyncTap,
  });

  final DateTime selectedDate;
  final VoidCallback onTap;
  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protocolo diario',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _isToday(selectedDate)
                          ? 'Hoy'
                          : DateFormat('EEEE d').format(selectedDate),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, calendarState) {
                  return SyncStatusBadgeWithLogic(onSyncTap: onSyncTap);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}
