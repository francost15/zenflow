---
phase: 07-voice-input-accessibility
plan: 01
type: execute
wave: 1
depends_on: [PHASE-06]
files_modified:
  - lib/presentation/widgets/dialogs/create_task_dialog.dart
  - lib/presentation/widgets/task_tile.dart
  - lib/core/utils/haptic_service.dart
autonomous: true
requirements:
  - ACCESS-01: Voice input for task creation
  - ACCESS-02: Haptic feedback on task completion
  - ACCESS-03: Keyboard shortcuts (power user mode)

must_haves:
  truths:
    - User can create task by speaking (voice-to-text)
    - Completing a task triggers haptic feedback
    - Power users can use keyboard shortcuts
  artifacts:
    - path: lib/core/utils/haptic_service.dart
      provides: Unified haptic feedback
    - path: lib/presentation/widgets/voice_input_button.dart
      provides: Microphone button with voice-to-text
  key_links:
    - from: create_task_dialog.dart
      to: voice_input_button.dart
      via: TextField suffix icon
    - from: task_tile.dart
      to: haptic_service.dart
      via: onComplete callback
---

# PHASE-07: Voice Input & Accessibility

## Objective

Add voice input for task creation, haptic feedback, and keyboard shortcuts.

## Context

@lib/presentation/widgets/dialogs/create_task_dialog.dart
@lib/presentation/widgets/task_tile.dart

## Dependencies

Requires PHASE-06 completion first (performance optimizations should be stable).

---

## Tasks

<task type="auto">
  <name>Task 1: Create Haptic Service</name>
  <files>lib/core/utils/haptic_service.dart</files>
  <action>
    Create a unified haptic feedback service:

    ```dart
    import 'package:flutter/services.dart';

    class HapticService {
      /// Light impact - for UI interactions (toggles, chips)
      static void lightImpact() {
        HapticFeedback.lightImpact();
      }

      /// Medium impact - for task completion
      static void mediumImpact() {
        HapticFeedback.mediumImpact();
      }

      /// Heavy impact - for important actions (delete, sync)
      static void heavyImpact() {
        HapticFeedback.heavyImpact();
      }

      /// Selection click - for selections
      static void selectionClick() {
        HapticFeedback.selectionClick();
      }

      /// Success pattern - for successful completion
      static Future<void> success() async {
        await HapticFeedback.mediumImpact();
        await Future.delayed(Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
      }

      /// Error pattern - for errors
      static Future<void> error() async {
        await HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
      }
    }
    ```

    Export from core/utils barrel file.
  </action>
  <verify>flutter analyze passes</verify>
  <done>HapticService provides consistent haptic feedback patterns</done>
</task>

<task type="auto">
  <name>Task 2: Add Haptic Feedback to Task Completion</name>
  <files>lib/presentation/widgets/task_tile.dart</files>
  <action>
    Add haptic feedback to task interactions:

    1. Import HapticService
    2. On task completion (checkmark tap):
    ```dart
    onCheckmarkTap: () {
      HapticService.success(); // Success pattern
      // existing completion logic
    }
    ```

    3. On task tile long-press (edit):
    ```dart
    onLongPress: () {
      HapticService.lightImpact();
      // existing edit logic
    }
    ```

    4. On delete (if swipe-to-delete enabled):
    ```dart
    onDismissed: (direction) {
      HapticService.heavyImpact();
      // existing delete logic
    }
    ```

    5. On FAB tap (create task):
    ```dart
    onPressed: () {
      HapticService.lightImpact();
      // existing create logic
    }
    ```
  </action>
  <verify>flutter test passes, haptic calls don't break UI</verify>
  <done>Task interactions trigger appropriate haptic feedback</done>
</task>

<task type="auto">
  <name>Task 3: Add Voice Input Button</name>
  <files>lib/presentation/widgets/voice_input_button.dart</files>
  <action>
    Create voice input button using speech_to_text package:

    1. Add dependency (check if already exists):
    ```yaml
    # pubspec.yaml
    dependencies:
      speech_to_text: ^7.0.0
    ```

    2. Create VoiceInputButton widget:
    ```dart
    class VoiceInputButton extends StatefulWidget {
      final ValueChanged<String> onResult;
      final bool isListening;
      
      const VoiceInputButton({
        super.key,
        required this.onResult,
        this.isListening = false,
      });
    }

    class _VoiceInputButtonState extends State<VoiceInputButton>
        with SingleTickerProviderStateMixin {
      // Animation for listening state (pulsing mic)
      // On tap: start listening, on result: call onResult
    }
    ```

    3. Features:
    - Show mic icon
    - When listening: animate (scale pulse), show "Escuchando..."
    - On result: add text to field, show checkmark briefly
    - Handle errors: show "No se detectó voz"

    4. Add to CreateTaskDialog TextFields:
    - Task name TextField gets voice button as suffix
    - Description TextField gets voice button as suffix
  </action>
  <verify>flutter analyze passes, voice button renders</verify>
  <done>Voice input button available in task creation dialog</done>
</task>

<task type="auto">
  <name>Task 4: Add Keyboard Shortcuts</name>
  <files>lib/presentation/app.dart, lib/presentation/screens/home/home_screen.dart</files>
  <action>
    Add keyboard shortcuts for power users:

    1. In HomeScreen, wrap body with Shortcuts and Actions:
    ```dart
    Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyN): CreateTaskIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyT): TodayIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyS): SyncIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          CreateTaskIntent: CallbackAction<CreateTaskIntent>(
            onInvoke: (_) => _openTaskEditor(),
          ),
          TodayIntent: CallbackAction<TodayIntent>(
            onInvoke: (_) => _selectToday(),
          ),
          SyncIntent: CallbackAction<SyncIntent>(
            onInvoke: (_) => _syncTasks(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(...),
        ),
      ),
    )
    ```

    2. Define intents:
    ```dart
    class CreateTaskIntent extends Intent {}
    class TodayIntent extends Intent {}
    class SyncIntent extends Intent {}
    ```

    3. Add tooltip to FAB showing "Ctrl+N" hint
    4. Document shortcuts in Settings/Profile screen

    Shortcuts:
    - `Ctrl+N` - New task
    - `Ctrl+T` - Go to today
    - `Ctrl+S` - Sync tasks
    - `Esc` - Close dialogs
  </action>
  <verify>flutter test passes, shortcuts registered correctly</verify>
  <done>Keyboard shortcuts work in home screen</done>
</task>

---

## Verification

1. Run `flutter pub get` to fetch speech_to_text
2. Run `flutter analyze` - no errors
3. Run `flutter test` - all tests pass
4. Manual verification:
   - Voice button appears in task dialog
   - Haptic feedback triggers on task completion
   - Keyboard shortcuts work

---

## Output

After completion, create `.planning/phases/07-voice-input-accessibility/PHASE-07-01-SUMMARY.md`