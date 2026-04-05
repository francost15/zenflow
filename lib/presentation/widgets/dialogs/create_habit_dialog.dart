import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/streaks/streaks_bloc.dart';
import 'package:app/presentation/blocs/streaks/streaks_event.dart';
import 'package:app/presentation/widgets/focus_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateHabitSheet extends StatefulWidget {
  const CreateHabitSheet({super.key});

  static Future<void> show(BuildContext context) {
    return FocusSheetShell.show(
      context: context,
      child: const CreateHabitSheet(),
    );
  }

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  final _nameController = TextEditingController();
  String _selectedIcon = '🔥';

  final _icons = ['🔥', '💪', '📚', '🏃', '💧', '🧘', '💤', '🥗', '✍️', '🎯'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FocusSheetShell(
      title: 'Nuevo Hábito',
      monospaceLabel: 'habit_protocol_03',
      actions: [
        ElevatedButton(
          onPressed: _createHabit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('REFORZAR HÁBITO'),
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
              hintText: 'Nombre del hábito...',
              hintStyle: TextStyle(
                color:
                    (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary)
                        .withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
            ),
            autofocus: true,
          ),
          const Divider(height: 32),
          const Text(
            'SELECCIONAR ICONO',
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
            children: _icons.map((icon) {
              final isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : (isDark
                              ? AppColors.darkSurfaceElevated
                              : AppColors.lightSurfaceElevated),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _createHabit() {
    if (_nameController.text.isEmpty) return;
    context.read<StreaksBloc>().add(
      HabitCreated(name: _nameController.text, icon: _selectedIcon),
    );
    Navigator.pop(context);
  }
}
