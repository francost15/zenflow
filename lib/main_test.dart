import 'package:flutter/material.dart';

// Test entry point - NOT connected to Firebase
// Use this to test UI without Firebase setup
void main() {
  runApp(const ZenFlowTestApp());
}

class ZenFlowTestApp extends StatelessWidget {
  const ZenFlowTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFlow Test',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
      ),
      home: const TestHomeScreen(),
    );
  }
}

class TestHomeScreen extends StatelessWidget {
  const TestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenFlow - Test Mode'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Color(0xFF10B981)),
            SizedBox(height: 24),
            Text(
              'UI funciona correctamente!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ahora configura Firebase para datos reales',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text(
              'Pasos para configurar Firebase:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Crear proyecto en Firebase Console'),
            Text('2. Habilitar Authentication (Google)'),
            Text('3. Crear Firestore Database'),
            Text('4. Descargar google-services.json'),
            Text('5. Colocar en android/app/'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {},
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'Rachas',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Cursos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
