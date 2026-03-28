import 'package:flutter/material.dart';

class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rachas')),
      body: const Center(
        child: Icon(
          Icons.local_fire_department,
          size: 80,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }
}
