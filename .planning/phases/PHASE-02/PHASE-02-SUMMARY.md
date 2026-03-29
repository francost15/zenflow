# PHASE-02-SUMMARY

## Task: PHASE-02-PLAN-01-T01

**Task:** Trigger reconciliation after login and manual calendar connect

## What Was Implemented

### 1. Reconciliation Trigger on Login (AuthBloc)

When a user signs in with Google and the calendar is successfully linked:
- `TaskRepository.reconcileUnsyncedTasks()` is called
- Returns a `ReconciliationResult` with synced and failed tasks
- A notice message is surfaced describing the results
- If reconciliation fails, login still succeeds and a notice is shown

### 2. Reconciliation Trigger on Manual Calendar Connect (CalendarBloc)

When a user manually connects their Google Calendar:
- `TaskRepository.reconcileUnsyncedTasks()` is called after successful sign-in
- A notice message is surfaced describing the results
- If reconciliation fails, connection still succeeds and a notice is shown

### 3. Repository Changes

**TaskRepository interface** - Added `reconcileUnsyncedTasks()` method:
```dart
Future<ReconciliationResult> reconcileUnsyncedTasks();
```

**TaskRepositoryImpl** - Implementation delegates to TaskCalendarSyncService:
```dart
@override
Future<ReconciliationResult> reconcileUnsyncedTasks() async {
  final models = await _datasource.getTasksWithoutCalendarEvent();
  final tasks = models.map((m) => m.toEntity()).toList();
  return _syncService.reconcileUnsyncedTasks(tasks);
}
```

**TaskDatasource** - Added method to fetch tasks needing sync:
```dart
Future<List<TaskModel>> getTasksWithoutCalendarEvent() async {
  final snapshot = await _tasksRef
      .where('calendarEventId', isNull: true)
      .get();
  return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
}
```

### 4. BLoC Changes

**AuthBloc** - Now accepts `TaskRepository` and triggers reconciliation:
- Constructor: `AuthBloc(AuthRepository, CalendarRepository, TaskRepository)`
- After successful calendar link, calls `reconcileUnsyncedTasks()`
- Notice messages describe sync results or failures

**CalendarBloc** - Now accepts `TaskRepository` and triggers reconciliation:
- Constructor: `CalendarBloc(CalendarRepository, TaskRepository)`
- After successful manual connect, calls `reconcileUnsyncedTasks()`
- `CalendarLoaded` now has `noticeMessage` field
- Notice messages describe sync results or failures

### 5. DI Changes

Updated factory registrations in `injection.dart`:
```dart
getIt.registerFactory<AuthBloc>(
  () => AuthBloc(
    getIt<AuthRepository>(),
    getIt<CalendarRepository>(),
    getIt<TaskRepository>(),
  ),
);
getIt.registerFactory<CalendarBloc>(
  () => CalendarBloc(
    getIt<CalendarRepository>(),
    getIt<TaskRepository>(),
  ),
);
```

## Test Coverage

### New Tests Added

**auth_bloc_test.dart:**
- `AuthGoogleSignInRequested triggers reconciliation for unsynced tasks after successful calendar link`
- `AuthGoogleSignInRequested still succeeds if reconciliation fails; notice is surfaced`

**calendar_bloc_test.dart:**
- `CalendarBloc manual calendar connect triggers reconciliation for unsynced tasks`
- `CalendarBloc manual calendar connect still succeeds if reconciliation fails; notice is surfaced`

## User-Facing Behavior

1. **Fresh login with calendar link:**
   - User signs in with Google
   - Calendar is linked automatically
   - Any tasks missing calendar events are reconciled
   - User sees: "X tarea(s) sincronizada(s) con Google Calendar."

2. **Manual calendar connect:**
   - User goes to Settings and connects calendar
   - Any tasks missing calendar events are reconciled
   - User sees: "X tarea(s) sincronizada(s) con Google Calendar."

3. **Reconciliation failure:**
   - User sees: "Sesion iniciada. La sincronizacion de tareas pendientes fallo."
   - Login/connect still succeeds

## Files Modified

| File | Lines Changed |
|------|--------------|
| `lib/presentation/blocs/auth/auth_bloc.dart` | +15/-2 |
| `lib/presentation/blocs/calendar/calendar_bloc.dart` | +25/-5 |
| `lib/presentation/blocs/calendar/calendar_state.dart` | +3/-0 |
| `lib/data/repositories/task_repository_impl.dart` | +7/-0 |
| `lib/domain/repositories/task_repository.dart` | +2/-0 |
| `lib/data/datasources/firestore/task_datasource.dart` | +7/-0 |
| `lib/core/di/injection.dart` | +6/-4 |
| `test/auth_bloc_test.dart` | +70/-0 |
| `test/calendar_bloc_test.dart` | +80/-15 |
| `test/task_repository_impl_test.dart` | +5/-0 |
| `test/task_bloc_test.dart` | +10/-0 |

## Notes

- The implementation uses the existing `TaskCalendarSyncService.reconcileUnsyncedTasks()` from Task 3
- Reconciliation is fire-and-forget: failures do not block login or calendar connection
- Notice messages are surfaced in Spanish to match existing codebase conventions
- The `ReconciliationResult` class contains `syncedTasks` and `failedTasks` lists
