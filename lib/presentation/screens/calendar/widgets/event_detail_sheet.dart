import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/screens/calendar/widgets/event_detail_components.dart';
import 'package:app/presentation/widgets/app_snackbars.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailSheet extends StatelessWidget {
  const EventDetailSheet({
    super.key,
    required this.event,
    this.onStartZenMode,
  });

  final Event event;
  final VoidCallback? onStartZenMode;

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
                  Text(
                    event.summary ?? 'Sin título',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (start != null) ...[
                    EventDetailRow(
                      icon: Icons.access_time,
                      label: DateFormat('EEEE, d MMMM').format(start),
                      value:
                          '${DateFormat('HH:mm').format(start)}${end != null ? ' - ${DateFormat('HH:mm').format(end)}' : ''}',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (event.location != null) ...[
                    EventDetailRow(
                      icon: Icons.place,
                      label: 'Ubicación',
                      value: event.location!,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (event.description?.isNotEmpty == true) ...[
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
                  const SizedBox(height: 8),
                  EventDetailActionButton(
                    icon: Icons.play_arrow,
                    label: 'Iniciar Modo Zen',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      onStartZenMode?.call();
                    },
                  ),
                  const SizedBox(height: 12),
                  EventDetailActionButton(
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
    final start = event.start?.dateTime ?? event.start?.date;
    if (eventId == null || start == null) {
      return;
    }

    final uri = Uri.parse(
      'https://calendar.google.com/calendar/r/eventedit?text=${Uri.encodeComponent(event.summary ?? '')}&dates=${DateFormat("yyyyMMdd'T'HHmmss").format(start)}/${DateFormat("yyyyMMdd'T'HHmmss").format(start.add(const Duration(hours: 1)))}&details=${Uri.encodeComponent(event.description ?? '')}&location=${Uri.encodeComponent(event.location ?? '')}',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        AppSnackbars.showError(context, 'No se pudo abrir Google Calendar');
      }
    }
  }
}

void showEventDetailSheet(
  BuildContext context, {
  required Event event,
  VoidCallback? onStartZenMode,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        EventDetailSheet(event: event, onStartZenMode: onStartZenMode),
  );
}
