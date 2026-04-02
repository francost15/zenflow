---
phase: 08-polish-animations
plan: 01
type: execute
wave: 1
depends_on: [PHASE-07]
files_modified:
  - lib/presentation/app.dart
  - lib/presentation/screens/home/home_screen.dart
  - lib/presentation/widgets/bottom_nav_bar.dart
  - lib/presentation/widgets/floating_action_button.dart
autonomous: true
requirements:
  - POLISH-01: Screen transition animations
  - POLISH-02: Micro-interactions (button press, FAB)
  - POLISH-03: Enhanced loading/error states

must_haves:
  truths:
    - Screen transitions have smooth fade/slide animations
    - Buttons and FABs have satisfying press animations
    - Loading states are visually engaging
  artifacts:
    - path: lib/presentation/widgets/animated_fab.dart
      provides: FAB with scale animation on press
    - path: lib/presentation/widgets/shimmer_loading.dart
      provides: Shimmer effect for loading states
  key_links:
    - from: app.dart
      to: home_screen.dart
      via: PageRouteBuilder transitions
    - from: bottom_nav_bar.dart
      to: animated_fab.dart
      via: Replace FAB with animated version
---

# PHASE-08: Polish & Animations

## Objective

Add screen transitions, micro-interactions, and enhanced visual polish.

## Context

@lib/presentation/app.dart
@lib/presentation/widgets/bottom_nav_bar.dart

## Dependencies

Requires PHASE-07 completion first (all features should be in place before polishing).

---

## Tasks

<task type="auto">
  <name>Task 1: Screen Transition Animations</name>
  <files>lib/presentation/app.dart</files>
  <action>
    Replace default page transitions with custom animated transitions:

    1. Create custom page route:
    ```dart
    class ZenFlowPageRoute<T> extends PageRouteBuilder<T> {
      final Widget page;
      
      ZenFlowPageRoute({required this.page})
          : super(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              transitionDuration: Duration(milliseconds: 300),
            );
    }
    ```

    2. Apply to Navigator.push in app.dart
    3. For bottom nav tab switches, use AnimatedSwitcher with FadeTransition:
    ```dart
    AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: TabContent(key: ValueKey(currentIndex)),
      transitionBuilder: (child, animation) => 
        FadeTransition(opacity: animation, child: child),
    )
    ```

    4. Use hero animations for task cards going to detail view.
  </action>
  <verify>flutter analyze passes, transitions are smooth</verify>
  <done>Screen transitions have fade+slide animations</done>
</task>

<task type="auto">
  <name>Task 2: FAB Micro-interactions</name>
  <files>lib/presentation/widgets/animated_fab.dart</files>
  <action>
    Enhance FloatingActionButton with satisfying micro-interactions:

    1. Create AnimatedFAB widget:
    ```dart
    class AnimatedFAB extends StatefulWidget {
      final VoidCallback onPressed;
      final Widget child;
      final String heroTag;
      
      const AnimatedFAB({
        super.key,
        required this.onPressed,
        required this.child,
        this.heroTag = 'fab',
      });
    }

    class _AnimatedFABState extends State<AnimatedFAB>
        with SingleTickerProviderStateMixin {
      late AnimationController _controller;
      late Animation<double> _scaleAnimation;
      
      @override
      void initState() {
        _controller = AnimationController(
          duration: Duration(milliseconds: 150),
          vsync: this,
        );
        _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      }
      
      @override
      void dispose() { _controller.dispose(); }
      
      @override
      Widget build(BuildContext context) {
        return GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onPressed();
          },
          onTapCancel: () => _controller.reverse(),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FloatingActionButton(
              heroTag: widget.heroTag,
              onPressed: null, // Handled by GestureDetector
              child: widget.child,
            ),
          ),
        );
      }
    }
    ```

    2. Replace FAB in HomeScreen and StreaksScreen with AnimatedFAB
    3. Add heroTag to preserve FAB identity across navigation

    Add additional micro-interactions:
    - On long press: show tooltip with shortcut hint
    - On secondary tap (right click on desktop): show speed dial menu
  </action>
  <verify>flutter analyze passes, FAB animates on press</verify>
  <done>FAB has scale animation on tap, feels responsive</done>
</task>

<task type="auto">
  <name>Task 3: Shimmer Loading States</name>
  <files>lib/presentation/widgets/shimmer_loading.dart</files>
  <action>
    Replace basic LoadingIndicator with shimmer effect:

    1. Create ShimmerLoading widget:
    ```dart
    class ShimmerLoading extends StatefulWidget {
      final double width;
      final double height;
      final BorderRadius borderRadius;
      
      const ShimmerLoading({
        super.key,
        required this.width,
        required this.height,
        this.borderRadius = BorderRadius.zero,
      });
    }

    // Uses AnimationController + Shader for shimmer effect
    // Light/dark theme aware
    ```

    2. Create skeleton loaders for common screens:
    ```dart
    class TaskListSkeleton extends StatelessWidget {
      // Shows 5-6 shimmer task tiles
    }

    class CalendarSkeleton extends StatelessWidget {
      // Shows shimmer week strip + event placeholders
    }

    class CourseCardSkeleton extends StatelessWidget {
      // Shows shimmer course card
    }
    ```

    3. Replace LoadingIndicator usage in:
    - HomeScreen (while loading tasks)
    - CalendarScreen (while loading events)
    - CoursesScreen (while loading courses)

    4. In ErrorState, add "pulse" animation to icon before showing retry.
  </action>
  <verify>flutter analyze passes, shimmer renders correctly</verify>
  <done>Loading states show engaging shimmer animation</done>
</task>

<task type="auto">
  <name>Task 4: Bottom Nav Enhancement</name>
  <files>lib/presentation/widgets/bottom_nav_bar.dart</files>
  <action>
    Enhance bottom navigation with animated feedback:

    1. Add scale animation to selected item:
    ```dart
    _buildDestination(...) {
      return AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: Duration(milliseconds: 200),
        child: Icon(...),
      );
    }
    ```

    2. Add color animation:
    ```dart
    AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: isSelected ? 64 : 56,
      height: isSelected ? 64 : 56,
      // Visual feedback on selection
    )
    ```

    3. Add subtle bounce on tap:
    ```dart
    AnimatedScale(
      scale: isSelected ? 1.0 : 0.95,
      duration: Duration(milliseconds: 100),
      child: // icon container
    )
    ```

    4. Ensure backdrop blur remains smooth during animation.
  </action>
  <verify>flutter analyze passes, nav animations are smooth</verify>
  <done>Bottom nav has satisfying tap animations</done>
</task>

---

## Verification

1. Run `flutter analyze` - no errors
2. Run `flutter test` - all tests pass
3. Manual verification:
   - Navigate between tabs - observe transition
   - Tap FAB - observe scale animation
   - Navigate to loading screens - observe shimmer
   - Navigate - observe bottom nav animation

---

## Output

After completion, create `.planning/phases/08-polish-animations/PHASE-08-01-SUMMARY.md`