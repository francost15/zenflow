import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final initial = course.name.isNotEmpty ? course.name[0].toUpperCase() : '?';
    final pendingTasks = ((1 - course.progress) * 10).round(); // Approximate

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular progress ring with initial
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 3,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CustomPaint(
                      painter: _CourseProgressPainter(
                        progress: course.progress,
                        color: course.color,
                        strokeWidth: 3.5,
                      ),
                    ),
                  ),
                  // Initial letter
                  Text(
                    initial,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Course name
            Text(
              course.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Status
            Text(
              course.progress >= 1.0
                  ? 'Al día'
                  : '$pendingTasks pendientes',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: course.progress >= 1.0
                    ? AppColors.success
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

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Eliminar', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CourseProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CourseProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
