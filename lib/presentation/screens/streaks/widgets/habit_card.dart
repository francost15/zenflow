import 'package:flutter/material.dart';
import '../../../../domain/entities/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool checkedToday;
  final VoidCallback onCheckIn;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.checkedToday,
    required this.onCheckIn,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: checkedToday ? null : onCheckIn,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: checkedToday
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  checkedToday ? Icons.check : Icons.local_fire_department,
                  color: checkedToday ? Colors.white : const Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkedToday
                          ? '¡Completado hoy! 🎉'
                          : '${habit.currentStreak} días de racha',
                      style: TextStyle(
                        color: checkedToday
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (!checkedToday)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF6366F1),
                  onPressed: onCheckIn,
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
