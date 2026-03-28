import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../data/datasources/firebase/auth_datasource.dart';
import '../data/datasources/firestore/task_datasource.dart';
import '../data/datasources/firestore/habit_datasource.dart';
import '../data/datasources/firestore/course_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../data/repositories/habit_repository_impl.dart';
import '../data/repositories/course_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/repositories/habit_repository.dart';
import '../domain/repositories/course_repository.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_event.dart';
import '../presentation/blocs/auth/auth_state.dart';
import '../presentation/blocs/task/task_bloc.dart';
import '../presentation/blocs/calendar/calendar_bloc.dart';
import '../presentation/blocs/streaks/streaks_bloc.dart';
import '../presentation/blocs/course/course_bloc.dart';
import '../data/datasources/google/google_calendar_datasource.dart';
import '../data/repositories/calendar_repository_impl.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/calendar/calendar_screen.dart';
import '../presentation/screens/streaks/streaks_screen.dart';
import '../presentation/screens/courses/courses_screen.dart';
import '../presentation/screens/zen/zen_mode_screen.dart';
import '../presentation/widgets/bottom_nav_bar.dart';

class ZenFlowApp extends StatefulWidget {
  const ZenFlowApp({super.key});

  @override
  State<ZenFlowApp> createState() => _ZenFlowAppState();
}

class _ZenFlowAppState extends State<ZenFlowApp> {
  late final AuthDatasource _authDatasource;
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;

  late final TaskDatasource _taskDatasource;
  late final TaskRepository _taskRepository;
  late final TaskBloc _taskBloc;

  late final HabitDatasource _habitDatasource;
  late final HabitRepository _habitRepository;
  late final StreaksBloc _streaksBloc;

  late final CourseDatasource _courseDatasource;
  late final CourseRepository _courseRepository;
  late final CourseBloc _courseBloc;

  late final GoogleCalendarDatasource _calendarDatasource;
  late final CalendarRepositoryImpl _calendarRepository;
  late final CalendarBloc _calendarBloc;

  bool _showZenMode = false;
  String? _zenTaskName;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _initAuth();
    _initTask();
    _initStreaks();
    _initCourse();
    _initCalendar();
    _loadThemePreference();
  }

  void _initAuth() {
    _authDatasource = AuthDatasource();
    _authRepository = AuthRepositoryImpl(_authDatasource);
    _authBloc = AuthBloc(_authRepository)..add(AuthCheckRequested());
  }

  void _initTask() {
    _taskDatasource = TaskDatasource();
    _taskRepository = TaskRepositoryImpl(_taskDatasource);
    _taskBloc = TaskBloc(_taskRepository);
  }

  void _initStreaks() {
    _habitDatasource = HabitDatasource();
    _habitRepository = HabitRepositoryImpl(_habitDatasource);
    _streaksBloc = StreaksBloc(_habitRepository);
  }

  void _initCourse() {
    _courseDatasource = CourseDatasource();
    _courseRepository = CourseRepositoryImpl(_courseDatasource);
    _courseBloc = CourseBloc(_courseRepository);
  }

  void _initCalendar() {
    _calendarDatasource = GoogleCalendarDatasource();
    _calendarRepository = CalendarRepositoryImpl(_calendarDatasource);
    _calendarBloc = CalendarBloc(_calendarRepository);
    _calendarDatasource.initialize(
      serverClientId:
          '425631623811-3ir83r6i9kb688ml7rlnj4gnuelopo5m.apps.googleusercontent.com',
    );
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
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
    return MultiBlocProvider(
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
            ? ZenModeScreen(
                onExit: _exitZenMode,
                taskName: _zenTaskName,
              )
            : _buildMainScreen(),
      ),
    );
  }

  Widget _buildMainScreen() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        debugPrint('Auth state changed: $state');
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _MainShell(
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

class _MainShell extends StatefulWidget {
  final void Function({String? taskName}) onZenModeToggle;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const _MainShell({
    required this.onZenModeToggle,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onThemeToggle: widget.onThemeToggle,
            isDarkMode: widget.isDarkMode,
          ),
          CalendarScreen(
            onStartZenMode: (taskName) =>
                widget.onZenModeToggle(taskName: taskName),
          ),
          const CoursesScreen(),
          const StreaksScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
