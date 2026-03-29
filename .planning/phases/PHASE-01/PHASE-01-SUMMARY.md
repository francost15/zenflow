# PHASE-01 Summary

## Task: PHASE-01-PLAN-02-T01 - Make auth loss and reconnect explicit

## Problem Statement
`GoogleCalendarDatasource.getEvents()` was returning `[]` when not authorized, which:
- Didn't distinguish between "no events" and "not authorized"
- Required fragile string-matching in the bloc to detect auth failures
- Could lead to silent auth loss where UI showed empty calendar instead of prompting to reconnect

## Solution Implemented

### 1. Typed Exception in Domain Layer
Added `CalendarAuthRequiredException` to `lib/domain/repositories/calendar_repository.dart`:
```dart
class CalendarAuthRequiredException implements Exception {
  @override
  String toString() => 'CalendarAuthRequiredException';
}
```

### 2. Datasource Throws Instead of Returning Empty List
Updated `GoogleCalendarDatasource.getEvents()`:
- Throws `CalendarAuthRequiredException` when `_calendarApi == null`
- Rethrows API exceptions instead of swallowing them with `return []`

### 3. Bloc Uses Typed Exception Handling
Updated `CalendarBloc._onLoadRequested`:
- Uses `e is CalendarAuthRequiredException` check instead of string matching
- Maps auth exceptions to `CalendarNeedsSignIn` state

## Key Behavioral Changes

| Scenario | Before | After |
|----------|--------|-------|
| `getEvents()` when not authorized | Returns `[]` | Throws `CalendarAuthRequiredException` |
| API returns 401/403 | Returns `[]` | Rethrows (bloc maps to `CalendarNeedsSignIn`) |
| Other API errors | Returns `[]` | Rethrows (bloc maps to `CalendarError`) |

## Test Coverage Added

New tests in `test/calendar_bloc_test.dart`:
- `connect canceled/denied → CalendarNeedsSignIn`
- `token/auth loss during fetch → CalendarNeedsSignIn (not CalendarLoaded([]))`
- `reconnect after auth success → loaded events`

## Files Changed

| File | Change |
|------|--------|
| `lib/domain/repositories/calendar_repository.dart` | Added `CalendarAuthRequiredException` |
| `lib/data/datasources/google/google_calendar_datasource.dart` | Throw on auth failure; rethrow on API error |
| `lib/presentation/blocs/calendar/calendar_bloc.dart` | Catch typed exception |
| `test/calendar_bloc_test.dart` | New test file with 3 tests |
| `.planning/phases/PHASE-01/PHASE-01-VERIFICATION.md` | Verification document |
| `.planning/phases/PHASE-01/PHASE-01-SUMMARY.md` | This summary |

## Status: COMPLETE

All tests pass (3 new + 4 existing auth tests = 7 total)
