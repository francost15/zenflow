import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/blocs/streaks/streaks_bloc.dart';
import 'package:app/presentation/blocs/streaks/streaks_state.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:app/presentation/screens/home/widgets/home_header.dart';
import 'package:app/presentation/screens/home/widgets/home_protocol_header.dart';
import 'package:app/presentation/screens/home/widgets/home_streak_hero.dart';
import 'package:app/presentation/screens/home/widgets/home_task_sliver.dart';
import 'package:app/presentation/widgets/app_snackbars.dart';
import 'package:app/presentation/widgets/date_picker_sheet_theme.dart';
import 'package:app/presentation/widgets/dialogs/create_task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadTasks();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded && state.noticeMessage != null) {
            AppSnackbars.showNotice(context, state.noticeMessage!);
          }
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    onThemeToggle: widget.onThemeToggle,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<StreaksBloc, StreaksState>(
                    builder: (context, state) {
                      final streak =
                          state is StreaksLoaded ? state.totalCurrentStreak : 0;
                      return HomeStreakHero(streak: streak);
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: HomeProtocolHeader(
                    selectedDate: _selectedDate,
                    onTap: _selectDate,
                  ),
                ),
                HomeTaskSliver(
                  onRetry: _loadTasks,
                  onEditTask: _showTaskEditor,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        label: const Text(
          'AÑADIR TAREA',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
      ),
    );
  }

  void _loadTasks() {
    context.read<TaskBloc>().add(TasksByDateRequested(_selectedDate));
  }

  Future<void> _selectDate() async {
    final selectedDate = await showAppDatePicker(
      context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() => _selectedDate = selectedDate);
    _loadTasks();
  }

  void _showCreateDialog() {
    TaskEditorSheet.show(context);
  }

  void _showTaskEditor(Task task) {
    TaskEditorSheet.show(context, initialTask: task);
  }
}
