import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class EventCard extends StatefulWidget {
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
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final start = widget.event.start?.dateTime ?? widget.event.start?.date;

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
                color: _getEventColor(widget.event),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: _isExpanded ? 160 : 60,
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Event card
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              widget.onTap?.call();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.event.summary ?? 'Sin título',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (widget.event.location != null)
                        Icon(
                          Icons.place,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                    ],
                  ),
                  if (widget.event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          widget.event.location!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_isExpanded) ...[
                    if (widget.event.description != null &&
                        widget.event.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.event.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Zen mode button
                    GestureDetector(
                      onTap: () {
                        widget.onStartZenMode?.call(
                          widget.event.summary ?? 'Tarea',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white
                              : AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              size: 16,
                              color: isDark
                                  ? AppColors.darkBackground
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Iniciar Modo Zen',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkBackground
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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
