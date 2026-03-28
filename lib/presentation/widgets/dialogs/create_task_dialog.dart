import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../focus_sheet_shell.dart';

class CreateTaskSheet extends StatefulWidget {
  const CreateTaskSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTaskSheet(),
    );
  }

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FocusSheetShell(
      title: 'Nueva Tarea',
      monospaceLabel: 'focus_protocol_01',
      actions: [
        ElevatedButton(
          onPressed: _createTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('INGRESAR TAREA'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: '¿En qué vas a enfocarte?',
              hintStyle: TextStyle(
                color: (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary).withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Notas adicionales (opcional)...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              border: InputBorder.none,
            ),
          ),
          const Divider(height: 32),
          
          // Selection Row
          const Text(
            'PARÁMETROS DE ENFOQUE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          // Priority
          Wrap(
            spacing: 8,
            children: TaskPriority.values.map((p) {
              final isSelected = _priority == p;
              return ChoiceChip(
                label: Text(p.name.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _priority = p);
                },
                backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                selectedColor: _getPriorityColor(p).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? _getPriorityColor(p) : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                side: BorderSide(
                  color: isSelected ? _getPriorityColor(p) : Colors.transparent,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Date/Time
          Row(
            children: [
              _SelectionAction(
                icon: Icons.calendar_today_outlined,
                label: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(width: 12),
              _SelectionAction(
                icon: Icons.access_time,
                label: _selectedTime != null
                    ? '${_selectedTime!.format(context)}'
                    : 'Sin hora',
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.courseAmber;
      case TaskPriority.low:
        return AppColors.darkTextTertiary;
    }
  }

  void _createTask() {
    if (_titleController.text.isEmpty) return;
    final now = DateTime.now();
    final task = Task(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      dueDate: _selectedDate,
      dueTime: _selectedTime,
      priority: _priority,
      status: TaskStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
    context.read<TaskBloc>().add(TaskCreated(task));
    Navigator.pop(context);
  }
}

class _SelectionAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SelectionAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.darkTextTertiary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

