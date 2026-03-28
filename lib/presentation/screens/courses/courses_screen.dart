import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cursos')),
      body: const Center(
        child: Icon(Icons.school, size: 80, color: Color(0xFF6366F1)),
      ),
    );
  }
}
