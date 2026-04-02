---
phase: 06-performance-optimization
plan: 01
type: execute
wave: 1
depends_on: [PHASE-05]
files_modified:
  - lib/presentation/screens/home/widgets/home_task_sliver.dart
  - lib/presentation/screens/home/home_screen.dart
  - lib/presentation/blocs/task/task_bloc.dart
autonomous: true
requirements:
  - PERF-01: Virtualize task list rendering
  - PERF-02: Add lazy loading for calendar events
  - PERF-03: Memoize frequently rebuilt widgets

must_haves:
  truths:
    - Task list renders efficiently with 100+ tasks
    - Calendar events load progressively, not all at once
    - Widget rebuilds are minimized through memoization
  artifacts:
    - path: lib/presentation/screens/home/widgets/home_task_sliver.dart
      provides: Virtualized task list using SliverList
    - path: lib/presentation/blocs/task/task_bloc.dart
      provides: Lazy loading state management
  key_links:
    - from: home_task_sliver.dart
      to: task_bloc.dart
      via: PaginationRequest event
---

# PHASE-06: Performance Optimization

## Objective

Improve app performance through virtualization, lazy loading, and memoization.

## Context

@lib/presentation/screens/home/widgets/home_task_sliver.dart
@lib/presentation/screens/home/home_screen.dart

## Problems Identified

1. **HomeTaskSliver** - Uses SliverList but loads ALL tasks at once
2. **No pagination** - Calendar loads 2 months of events upfront
3. **Widget rebuilds** - Some widgets rebuild unnecessarily

---

## Tasks

<task type="auto">
  <name>Task 1: Add Pagination to Task Loading</name>
  <files>lib/presentation/blocs/task/task_bloc.dart, lib/presentation/blocs/task/task_state.dart</files>
  <action>
    Add lazy loading/pagination to task bloc:

    1. Add to TaskEvent:
    ```dart
    abstract class _PaginationRequest extends TaskEvent {
      final int page;
      final int pageSize;
    }
    class TasksLoadMoreRequested extends _PaginationRequest {}
    ```

    2. Modify TaskState to include:
    ```dart
    bool get hasReachedMax; // true when all pages loaded
    int _currentPage = 0;
    ```

    3. In TaskBloc, handle TasksLoadMoreRequested:
    - Load pageSize tasks starting from current offset
    - Emit new state with appended tasks
    - Stop when returned tasks < pageSize

    4. Update HomeTaskSliver to detect scroll near bottom:
    - Use ScrollController listener
    - When within 200px of bottom, dispatch TasksLoadMoreRequested

    Page size: 20 tasks
  </action>
  <verify>flutter test passes, pagination logic works</verify>
  <done>Tasks load in pages of 20, scroll loads more</done>
</task>

<task type="auto">
  <name>Task 2: Memoize TaskTile Widgets</name>
  <files>lib/presentation/widgets/task_tile.dart, lib/presentation/widgets/task_tile_content.dart</files>
  <action>
    Prevent unnecessary rebuilds of task tiles:

    1. Wrap TaskTile with `const` where possible
    2. Use `select` in BlocBuilder to prevent full state rebuild:
    ```dart
    BlocBuilder<TaskBloc, TaskState>(
      buildWhen: (prev, curr) => 
        prev.selectedDate != curr.selectedDate ||
        prev.tasks != curr.tasks, // Only rebuild when tasks change
      builder: ...
    )
    ```

    3. Extract static parts of TaskTile into const widgets
    4. Use `RepaintBoundary` around individual task tiles

    5. For TaskTileContent - use const constructors for:
    - PriorityChip (doesn't change)
    - DateTime display (uses Intl but cache format)
    - Icon buttons (Checkmark, Delete, Edit)
  </action>
  <verify>flutter analyze --no-fatal-infos passes</verify>
  <done>Task tiles memoized, fewer unnecessary rebuilds</done>
</task>

<task type="auto">
  <name>Task 3: Lazy Load Calendar Events</name>
  <files>lib/presentation/blocs/calendar/calendar_bloc.dart, lib/presentation/screens/calendar/calendar_screen.dart</files>
  <action>
    Change calendar event loading from eager to lazy:

    1. Modify CalendarLoadRequested to include page info:
    ```dart
    class CalendarLoadRequested extends CalendarEvent {
      final DateTime start;
      final DateTime end;
      final int page; // Which "page" of months
    }
    ```

    2. In CalendarBloc:
    - Load ONE month at a time instead of 2 months upfront
    - When user navigates to adjacent month, load that month's events
    - Cache already-loaded months in state

    3. In CalendarScreen._loadEvents():
    - Change from 2-month load to 1-month load:
    ```dart
    void _loadEvents() {
      final start = DateTime(_focusedWeekStart.year, _focusedWeekStart.month, 1);
      final end = DateTime(_focusedWeekStart.year, _focusedWeekStart.month + 1, 0);
      // Load only focused month
    }
    ```

    4. Add prefetch: When week strip shows dates from next/prev month, prefetch those events when user scrolls.
  </action>
  <verify>flutter test passes, calendar loads one month at a time</verify>
  <done>Calendar events lazy loaded per month</done>
</task>

---

## Verification

1. Run `flutter analyze` - no errors
2. Run `flutter test` - all tests pass
3. Performance test (if possible):
   - Create 100+ tasks, verify list scrolls smoothly
   - Navigate calendar months, verify only needed events load

---

## Output

After completion, create `.planning/phases/06-performance-optimization/PHASE-06-01-SUMMARY.md`