import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TaskBloc, TaskState>(
      // Memoization: only rebuild when tasks or selectedDate actually change
      buildWhen: (previous, current) {
        if (previous is TaskLoaded && current is TaskLoaded) {
          return previous.tasks != current.tasks ||
              previous.selectedDate != current.selectedDate ||
              previous.noticeMessage != current.noticeMessage;
        }
        return true;
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return const SliverFillRemaining(child: LoadingIndicator());
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
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    size: 32,
                    color: Color(0xFF27272A),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PROTOCOLO COMPLETADO',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.5,
                      color: isDark ? AppColors.stone : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DÍA DESPEJADO',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : Colors.black45,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Text(
                  'HOY',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                    color: isDark ? AppColors.darkTextTertiary : Colors.black45,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  // RepaintBoundary isolates repaints for each tile
                  return RepaintBoundary(
                    child: TaskTile(
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
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
