import 'package:flutter/material.dart';

class ZenModeToggle extends StatelessWidget {
  final VoidCallback onToggle;

  const ZenModeToggle({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onToggle,
      backgroundColor: const Color(0xFF111827),
      child: const Icon(Icons.self_improvement, color: Colors.white),
    );
  }
}
