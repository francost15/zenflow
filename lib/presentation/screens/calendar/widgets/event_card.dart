import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final start = event.start?.dateTime ?? event.start?.date;
    final end = event.end?.dateTime ?? event.end?.date;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: _getEventColor(event),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.summary ?? 'Sin título',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (event.description != null &&
                        event.description!.isNotEmpty)
                      Text(
                        event.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    if (start != null)
                      Text(
                        _formatTime(start, end),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (event.location != null)
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEventColor(Event event) {
    final color = event.colorId;
    if (color == null) return const Color(0xFF6366F1);

    const colorMap = {
      '1': Color(0xFF6366F1), // Indigo
      '2': Color(0xFF10B981), // Green
      '3': Color(0xFFF59E0B), // Amber
      '4': Color(0xFFEF4444), // Red
      '5': Color(0xFF8B5CF6), // Purple
    };
    return colorMap[color] ?? const Color(0xFF6366F1);
  }

  String _formatTime(DateTime start, DateTime? end) {
    final dateStr = DateFormat('MMM d').format(start);
    final startStr = DateFormat('h:mm a').format(start);
    if (end != null) {
      final endStr = DateFormat('h:mm a').format(end);
      return '$dateStr, $startStr - $endStr';
    }
    return '$dateStr, $startStr';
  }
}
