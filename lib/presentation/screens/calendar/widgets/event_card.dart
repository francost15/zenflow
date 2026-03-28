import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import 'event_detail_sheet.dart';

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time label
        SizedBox(
          width: 50,
          child: Text(
            start != null ? DateFormat('HH:mm').format(start) : '',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Timeline dot + line
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _getEventColor(event),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 60,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Event card
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.summary ?? 'Sin título',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 13,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 12,
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
