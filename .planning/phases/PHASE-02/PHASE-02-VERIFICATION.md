# PHASE-02-VERIFICATION

## Task: PHASE-02-PLAN-01-T01

**Task:** Trigger reconciliation after login and manual calendar connect

## Verification Steps

### 1. Tests Pass

```bash
cd /home/franco-ubuntu/Desktop/app/.worktrees/bootstrap
flutter test
```

**Result:** All 55 tests pass, including:
- `test/auth_bloc_test.dart` - 6 tests pass
  - `AuthCheckRequested restores Calendar link state for persisted sessions`
  - `AuthGoogleSignInRequested links Google Calendar after login`
  - `AuthSignOutRequested clears cached Calendar authorization`
  - `AuthGoogleSignInRequested still authenticates when Calendar linking fails`
  - `AuthGoogleSignInRequested triggers reconciliation for unsynced tasks after successful calendar link`
  - `AuthGoogleSignInRequested still succeeds if reconciliation fails; notice is surfaced`
- `test/calendar_bloc_test.dart` - 5 tests pass
  - `CalendarBloc connect canceled/denied → CalendarNeedsSignIn`
  - `CalendarBloc token/auth loss during fetch → CalendarNeedsSignIn`
  - `CalendarBloc reconnect after auth success → loaded events`
  - `CalendarBloc manual calendar connect triggers reconciliation for unsynced tasks`
  - `CalendarBloc manual calendar connect still succeeds if reconciliation fails; notice is surfaced`

### 2. Code Analyzes Cleanly

```bash
flutter analyze lib/presentation/blocs/auth/auth_bloc.dart \
  lib/presentation/blocs/calendar/calendar_bloc.dart \
  lib/data/repositories/task_repository_impl.dart \
  lib/domain/repositories/task_repository.dart \
  lib/data/datasources/firestore/task_datasource.dart \
  lib/core/di/injection.dart
```

**Result:** No issues found.

### 3. Implementation Evidence

**AuthBloc after successful Google login + linked calendar:**
- Calls `TaskRepository.reconcileUnsyncedTasks()`
- Surfaces notice message with sync results
- Login succeeds even if reconciliation fails

**CalendarBloc after successful manual calendar connect:**
- Calls `TaskRepository.reconcileUnsyncedTasks()`
- Surfaces notice message with sync results
- Connection succeeds even if reconciliation fails

## Files Modified

| File | Changes |
|------|---------|
| `lib/presentation/blocs/auth/auth_bloc.dart` | Added TaskRepository injection, reconcile after successful calendar link |
| `lib/presentation/blocs/auth/auth_state.dart` | No changes (noticeMessage already exists) |
| `lib/presentation/blocs/calendar/calendar_bloc.dart` | Added TaskRepository injection, reconcile after successful connect, noticeMessage in CalendarLoaded |
| `lib/presentation/blocs/calendar/calendar_state.dart` | Added noticeMessage field to CalendarLoaded |
| `lib/data/repositories/task_repository_impl.dart` | Added reconcileUnsyncedTasks() implementation |
| `lib/domain/repositories/task_repository.dart` | Added reconcileUnsyncedTasks() to interface |
| `lib/data/datasources/firestore/task_datasource.dart` | Added getTasksWithoutCalendarEvent() |
| `lib/core/di/injection.dart` | Updated AuthBloc and CalendarBloc factories to inject TaskRepository |
| `test/auth_bloc_test.dart` | Added 2 new tests, FakeTaskRepository |
| `test/calendar_bloc_test.dart` | Added 2 new tests, FakeTaskRepository |

## Dependencies

- TaskCalendarSyncService (already implemented in Task 3)
- TaskRepository (extended with reconcileUnsyncedTasks)

## Status: COMPLETE

All tests pass and code analyzes cleanly.
