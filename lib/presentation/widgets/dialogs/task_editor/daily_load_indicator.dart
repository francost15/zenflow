import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DailyLoadIndicator extends StatelessWidget {
  const DailyLoadIndicator({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is! TaskLoaded) return const SizedBox.shrink();
        final tasks = state.tasks.where((t) {
          return t.dueDate.year == selectedDate.year &&
              t.dueDate.month == selectedDate.month &&
              t.dueDate.day == selectedDate.day;
        }).toList();
        if (tasks.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceElevated.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.monolithBorder.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 10,
                color: AppColors.darkTextTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'PROTOCOL: ${tasks.length} SEC_TASKS_DETEKTED',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
