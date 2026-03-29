import 'package:get_it/get_it.dart';
import '../../data/datasources/firebase/auth_datasource.dart';
import '../../data/datasources/firestore/task_datasource.dart';
import '../../data/datasources/firestore/habit_datasource.dart';
import '../../data/datasources/firestore/course_datasource.dart';
import '../../data/datasources/google/google_calendar_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import '../../data/services/task_calendar_sync_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/task/task_bloc.dart';
import '../../presentation/blocs/streaks/streaks_bloc.dart';
import '../../presentation/blocs/course/course_bloc.dart';
import '../../presentation/blocs/calendar/calendar_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Initialize all dependencies. Call this in main() before runApp().
Future<void> initDependencies() async {
  // ─── Datasources ───────────────────────────────────────────────────────────

  getIt.registerLazySingleton<AuthDatasource>(() => AuthDatasource());
  getIt.registerLazySingleton<TaskDatasource>(() => TaskDatasource());
  getIt.registerLazySingleton<HabitDatasource>(() => HabitDatasource());
  getIt.registerLazySingleton<CourseDatasource>(() => CourseDatasource());
  getIt.registerLazySingleton<GoogleCalendarDatasource>(
    () => GoogleCalendarDatasource(),
  );

  // ─── Repositories ──────────────────────────────────────────────────────────

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthDatasource>()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      getIt<TaskDatasource>(),
      getIt<TaskCalendarSyncService>(),
    ),
  );
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(getIt<HabitDatasource>()),
  );
  getIt.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(getIt<CourseDatasource>()),
  );
  getIt.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(getIt<GoogleCalendarDatasource>()),
  );
  getIt.registerLazySingleton<TaskCalendarSyncService>(
    () => TaskCalendarSyncService(
      getIt<TaskDatasource>(),
      getIt<CalendarRepository>(),
    ),
  );

  // ─── BLoCs ────────────────────────────────────────────────────────────────

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      getIt<AuthRepository>(),
      getIt<CalendarRepository>(),
      getIt<TaskRepository>(),
    ),
  );
  getIt.registerFactory<TaskBloc>(() => TaskBloc(getIt<TaskRepository>()));
  getIt.registerFactory<StreaksBloc>(
    () => StreaksBloc(getIt<HabitRepository>()),
  );
  getIt.registerFactory<CourseBloc>(
    () => CourseBloc(getIt<CourseRepository>()),
  );
  getIt.registerFactory<CalendarBloc>(
    () => CalendarBloc(getIt<CalendarRepository>(), getIt<TaskRepository>()),
  );

  // ─── External services ────────────────────────────────────────────────────

  final calendarDatasource = getIt<GoogleCalendarDatasource>();
  await calendarDatasource.initialize(
    serverClientId:
        '425631623811-3ir83r6i9kb688ml7rlnj4gnuelopo5m.apps.googleusercontent.com',
  );
}
