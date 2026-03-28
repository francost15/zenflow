import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/course.dart';
import '../blocs/course/course_bloc.dart';
import '../blocs/course/course_event.dart';

class CreateCourseDialog extends StatefulWidget {
  const CreateCourseDialog({super.key});

  @override
  State<CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends State<CreateCourseDialog> {
  final _nameController = TextEditingController();
  final _professorController = TextEditingController();
  Color _selectedColor = const Color(0xFF6366F1);

  final _colors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFEC4899), // Pink
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
    return AlertDialog(
      title: const Text('Nueva Materia'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la materia',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _professorController,
              decoration: const InputDecoration(
                labelText: 'Profesor (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _createCourse, child: const Text('Crear')),
      ],
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
