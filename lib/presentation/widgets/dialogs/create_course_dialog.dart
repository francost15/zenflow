import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/course.dart';
import 'package:app/presentation/blocs/course/course_bloc.dart';
import 'package:app/presentation/blocs/course/course_event.dart';
import 'package:app/presentation/blocs/course/course_state.dart';
import 'package:app/presentation/widgets/app_snackbars.dart';
import 'package:app/presentation/widgets/dialogs/course_editor/course_editor_form.dart';
import 'package:app/presentation/widgets/focus_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseEditorSheet extends StatefulWidget {
  const CourseEditorSheet({super.key, this.initialCourse});

  final Course? initialCourse;

  static Future<void> show(BuildContext context, {Course? initialCourse}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseEditorSheet(initialCourse: initialCourse),
    );
  }

  @override
  State<CourseEditorSheet> createState() => _CourseEditorSheetState();
}

class _CourseEditorSheetState extends State<CourseEditorSheet> {
  final _nameController = TextEditingController();
  final _professorController = TextEditingController();
  final _notesController = TextEditingController();
  final _colors = [
    AppColors.courseRed,
    AppColors.courseBlue,
    AppColors.coursePurple,
    AppColors.courseGreen,
    AppColors.courseAmber,
    AppColors.coursePink,
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
  ];

  late Color _selectedColor;
  late List<Schedule> _schedule;
  String? _nameError;
  var _isSubmitting = false;

  bool get _isEditMode => widget.initialCourse != null;

  @override
  void initState() {
    super.initState();
    final initialCourse = widget.initialCourse;
    _nameController.text = initialCourse?.name ?? '';
    _professorController.text = initialCourse?.professor ?? '';
    _notesController.text = initialCourse?.notes ?? '';
    _selectedColor = initialCourse?.color ?? AppColors.accent;
    _schedule = List<Schedule>.from(initialCourse?.schedule ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CourseBloc, CourseState>(
      listener: (context, state) {
        if (!_isSubmitting) {
          return;
        }

        if (state is CourseLoaded) {
          Navigator.pop(context);
          return;
        }

        if (state is CourseError) {
          setState(() => _isSubmitting = false);
          AppSnackbars.showError(
            context,
            'No se pudo guardar el curso. Intenta de nuevo.',
          );
        }
      },
      child: FocusSheetShell(
        title: _isEditMode ? 'Editar materia' : 'Nueva materia',
        monospaceLabel: _isEditMode
            ? 'course_registry_edit'
            : 'course_registry_02',
        actions: [
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitCourse,
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
                : Text(_isEditMode ? 'GUARDAR CAMBIOS' : 'REGISTRAR MATERIA'),
          ),
        ],
        child: CourseEditorForm(
          nameController: _nameController,
          professorController: _professorController,
          notesController: _notesController,
          selectedColor: _selectedColor,
          schedule: _schedule,
          nameError: _nameError,
          isEditMode: _isEditMode,
          colors: _colors,
          onNameChanged: (_) {
            if (_nameError != null) {
              setState(() => _nameError = null);
            }
          },
          onColorChanged: (value) => setState(() => _selectedColor = value),
          onAddSchedule: _addSchedule,
          onScheduleChanged: (update) {
            setState(() => _schedule[update.index] = update.schedule);
          },
          onScheduleRemoved: (index) {
            setState(() => _schedule.removeAt(index));
          },
        ),
      ),
    );
  }

  void _addSchedule() {
    setState(() {
      _schedule = [
        ..._schedule,
        const Schedule(
          dayOfWeek: 1,
          startTime: TimeOfDay(hour: 9, minute: 0),
          endTime: TimeOfDay(hour: 10, minute: 0),
        ),
      ];
    });
  }

  void _submitCourse() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Ingresa un nombre para la materia');
      return;
    }

    final initialCourse = widget.initialCourse;
    final notes = _notesController.text.trim();
    final professor = _professorController.text.trim();
    final course = initialCourse == null
        ? Course(
            id: '',
            name: _nameController.text.trim(),
            color: _selectedColor,
            professor: professor.isEmpty ? null : professor,
            schedule: _schedule,
            notes: notes.isEmpty ? null : notes,
            createdAt: DateTime.now(),
          )
        : initialCourse.copyWith(
            name: _nameController.text.trim(),
            color: _selectedColor,
            professor: professor.isEmpty ? null : professor,
            schedule: _schedule,
            notes: notes.isEmpty ? null : notes,
          );

    setState(() {
      _isSubmitting = true;
      _nameError = null;
    });

    context.read<CourseBloc>().add(
      initialCourse == null ? CourseCreated(course) : CourseUpdated(course),
    );
  }
}
