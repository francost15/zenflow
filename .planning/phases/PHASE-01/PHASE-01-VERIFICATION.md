# PHASE-01 Verification

## Task: PHASE-01-PLAN-02-T01 - Make auth loss and reconnect explicit

## Date: 2026-03-29

## Objective
Ensure auth loss and reconnection are signaled explicitly through typed exceptions rather than implicit empty list returns.

## Tests Written

### calendar_bloc_test.dart

| Test | Status | Description |
|------|--------|-------------|
| `connect canceled/denied → CalendarNeedsSignIn` | PASS | When `isAuthorized()` returns false, bloc emits `CalendarNeedsSignIn` |
| `token/auth loss during fetch → CalendarNeedsSignIn (not CalendarLoaded([]))` | PASS | When `getEvents()` throws `CalendarAuthRequiredException`, bloc emits `CalendarNeedsSignIn` (not `CalendarLoaded([])`) |
| `reconnect after auth success → loaded events` | PASS | After successful auth, events are loaded correctly |

## Files Modified

### lib/domain/repositories/calendar_repository.dart
- Added `CalendarAuthRequiredException` class

### lib/data/datasources/google/google_calendar_datasource.dart
- Changed `getEvents()` to throw `CalendarAuthRequiredException` instead of returning `[]` when `_calendarApi == null`
- Changed catch block in `getEvents()` to `rethrow` instead of returning `[]`

### lib/presentation/blocs/calendar/calendar_bloc.dart
- Updated catch block in `_onLoadRequested` to use `e is CalendarAuthRequiredException` instead of string matching

### test/calendar_bloc_test.dart
- Created new test file with 3 tests covering auth loss scenarios

## Test Results

```
flutter test test/calendar_bloc_test.dart
00:00 +3: All tests passed!

flutter test test/auth_bloc_test.dart
00:00 +4: All tests passed!
```

## Verification Checklist

- [x] `CalendarAuthRequiredException` defined in domain layer
- [x] Datasource throws exception (not returns empty list) when not authorized
- [x] Datasource rethrows exceptions from API calls (not swallows them)
- [x] Bloc catches typed exception and maps to `CalendarNeedsSignIn`
- [x] All tests pass
- [x] Existing auth tests still pass
