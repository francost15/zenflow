import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/screens/calendar/widgets/event_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final void Function(String taskName)? onStartZenMode;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onStartZenMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final start = event.start?.dateTime ?? event.start?.date;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time label
          Container(
            width: 60,
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  start != null ? DateFormat('HH:mm').format(start) : '--:--',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                if (event.end?.dateTime != null || event.end?.date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('HH:mm').format(
                      event.end?.dateTime ?? event.end!.date!,
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _getEventColor(event),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Event content
          Expanded(
            child: GestureDetector(
              onTap: () {
                onTap?.call();
                showEventDetailSheet(
                  context,
                  event: event,
                  onStartZenMode: onStartZenMode != null
                      ? () => onStartZenMode!(event.summary ?? 'Tarea')
                      : null,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.summary ?? 'Sin título',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ],
                    ),
                    if (event.location != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.accent.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(Event event) {
    final color = event.colorId;
    if (color == null) return AppColors.accent;

    const colorMap = {
      '1': AppColors.accent,
      '2': AppColors.success,
      '3': AppColors.warning,
      '4': AppColors.error,
      '5': AppColors.coursePurple,
    };
    return colorMap[color] ?? AppColors.accent;
  }
}
