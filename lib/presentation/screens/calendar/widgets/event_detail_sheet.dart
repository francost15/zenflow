import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';

/// Bottom sheet showing full event details.
/// Provides actions like opening in Google Calendar and starting Zen Mode.
class EventDetailSheet extends StatelessWidget {
  final Event event;
  final VoidCallback? onStartZenMode;

  const EventDetailSheet({super.key, required this.event, this.onStartZenMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final start = event.start?.dateTime ?? event.start?.date;
    final end = event.end?.dateTime ?? event.end?.date;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.summary ?? 'Sin título',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time
                  if (start != null) ...[
                    _DetailRow(
                      icon: Icons.access_time,
                      label: DateFormat('EEEE, d MMMM').format(start),
                      value:
                          '${DateFormat('HH:mm').format(start)}${end != null ? ' - ${DateFormat('HH:mm').format(end)}' : ''}',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Location
                  if (event.location != null) ...[
                    _DetailRow(
                      icon: Icons.place,
                      label: 'Ubicación',
                      value: event.location!,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Description
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Actions
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.play_arrow,
                    label: 'Iniciar Modo Zen',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      onStartZenMode?.call();
                    },
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.open_in_new,
                    label: 'Abrir en Google Calendar',
                    isDark: isDark,
                    onTap: () => _openInBrowser(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInBrowser(BuildContext context) async {
    final eventId = event.id;
    if (eventId == null) return;

    // Build Google Calendar URL
    final start = event.start?.dateTime ?? event.start?.date;
    if (start == null) return;

    final uri = Uri.parse(
      'https://calendar.google.com/calendar/r/eventedit?text=${Uri.encodeComponent(event.summary ?? '')}&dates=${DateFormat("yyyyMMdd'T'HHmmss").format(start)}/${DateFormat("yyyyMMdd'T'HHmmss").format(start.add(const Duration(hours: 1)))}&details=${Uri.encodeComponent(event.description ?? '')}&location=${Uri.encodeComponent(event.location ?? '')}',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Calendar')),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the event detail bottom sheet.
void showEventDetailSheet(
  BuildContext context, {
  required Event event,
  VoidCallback? onStartZenMode,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        EventDetailSheet(event: event, onStartZenMode: onStartZenMode),
  );
}
