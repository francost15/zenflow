import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/blocs/course/course.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:app/presentation/widgets/app_snackbars.dart';
import 'package:app/presentation/widgets/confirm_delete_dialog.dart';
import 'package:app/presentation/widgets/date_picker_sheet_theme.dart';
import 'package:app/presentation/widgets/dialogs/task_editor/task_editor_form.dart';
import 'package:app/presentation/widgets/dialogs/task_editor/task_editor_helpers.dart';
import 'package:app/presentation/widgets/focus_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({super.key, this.initialTask});

  final Task? initialTask;

  static Future<void> show(BuildContext context, {Task? initialTask}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditorSheet(initialTask: initialTask),
    );
  }

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  late TaskPriority _priority;
  String? _selectedCourseId;
  String? _titleError;
  String? _collisionError;
  var _isSubmitting = false;
  var _isDeleting = false;

  bool get _isEditMode => widget.initialTask != null;
  bool get _awaitingMutation => _isSubmitting || _isDeleting;

  @override
  void initState() {
    super.initState();
    final initialTask = widget.initialTask;
    _titleController.text = initialTask?.title ?? '';
    _descriptionController.text = initialTask?.description ?? '';
    _selectedDate = initialTask?.dueDate ?? DateTime.now();
    _selectedTime = initialTask?.dueTime;
    _priority = initialTask?.priority ?? TaskPriority.medium;
    _selectedCourseId = initialTask?.courseId;

    _checkForCollisions();

    final courseBloc = context.read<CourseBloc>();
    if (courseBloc.state is! CourseLoaded &&
        courseBloc.state is! CourseLoading) {
      courseBloc.add(CoursesLoadRequested());
    }
  }

  void _checkForCollisions() {
    final taskState = context.read<TaskBloc>().state;
    if (taskState is! TaskLoaded) return;

    final collidingTask = findCollision(
      existingTasks: taskState.tasks,
      date: _selectedDate,
      time: _selectedTime,
      excludeTaskId: widget.initialTask?.id,
    );

    setState(() {
      _collisionError = collidingTask != null
          ? formatCollisionError(collidingTask)
          : null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (!_awaitingMutation) {
          return;
        }

        if (state is TaskLoaded) {
          Navigator.pop(context);
          return;
        }

        if (state is TaskError) {
          setState(() {
            _isSubmitting = false;
            _isDeleting = false;
          });
          AppSnackbars.showError(
            context,
            buildTaskMutationErrorMessage(
              isDeleting: _isDeleting,
              error: state.message,
            ),
          );
        }
      },
      child: FocusSheetShell(
        title: _isEditMode ? 'Editar tarea' : 'Nueva tarea',
        monospaceLabel: _isEditMode
            ? 'focus_protocol_edit'
            : 'focus_protocol_01',
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: _awaitingMutation ? null : _deleteTask,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : const Text('Eliminar'),
            ),
          ElevatedButton(
            onPressed: (_awaitingMutation || _collisionError != null)
                ? null
                : _submitTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEditMode ? 'GUARDAR CAMBIOS' : 'INGRESAR TAREA'),
          ),
        ],
        child: TaskEditorForm(
          titleController: _titleController,
          descriptionController: _descriptionController,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          priority: _priority,
          selectedCourseId: _selectedCourseId,
          titleError: _titleError,
          collisionError: _collisionError,
          isEditMode: _isEditMode,
          onTitleChanged: (_) {
            if (_titleError != null) {
              setState(() => _titleError = null);
            }
          },
          onPriorityChanged: (value) => setState(() => _priority = value),
          onPickDate: _pickDate,
          onPickTime: _pickTime,
          onCourseChanged: (value) => setState(() => _selectedCourseId = value),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showAppDatePicker(
      context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      _checkForCollisions();
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
      _checkForCollisions();
    }
  }

  Future<void> _deleteTask() async {
    final task = widget.initialTask;
    if (task == null) {
      return;
    }

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: 'Eliminar tarea',
      itemName: task.title,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isDeleting = true);
    context.read<TaskBloc>().add(TaskDeleted(task));
  }

  void _submitTask() {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'Ingresa un título para la tarea');
      return;
    }

    final now = DateTime.now();
    final description = _descriptionController.text.trim();
    final initialTask = widget.initialTask;
    final task = initialTask == null
        ? Task(
            id: '',
            title: _titleController.text.trim(),
            description: description.isEmpty ? null : description,
            dueDate: _selectedDate,
            dueTime: _selectedTime,
            priority: _priority,
            status: TaskStatus.pending,
            courseId: _selectedCourseId,
            createdAt: now,
            updatedAt: now,
          )
        : initialTask.copyWith(
            title: _titleController.text.trim(),
            description: description.isEmpty ? null : description,
            dueDate: _selectedDate,
            dueTime: _selectedTime,
            priority: _priority,
            courseId: _selectedCourseId,
            updatedAt: now,
          );

    setState(() {
      _isSubmitting = true;
      _titleError = null;
    });

    context.read<TaskBloc>().add(
      initialTask == null ? TaskCreated(task) : TaskUpdated(task),
    );
  }
}
