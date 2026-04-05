import 'package:app/app/main_shell.dart';
import 'package:app/core/di/injection.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/auth/auth.dart';
import 'package:app/presentation/blocs/calendar/calendar.dart';
import 'package:app/presentation/blocs/course/course.dart';
import 'package:app/presentation/blocs/streaks/streaks.dart';
import 'package:app/presentation/blocs/task/task.dart';
import 'package:app/presentation/screens/auth/login_screen.dart';
import 'package:app/presentation/screens/zen/zen_mode_screen.dart';
import 'package:app/presentation/widgets/app_snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZenFlowApp extends StatefulWidget {
  const ZenFlowApp({super.key});

  @override
  State<ZenFlowApp> createState() => _ZenFlowAppState();
}

class _ZenFlowAppState extends State<ZenFlowApp> {
  late final AuthBloc _authBloc;
  late final TaskBloc _taskBloc;
  late final StreaksBloc _streaksBloc;
  late final CourseBloc _courseBloc;
  late final CalendarBloc _calendarBloc;

  bool _showZenMode = false;
  String? _zenTaskName;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _initBlocs();
    _loadThemePreference();
  }

  void _initBlocs() {
    _authBloc = getIt<AuthBloc>()..add(AuthCheckRequested());
    _taskBloc = getIt<TaskBloc>();
    _streaksBloc = getIt<StreaksBloc>();
    _courseBloc = getIt<CourseBloc>();
    _calendarBloc = getIt<CalendarBloc>();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() => _themeMode = newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
  }

  void _enterZenMode({String? taskName}) {
    setState(() {
      _showZenMode = true;
      _zenTaskName = taskName;
    });
  }

  void _exitZenMode() {
    setState(() {
      _showZenMode = false;
      _zenTaskName = null;
    });
  }

  @override
  void dispose() {
    _authBloc.close();
    _taskBloc.close();
    _streaksBloc.close();
    _courseBloc.close();
    _calendarBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TaskRepository>.value(
      value: getIt<TaskRepository>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _taskBloc),
          BlocProvider.value(value: _streaksBloc),
          BlocProvider.value(value: _courseBloc),
          BlocProvider.value(value: _calendarBloc),
        ],
        child: MaterialApp(
          title: 'ZenFlow',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return AnimatedTheme(
              data: _themeMode == ThemeMode.dark
                  ? AppTheme.darkTheme
                  : AppTheme.lightTheme,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              child: child!,
            );
          },
          home: _showZenMode
              ? ZenModeScreen(onExit: _exitZenMode, taskName: _zenTaskName)
              : _buildMainScreen(),
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        debugPrint('Auth state changed: $state');
        if (state is AuthAuthenticated && state.noticeMessage != null) {
          AppSnackbars.showNotice(context, state.noticeMessage!);
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return MainShell(
            onZenModeToggle: _enterZenMode,
            onThemeToggle: _toggleTheme,
            isDarkMode: _themeMode == ThemeMode.dark,
          );
        }
        return const LoginScreen();
      },
    );
  }
}
