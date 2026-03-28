import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/habit.dart';
import '../../blocs/streaks/streaks_bloc.dart';
import '../../blocs/streaks/streaks_event.dart';
import '../../blocs/streaks/streaks_state.dart';
import '../../widgets/heatmap_chart.dart';
import '../../widgets/streak_counter.dart';
import '../../widgets/empty_state.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rachas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<StreaksBloc, StreaksState>(
        builder: (context, state) {
          if (state is StreaksLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StreaksError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StreaksBloc>().add(StreaksLoadRequested());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is StreaksLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<StreaksBloc>().add(StreaksLoadRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak Counter
                    Center(
                      child: StreakCounter(
                        currentStreak: state.totalCurrentStreak,
                        longestStreak: state.longestStreak,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Heatmap
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actividad del año',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          HeatmapChart(data: state.heatmapData),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Habits section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hábitos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showCreateHabitDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (state.habits.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: EmptyState(
                          icon: Icons.local_fire_department,
                          title: 'No hay hábitos',
                          subtitle: 'Crea tu primer hábito para empezar',
                          action: ElevatedButton.icon(
                            onPressed: () => _showCreateHabitDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Hábito'),
                          ),
                        ),
                      )
                    else
                      ...state.habits.map((habit) {
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
                      }),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateHabitDialog(context),
        child: const Icon(Icons.add),
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
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StreaksBloc>(),
        child: const CreateHabitDialog(),
      ),
    );
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
