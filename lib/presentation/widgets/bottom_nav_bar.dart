import 'dart:ui';

import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkNavBar.withValues(alpha: 0.8)
                  : AppColors.lightNavBar.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDestination(
                  context,
                  Icons.track_changes_outlined,
                  Icons.track_changes,
                  'Foco',
                  0,
                ),
                _buildDestination(
                  context,
                  Icons.calendar_today_outlined,
                  Icons.calendar_today,
                  'Agenda',
                  1,
                ),
                _buildDestination(
                  context,
                  Icons.auto_stories_outlined,
                  Icons.auto_stories,
                  'Cursos',
                  2,
                ),
                _buildDestination(
                  context,
                  Icons.emoji_events_outlined,
                  Icons.emoji_events,
                  'Rachas',
                  3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestination(
    BuildContext context,
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? AppColors.accent : theme.hintColor,
          size: 26,
        ),
      ),
    );
  }
}
