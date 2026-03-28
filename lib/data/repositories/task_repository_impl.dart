import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firestore/task_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Future<List<Task>> getTasks() async {
    final models = await _datasource.getTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final models = await _datasource.getTasksByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    final created = await _datasource.createTask(model);
    return created.toEntity();
  }

  @override
  Future<Task> updateTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    final updated = await _datasource.updateTask(model);
    return updated.toEntity();
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _datasource.deleteTask(taskId);
  }

  @override
  Future<void> toggleTaskStatus(String taskId, bool completed) async {
    await _datasource.toggleTaskStatus(taskId, completed);
  }
}
