import 'package:app/domain/entities/habit.dart';
import 'package:app/domain/repositories/habit_repository.dart';
import 'package:app/presentation/blocs/streaks/streaks_event.dart';
import 'package:app/presentation/blocs/streaks/streaks_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StreaksBloc extends Bloc<StreaksEvent, StreaksState> {
  final HabitRepository _habitRepository;

  StreaksBloc(this._habitRepository) : super(StreaksInitial()) {
    on<StreaksLoadRequested>(_onLoadRequested);
    on<HabitCheckInRequested>(_onCheckIn);
    on<HabitCreated>(_onCreated);
    on<HabitDeleted>(_onDeleted);
  }

  Future<void> _onLoadRequested(
    StreaksLoadRequested event,
    Emitter<StreaksState> emit,
  ) async {
    emit(StreaksLoading());
    try {
      final habits = await _habitRepository.getHabits();
      final heatmapData = _calculateHeatmapData(habits);
      final totalStreak = _calculateTotalStreak(habits);
      final longest = _calculateLongestStreak(habits);

      emit(
        StreaksLoaded(
          habits: habits,
          heatmapData: heatmapData,
          totalCurrentStreak: totalStreak,
          longestStreak: longest,
        ),
      );
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }

  Future<void> _onCheckIn(
    HabitCheckInRequested event,
    Emitter<StreaksState> emit,
  ) async {
    try {
      await _habitRepository.checkIn(event.habitId);
      add(StreaksLoadRequested());
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }

  Future<void> _onCreated(
    HabitCreated event,
    Emitter<StreaksState> emit,
  ) async {
    try {
      await _habitRepository.createHabit(event.name, event.icon);
      add(StreaksLoadRequested());
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }

  Future<void> _onDeleted(
    HabitDeleted event,
    Emitter<StreaksState> emit,
  ) async {
    try {
      await _habitRepository.deleteHabit(event.habitId);
      add(StreaksLoadRequested());
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }

  Map<DateTime, int> _calculateHeatmapData(List<Habit> habits) {
    final Map<DateTime, int> data = {};
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));

    for (final habit in habits) {
      for (final checkIn in habit.checkInHistory) {
        if (checkIn.isAfter(oneYearAgo)) {
          final date = DateTime(checkIn.year, checkIn.month, checkIn.day);
          data[date] = (data[date] ?? 0) + 1;
        }
      }
    }

    return data;
  }

  int _calculateTotalStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }

  int _calculateLongestStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
  }
}
