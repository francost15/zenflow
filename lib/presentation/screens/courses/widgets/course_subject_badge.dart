import 'package:app/presentation/screens/courses/course_visuals.dart';
import 'package:flutter/material.dart';

class CourseSubjectBadge extends StatelessWidget {
  const CourseSubjectBadge({
    super.key,
    required this.courseName,
    required this.color,
    this.size = 58,
    this.iconSize = 28,
  });

  final String courseName;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.92),
            color.withValues(alpha: 0.62),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        courseIconForName(courseName),
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
