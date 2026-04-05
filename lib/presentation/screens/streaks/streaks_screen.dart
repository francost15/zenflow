import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/utils/haptic_service.dart';
import 'package:app/domain/entities/habit.dart';
import 'package:app/presentation/blocs/streaks/streaks_bloc.dart';
import 'package:app/presentation/blocs/streaks/streaks_event.dart';
import 'package:app/presentation/blocs/streaks/streaks_state.dart';
import 'package:app/presentation/screens/streaks/widgets/habit_card.dart';
import 'package:app/presentation/screens/streaks/widgets/streaks_activity_card.dart';
import 'package:app/presentation/screens/streaks/widgets/streaks_header.dart';
import 'package:app/presentation/widgets/animated_fab.dart';
import 'package:app/presentation/widgets/dialogs/create_habit_dialog.dart';
import 'package:app/presentation/widgets/empty_state.dart';
import 'package:app/presentation/widgets/error_state.dart';
import 'package:app/presentation/widgets/loading_indicator.dart';
import 'package:app/presentation/widgets/streak_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<StreaksBloc, StreaksState>(
          builder: (context, state) {
            if (state is StreaksLoading) {
              return const LoadingIndicator();
            }

            if (state is StreaksError) {
              return ErrorState(
                title: 'Error de conexión',
                message: state.message,
                onRetry: _reload,
              );
            }

            if (state is! StreaksLoaded) {
              return const LoadingIndicator();
            }

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StreaksHeader(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: StreakCounter(
                        currentStreak: state.totalCurrentStreak,
                        longestStreak: state.longestStreak,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: StreaksActivityCard(
                        heatmapData: state.heatmapData,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'HÁBITOS DE PROTOCOLO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: state.habits.isEmpty
                          ? const EmptyState(
                              title: 'Sin hábitos activos',
                              message: 'Crea rutinas para fortalecer tu racha.',
                              padding: EdgeInsets.all(20),
                            )
                          : Column(
                              children: state.habits
                                  .map(_buildHabitCard)
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: () {
          HapticService.lightImpact();
          _showCreateHabitDialog();
        },
        tooltip: 'Nuevo Hábito',
        heroTag: 'add_habit_fab',
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'NUEVO HÁBITO',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final checkedToday = _isCheckedToday(habit);

    return HabitCard(
      habit: habit,
      checkedToday: checkedToday,
      onCheckIn: () {
        context.read<StreaksBloc>().add(HabitCheckInRequested(habit.id));
      },
      onDelete: () => _confirmDelete(habit),
    );
  }

  bool _isCheckedToday(Habit habit) {
    if (habit.lastCheckIn == null) {
      return false;
    }

    final now = DateTime.now();
    final lastCheck = habit.lastCheckIn!;
    return lastCheck.year == now.year &&
        lastCheck.month == now.month &&
        lastCheck.day == now.day;
  }

  void _reload() {
    context.read<StreaksBloc>().add(StreaksLoadRequested());
  }

  void _showCreateHabitDialog() {
    CreateHabitSheet.show(context);
  }

  Future<void> _confirmDelete(Habit habit) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        title: const Text(
          'Eliminar hábito',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Seguro que quieres eliminar "${habit.name}"? Perderás tu racha actual.',
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<StreaksBloc>().add(HabitDeleted(habit.id));
    }
  }
}
