import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: const Center(
        child: Icon(Icons.calendar_month, size: 80, color: Color(0xFF6366F1)),
      ),
    );
  }
}
