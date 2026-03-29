import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:app/presentation/widgets/empty_state.dart';
import 'package:app/presentation/widgets/error_state.dart';
import 'package:app/presentation/widgets/loading_indicator.dart';
import 'package:app/presentation/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeTaskSliver extends StatelessWidget {
  const HomeTaskSliver({
    super.key,
    required this.onRetry,
    required this.onEditTask,
  });

  final VoidCallback onRetry;
  final ValueChanged<Task> onEditTask;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const SliverFillRemaining(
            child: LoadingIndicator(),
          );
        }

        if (state is TaskError) {
          return SliverFillRemaining(
            child: ErrorState(
              title: 'No pudimos cargar tus tareas',
              message: state.message,
              onRetry: onRetry,
            ),
          );
        }

        if (state is! TaskLoaded) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        if (state.tasks.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: 'Día despejado',
              message: 'No tienes tareas pendientes para hoy.',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return TaskTile(
                task: task,
                onToggle: (completed) {
                  context.read<TaskBloc>().add(
                        TaskStatusToggled(task: task, completed: completed),
                      );
                },
                onTap: () => onEditTask(task),
                onDelete: () {
                  context.read<TaskBloc>().add(TaskDeleted(task));
                },
                onUndoDelete: () {
                  context.read<TaskBloc>().add(TaskUndoDeletionRequested(task));
                },
              );
            },
          ),
        );
      },
    );
  }
}
