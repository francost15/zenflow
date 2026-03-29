import 'package:app/presentation/blocs/streaks/streaks_state.dart';

class ProfileAchievementData {
  const ProfileAchievementData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool unlocked;
}

List<ProfileAchievementData> buildProfileAchievements(StreaksLoaded state) {
  return [
    ProfileAchievementData(
      emoji: '🔥',
      title: 'Encendido',
      subtitle: 'Mantén 3 días de foco',
      unlocked: state.totalCurrentStreak >= 3,
    ),
    ProfileAchievementData(
      emoji: '📅',
      title: 'Semana sólida',
      subtitle: 'Llega a 7 días seguidos',
      unlocked: state.totalCurrentStreak >= 7,
    ),
    ProfileAchievementData(
      emoji: '🧘',
      title: 'Modo Zen',
      subtitle: 'Sostén 14 días seguidos',
      unlocked: state.totalCurrentStreak >= 14,
    ),
    ProfileAchievementData(
      emoji: '⭐',
      title: 'Un mes',
      subtitle: 'Completa 30 días seguidos',
      unlocked: state.totalCurrentStreak >= 30,
    ),
    ProfileAchievementData(
      emoji: '🏆',
      title: 'Maestría',
      subtitle: 'Supera 42 días como récord',
      unlocked: state.longestStreak >= 42,
    ),
    ProfileAchievementData(
      emoji: '📚',
      title: 'Constancia',
      subtitle: 'Registra hábitos y estudio a diario',
      unlocked: state.habits.isNotEmpty,
    ),
  ];
}
