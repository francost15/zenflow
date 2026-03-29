import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/screens/profile/profile_achievement_data.dart';
import 'package:flutter/material.dart';

class ProfileAchievementGrid extends StatelessWidget {
  const ProfileAchievementGrid({
    super.key,
    required this.achievements,
  });

  final List<ProfileAchievementData> achievements;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        return _AchievementCard(
          achievement: achievements[index],
          isDark: isDark,
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    required this.isDark,
  });

  final ProfileAchievementData achievement;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? AppColors.accent.withValues(alpha: 0.12)
            : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.unlocked
              ? AppColors.accent.withValues(alpha: 0.25)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievement.emoji,
            style: TextStyle(
              fontSize: 28,
              color: achievement.unlocked
                  ? null
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary),
            ),
          ),
          const Spacer(),
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
