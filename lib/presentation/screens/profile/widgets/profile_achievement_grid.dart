import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/screens/profile/profile_achievement_data.dart';
import 'package:flutter/material.dart';

class ProfileAchievementGrid extends StatelessWidget {
  const ProfileAchievementGrid({super.key, required this.achievements});

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
  const _AchievementCard({required this.achievement, required this.isDark});

  final ProfileAchievementData achievement;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? AppColors.accent.withAlpha(20)
            : (isDark ? AppColors.obsidian : Colors.white),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: achievement.unlocked
              ? AppColors.accent.withAlpha(60)
              : (isDark ? AppColors.monolithBorder : Colors.black12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 24,
                  color: achievement.unlocked
                      ? null
                      : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary),
                ),
              ),
              if (achievement.unlocked)
                const Icon(
                  Icons.verified_outlined,
                  size: 14,
                  color: AppColors.accent,
                ),
            ],
          ),
          const Spacer(),
          Text(
            achievement.title.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.stone : Colors.black87,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
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
