import '../entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<Habit> createHabit(String name, String? icon);
  Future<Habit> checkIn(String habitId);
  Future<void> deleteHabit(String habitId);
}
