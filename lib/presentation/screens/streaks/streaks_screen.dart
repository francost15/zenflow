import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/habit.dart';
import '../../blocs/streaks/streaks_bloc.dart';
import '../../blocs/streaks/streaks_event.dart';
import '../../blocs/streaks/streaks_state.dart';
import '../../widgets/streak_counter.dart';
import '../../widgets/dialogs/create_habit_dialog.dart';
import 'widgets/habit_card.dart';

class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});

  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StreaksBloc>().add(StreaksLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<StreaksBloc, StreaksState>(
          builder: (context, state) {
            if (state is StreaksLoading) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 3),
              );
            }

            if (state is StreaksError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 24),
                      Text(
                        'Error de conexión',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton(
                        onPressed: () {
                          context.read<StreaksBloc>().add(StreaksLoadRequested());
                        },
                        child: const Text('REINTENTAR'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is StreaksLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StreaksBloc>().add(StreaksLoadRequested());
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Header ───
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RENDIMIENTO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rachas y Foco',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ─── Streak Counters ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: StreakCounter(
                          currentStreak: state.totalCurrentStreak,
                          longestStreak: state.longestStreak,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ─── Achievements Header ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'SISTEMA DE LOGROS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAchievements(theme, isDark, state),
                      const SizedBox(height: 48),

                      // ─── Habits Section Header ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HÁBITOS DE PROTOCOLO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.habits.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Text(
                                'Sin hábitos activos',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Crea rutinas para fortalecer tu racha.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: state.habits.map((habit) {
                              final checkedToday = _isCheckedToday(habit);
                              return HabitCard(
                                habit: habit,
                                checkedToday: checkedToday,
                                onCheckIn: () {
                                  context.read<StreaksBloc>().add(
                                        HabitCheckInRequested(habit.id),
                                      );
                                },
                                onDelete: () => _confirmDelete(context, habit),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateHabitDialog(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 0,
        label: const Text(
          'NUEVO HÁBITO',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
      ),
    );
  }

  Widget _buildAchievements(ThemeData theme, bool isDark, StreaksLoaded state) {
    final achievements = [
      _Achievement(
        icon: Icons.check_circle,
        label: '7 Días',
        unlocked: state.totalCurrentStreak >= 7,
      ),
      _Achievement(
        icon: Icons.calendar_today,
        label: 'Agenda',
        unlocked: true,
      ),
      _Achievement(
        icon: Icons.timer,
        label: 'Focus',
        unlocked: state.totalCurrentStreak >= 3,
      ),
      _Achievement(
        icon: Icons.star,
        label: '1 Mes',
        unlocked: state.totalCurrentStreak >= 30,
      ),
      _Achievement(
        icon: Icons.emoji_events,
        label: 'Maestro',
        unlocked: state.longestStreak >= 42,
      ),
      _Achievement(
        icon: Icons.nightlight_round,
        label: 'Zen',
        unlocked: state.totalCurrentStreak >= 14,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: achievement.unlocked
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : (isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.lightSurfaceElevated),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  size: 24,
                  color: achievement.unlocked
                      ? AppColors.accent
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: achievement.unlocked
                      ? theme.colorScheme.onSurface
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isCheckedToday(Habit habit) {
    if (habit.lastCheckIn == null) return false;
    final now = DateTime.now();
    final lastCheck = habit.lastCheckIn!;
    return lastCheck.year == now.year &&
        lastCheck.month == now.month &&
        lastCheck.day == now.day;
  }

  void _showCreateHabitDialog(BuildContext context) {
    CreateHabitSheet.show(context);
  }

  void _confirmDelete(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Hábito'),
        content: Text('¿Estás seguro de eliminar "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<StreaksBloc>().add(HabitDeleted(habit.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  final IconData icon;
  final String label;
  final bool unlocked;

  _Achievement({required this.icon, required this.label, required this.unlocked});
}
