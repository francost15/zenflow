---
phase: 05-calendar-views
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/presentation/screens/calendar/calendar_screen.dart
  - lib/presentation/screens/calendar/widgets/calendar_grid.dart
  - lib/presentation/screens/calendar/widgets/calendar_week_strip.dart
  - lib/presentation/screens/calendar/widgets/calendar_header.dart
autonomous: true
requirements:
  - UX-01: Quick date selection (today, tomorrow, next week)
  - UX-02: Monthly/Weekly calendar view toggle
  - UX-03: Calendar navigation polish

must_haves:
  truths:
    - User can switch between monthly grid and weekly strip views
    - User can quickly select "Today", "Tomorrow", "Next Week" with one tap
    - Calendar navigation is smooth and responsive
  artifacts:
    - path: lib/presentation/screens/calendar/widgets/view_toggle.dart
      provides: Monthly/Weekly switcher component
    - path: lib/presentation/screens/calendar/widgets/quick_date_chips.dart
      provides: Quick date selection row
  key_links:
    - from: calendar_screen.dart
      to: view_toggle.dart
      via: stateful toggle
    - from: calendar_screen.dart
      to: quick_date_chips.dart
      via: horizontal chip row
---

# PHASE-05: Calendar Views Enhancement

## Objective

Add monthly/weekly view switcher and quick date selection chips to improve calendar usability.

## Context

@lib/presentation/screens/calendar/calendar_screen.dart
@lib/presentation/screens/calendar/widgets/calendar_grid.dart
@lib/presentation/screens/calendar/widgets/calendar_week_strip.dart

## Current State

- CalendarScreen shows week strip by default
- CalendarGrid exists but is not used in the main view
- No quick date selection (users must use date picker)

---

## Tasks

<task type="auto">
  <name>Task 1: Create View Toggle Component</name>
  <files>lib/presentation/screens/calendar/widgets/view_toggle.dart</files>
  <action>
    Create a segmented control (TabBar or ToggleButtons) that switches between:
    - "Semana" (Weekly strip - current behavior)
    - "Mes" (Monthly grid - uses CalendarGrid)

    Requirements:
    - Use Material 3 SegmentedButton or custom ToggleButtons
    - Accent color when selected
    - Animate the selection change (300ms)
    - Preserve selected date when switching views
    - Default to "Semana" to maintain current behavior

    Implementation:
    ```dart
    class CalendarViewToggle extends StatelessWidget {
      final bool isMonthly;
      final ValueChanged<bool> onChanged;
      
      // ... implementation
    }
    ```
  </action>
  <verify>flutter analyze passes, toggle renders in isolation</verify>
  <done>Toggle component exists and switches between monthly/weekly</done>
</task>

<task type="auto">
  <name>Task 2: Create Quick Date Chips</name>
  <files>lib/presentation/screens/calendar/widgets/quick_date_chips.dart</files>
  <action>
    Create horizontal row of chips for quick date selection:

    Chips:
    - "Hoy" → selects today
    - "Mañana" → selects tomorrow  
    - "Próxima semana" → selects next Monday

    Requirements:
    - Horizontal scrollable row
    - Chip style: Outlined when unselected, filled accent when selected
    - Only one chip selected at a time
    - Tap triggers onDateSelected callback

    Implementation:
    ```dart
    class QuickDateChips extends StatelessWidget {
      final DateTime selectedDate;
      final ValueChanged<DateTime> onDateSelected;
      
      // Returns today, tomorrow, or nextMonday based on today
    }
    ```
  </action>
  <verify>flutter analyze passes, chips render correctly</verify>
  <done>Quick date chips allow one-tap date selection</done>
</task>

<task type="auto">
  <name>Task 3: Integrate Views into CalendarScreen</name>
  <files>lib/presentation/screens/calendar/calendar_screen.dart</files>
  <action>
    Modify CalendarScreen to include:

    1. Add CalendarViewToggle at top (below header)
    2. Add QuickDateChips row below toggle
    3. Conditionally render:
       - When isMonthly=true: CalendarGrid with week navigation
       - When isMonthly=false: Current week strip behavior
    4. Update _selectedDate when chips are tapped

    State needed:
    ```dart
    bool _isMonthlyView = false; // default to weekly (current)
    ```

    Layout order:
    ```
    CalendarHeader
    CalendarViewToggle
    QuickDateChips  
    (isMonthly ? CalendarGrid : CalendarWeekStrip)
    CalendarStateView
    ```
  </action>
  <verify>flutter test passes, UI renders both views correctly</verify>
  <done>CalendarScreen has view toggle and quick date selection working</done>
</task>

---

## Verification

1. Run `flutter analyze` - no errors
2. Run `flutter test` - all tests pass
3. Manual verification:
   - Toggle between weekly/monthly views
   - Tap quick date chips and verify date changes
   - Verify navigation between weeks/months works

---

## Output

After completion, create `.planning/phases/05-calendar-views/PHASE-05-01-SUMMARY.md`