import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/di/injection.dart';
import 'package:app/core/utils/haptic_service.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:app/presentation/screens/home/widgets/home_header.dart';
import 'package:app/presentation/screens/home/widgets/home_protocol_header.dart';
import 'package:app/presentation/screens/home/widgets/home_task_sliver.dart';
import 'package:app/presentation/widgets/animated_fab.dart';
import 'package:app/presentation/widgets/app_snackbars.dart';
import 'package:app/presentation/widgets/date_picker_sheet_theme.dart';
import 'package:app/presentation/widgets/dialogs/create_task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Keyboard shortcut intents
class CreateTaskIntent extends Intent {
  const CreateTaskIntent();
}

class TodayIntent extends Intent {
  const TodayIntent();
}

class SyncIntent extends Intent {
  const SyncIntent();
}

class DismissIntent extends Intent {
  const DismissIntent();
}

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

  void _loadTasks() {
    context.read<TaskBloc>().add(TasksByDateRequested(_selectedDate));
  }

  void _selectToday() {
    final today = DateTime.now();
    setState(() => _selectedDate = today);
    _loadTasks();
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

  Future<void> _openTaskEditor([Task? task]) {
    return TaskEditorSheet.show(context, initialTask: task);
  }

  Future<void> _syncTasks() async {
    try {
      final taskRepo = getIt<TaskRepository>();
      final result = await taskRepo.reconcileUnsyncedTasks();
      if (mounted) {
        if (result.syncedTasks.isNotEmpty) {
          AppSnackbars.showNotice(
            context,
            '${result.syncedTasks.length} tarea(s) sincronizada(s)',
          );
        } else if (result.failedTasks.isNotEmpty) {
          AppSnackbars.showError(
            context,
            '${result.failedTasks.length} tarea(s) no se pudieron sincronizar',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, 'Error al sincronizar tareas');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            const CreateTaskIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyT):
            const TodayIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const SyncIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: {
          CreateTaskIntent: CallbackAction<CreateTaskIntent>(
            onInvoke: (_) {
              _openTaskEditor();
              return null;
            },
          ),
          TodayIntent: CallbackAction<TodayIntent>(
            onInvoke: (_) {
              _selectToday();
              return null;
            },
          ),
          SyncIntent: CallbackAction<SyncIntent>(
            onInvoke: (_) {
              _syncTasks();
              return null;
            },
          ),
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              Navigator.of(context).maybePop();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
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
                        child: HomeProtocolHeader(
                          selectedDate: _selectedDate,
                          onTap: _selectDate,
                          onSyncTap: _syncTasks,
                        ),
                      ),
                      HomeTaskSliver(
                        onRetry: _loadTasks,
                        onEditTask: _openTaskEditor,
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: AnimatedFAB(
              onPressed: () {
                HapticService.lightImpact();
                _openTaskEditor();
              },
              tooltip: 'Ctrl+N',
              heroTag: 'add_task_fab',
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'AÑADIR TAREA',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
