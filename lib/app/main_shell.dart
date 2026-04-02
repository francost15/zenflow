import 'package:app/presentation/screens/calendar/calendar_screen.dart';
import 'package:app/presentation/screens/courses/courses_screen.dart';
import 'package:app/presentation/screens/home/home_screen.dart';
import 'package:app/presentation/screens/streaks/streaks_screen.dart';
import 'package:app/presentation/widgets/bottom_nav_bar.dart';
import 'package:app/presentation/widgets/connection_indicator.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  final void Function({String? taskName}) onZenModeToggle;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const MainShell({
    super.key,
    required this.onZenModeToggle,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ConnectionIndicator(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              ),
              child: _buildPage(_currentIndex),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildPage(int index) {
    return KeyedSubtree(
      key: ValueKey(index),
      child: switch (index) {
        0 => HomeScreen(
          onThemeToggle: widget.onThemeToggle,
          isDarkMode: widget.isDarkMode,
        ),
        1 => CalendarScreen(
          onStartZenMode: (taskName) =>
              widget.onZenModeToggle(taskName: taskName),
        ),
        2 => const CoursesScreen(),
        3 => const StreaksScreen(),
        _ => HomeScreen(
          onThemeToggle: widget.onThemeToggle,
          isDarkMode: widget.isDarkMode,
        ),
      },
    );
  }
}
