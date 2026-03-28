import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/firestore/habit_datasource.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitDatasource _datasource;

  HabitRepositoryImpl(this._datasource);

  @override
  Future<List<Habit>> getHabits() async {
    final models = await _datasource.getHabits();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Habit> createHabit(String name, String? icon) async {
    final model = HabitModel(id: '', name: name, icon: icon);
    final created = await _datasource.createHabit(model);
    return created.toEntity();
  }

  @override
  Future<Habit> checkIn(String habitId) async {
    final updated = await _datasource.checkIn(habitId);
    return updated.toEntity();
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await _datasource.deleteHabit(habitId);
  }
}
