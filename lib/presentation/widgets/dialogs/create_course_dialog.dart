import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/course.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../focus_sheet_shell.dart';

class CreateCourseSheet extends StatefulWidget {
  const CreateCourseSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateCourseSheet(),
    );
  }

  @override
  State<CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends State<CreateCourseSheet> {
  final _nameController = TextEditingController();
  final _professorController = TextEditingController();
  Color _selectedColor = AppColors.accent;

  final _colors = [
    AppColors.courseRed,
    AppColors.courseBlue,
    AppColors.coursePurple,
    AppColors.courseGreen,
    AppColors.courseAmber,
    AppColors.coursePink,
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF84CC16), // Lime
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _professorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FocusSheetShell(
      title: 'Nueva Materia',
      monospaceLabel: 'course_registry_02',
      actions: [
        ElevatedButton(
          onPressed: _createCourse,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('REGISTRAR MATERIA'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Nombre de la materia',
              hintStyle: TextStyle(
                color: (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary).withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
            ),
            autofocus: true,
          ),
          TextField(
            controller: _professorController,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Profesor (opcional)',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              border: InputBorder.none,
            ),
          ),
          const Divider(height: 32),
          const Text(
            'ETIQUETA DE COLOR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? (isDark ? Colors.white : Colors.black) 
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ] : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _createCourse() {
    if (_nameController.text.isEmpty) return;

    final course = Course(
      id: '',
      name: _nameController.text,
      color: _selectedColor,
      professor: _professorController.text.isEmpty
          ? null
          : _professorController.text,
      createdAt: DateTime.now(),
    );

    context.read<CourseBloc>().add(CourseCreated(course));
    Navigator.pop(context);
  }
}

