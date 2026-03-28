import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/dialogs/create_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    context.read<TaskBloc>().add(TasksByDateRequested(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hoy', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              DateFormat('EEEE, d MMMM').format(_selectedDate),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return EmptyState(
                icon: Icons.task_alt,
                title: 'No hay tareas para hoy',
                subtitle: 'Toca + para agregar una tarea',
                action: ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Tarea'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadTasks(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return TaskTile(
                    task: task,
                    onToggle: (completed) {
                      context.read<TaskBloc>().add(
                        TaskStatusToggled(
                          taskId: task.id,
                          completed: completed,
                        ),
                      );
                    },
                    onTap: () => _showTaskDetails(task),
                    onDelete: () {
                      context.read<TaskBloc>().add(TaskDeleted(task.id));
                    },
                  );
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      _loadTasks();
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: this.context.read<TaskBloc>(),
        child: const CreateTaskDialog(),
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(task.description!),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(DateFormat('MMM d, y').format(task.dueDate)),
                ],
              ),
              if (task.dueTime != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${task.dueTime!.hour}:${task.dueTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
