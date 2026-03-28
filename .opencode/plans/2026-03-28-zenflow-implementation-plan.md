# ZenFlow - Plan de Implementación MVP

**Fecha:** 2026-03-28  
**Versión:** MVP Azul (Fase 1-6)

---

## Arquitectura General

**Stack:**
- Flutter 3.x (Material 3)
- Firebase (Auth, Firestore)
- Google Calendar API v3
- flutter_bloc para estado

**Estructura de Carpetas:**
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── theme/
│   ├── constants/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   └── entities/
└── presentation/
    ├── screens/
    ├── widgets/
    └── blocs/
```

---

## Chunk 1: Foundation

**Goal:** Proyecto base con Auth Firebase + Google + Theme

### Task 1.1: Setup Proyecto Flutter

**Files:**
- Create: `pubspec.yaml` (actualizado con dependencias)
- Create: `lib/main.dart` (entry point)

**Steps:**
- [ ] 1. Agregar dependencias al pubspec.yaml:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.6.0
  google_sign_in: ^6.2.2
  googleapis: ^14.0.0
  flutter_bloc: ^9.1.0
  equatable: ^2.0.7
  intl: ^0.20.2
  shared_preferences: ^2.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

- [ ] 2. Crear main.dart básico con Firebase init:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ZenFlowApp());
}
```

- [ ] 3. Commit

```bash
git add pubspec.yaml lib/main.dart
git commit -m "feat(foundation): setup Flutter project with dependencies"
```

---

### Task 1.2: Theme y Constants

**Files:**
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/core/constants/app_colors.dart`
- Create: `lib/core/constants/app_strings.dart`

**Steps:**
- [ ] 1. Crear app_colors.dart:

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF10B981);
  static const accent = Color(0xFFF59E0B);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const error = Color(0xFFEF4444);
  
  // Heatmap greens
  static const heatmapEmpty = Color(0xFFEBEDF0);
  static const heatmapLight = Color(0xFF9BE9A8);
  static const heatmapMedium = Color(0xFF40C463);
  static const heatmapDark = Color(0xFF30A14E);
  static const heatmapDarkest = Color(0xFF216E39);
}
```

- [ ] 2. Crear app_theme.dart:

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundRadius: 24,
      ),
    );
  }
}
```

- [ ] 3. Commit

```bash
git add lib/core/theme/ lib/core/constants/
git commit -m "feat(theme): add Material 3 theme and color constants"
```

---

### Task 1.3: Auth Firebase + Google

**Files:**
- Create: `lib/data/datasources/firebase/auth_datasource.dart`
- Create: `lib/data/repositories/auth_repository_impl.dart`
- Create: `lib/domain/repositories/auth_repository.dart`
- Create: `lib/presentation/blocs/auth/auth_bloc.dart`
- Create: `lib/presentation/blocs/auth/auth_event.dart`
- Create: `lib/presentation/blocs/auth/auth_state.dart`
- Create: `lib/presentation/screens/auth/login_screen.dart`

**Steps:**
- [ ] 1. Crear auth_repository.dart (interface):

```dart
abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
```

- [ ] 2. Crear auth_datasource.dart (implementación Firebase):

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
}
```

- [ ] 3. Crear BLoC para Auth (events, states, bloc)

- [ ] 4. Crear login_screen.dart con Google Sign-In button

- [ ] 5. Commit

```bash
git add lib/data/ lib/domain/ lib/presentation/blocs/auth/ lib/presentation/screens/auth/
git commit -m "feat(auth): Firebase Auth with Google Sign-In"
```

---

## Chunk 2: Navegación y Estructura Base

**Goal:** Bottom navigation + Router + App shell

### Task 2.1: Bottom Navigation Bar

**Files:**
- Create: `lib/presentation/widgets/bottom_nav_bar.dart`
- Create: `lib/presentation/screens/home/home_screen.dart`
- Create: `lib/presentation/screens/calendar/calendar_screen.dart`
- Create: `lib/presentation/screens/streaks/streaks_screen.dart`
- Create: `lib/presentation/screens/courses/courses_screen.dart`
- Create: `lib/presentation/screens/profile/profile_screen.dart`
- Modify: `lib/app/app.dart` (agregar navegación)

**Steps:**
- [ ] 1. Crear bottom_nav_bar.dart con 5 items
- [ ] 2. Crear screens placeholder para cada tab
- [ ] 3. Integrar en app.dart con GoRouter o Navigator
- [ ] 4. Commit

---

### Task 2.2: GoRouter Setup

**Files:**
- Create: `lib/app/router.dart`
- Modify: `lib/app/app.dart`

**Steps:**
- [ ] 1. Crear router.dart con rutas:
  - `/login` - login screen
  - `/` - home (con nested routes)
    - `/today`
    - `/calendar`
    - `/streaks`
    - `/courses`
    - `/profile`
- [ ] 2. Setup redirect logic (si no auth → login)
- [ ] 3. Commit

---

## Chunk 3: Google Calendar Integration

**Goal:** OAuth + listar eventos + vista mensual

### Task 3.1: Google Calendar OAuth

**Files:**
- Create: `lib/data/datasources/google/google_calendar_datasource.dart`
- Create: `lib/data/repositories/calendar_repository_impl.dart`
- Create: `lib/domain/repositories/calendar_repository.dart`
- Create: `lib/presentation/blocs/calendar/calendar_bloc.dart`

**Steps:**
- [ ] 1. Setup Google Cloud Console (documentar pasos para usuario)
- [ ] 2. Crear google_calendar_datasource.dart con:
  - OAuth flow
  - List events
  - Create event
  - Update event
  - Delete event
- [ ] 3. Crear repository interface + impl
- [ ] 4. Crear CalendarBloc
- [ ] 5. Commit

---

### Task 3.2: Calendar Screen UI

**Files:**
- Create: `lib/presentation/screens/calendar/widgets/calendar_grid.dart`
- Create: `lib/presentation/screens/calendar/widgets/event_card.dart`
- Modify: `lib/presentation/screens/calendar/calendar_screen.dart`

**Steps:**
- [ ] 1. Crear CalendarGrid widget (month view)
- [ ] 2. Crear EventCard widget
- [ ] 3. Integrar con CalendarBloc
- [ ] 4. Commit

---

## Chunk 4: Tasks (CRUD)

**Goal:** Sistema de tareas completo

### Task 4.1: Task Model + Firestore

**Files:**
- Create: `lib/domain/entities/task.dart`
- Create: `lib/data/models/task_model.dart`
- Create: `lib/data/datasources/firestore/task_datasource.dart`
- Create: `lib/data/repositories/task_repository_impl.dart`
- Create: `lib/domain/repositories/task_repository.dart`

**Steps:**
- [ ] 1. Crear Task entity:
```dart
class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TimeOfDay? dueTime;
  final TaskPriority priority; // low, medium, high
  final TaskStatus status; // pending, inProgress, completed
  final String? courseId;
  final List<String> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

- [ ] 2. Crear datasource con Firestore CRUD
- [ ] 3. Crear repository interface + impl
- [ ] 4. Commit

---

### Task 4.2: TaskBloc + UI

**Files:**
- Create: `lib/presentation/blocs/task/task_bloc.dart`
- Create: `lib/presentation/blocs/task/task_event.dart`
- Create: `lib/presentation/blocs/task/task_state.dart`
- Create: `lib/presentation/widgets/task_tile.dart`
- Create: `lib/presentation/screens/home/widgets/task_list.dart`
- Modify: `lib/presentation/screens/home/home_screen.dart`

**Steps:**
- [ ] 1. Crear TaskBloc con eventos: LoadTasks, AddTask, UpdateTask, DeleteTask, ToggleTask
- [ ] 2. Crear TaskTile widget (checkbox, title, date, priority dot)
- [ ] 3. Crear TaskList widget
- [ ] 4. Integrar en HomeScreen
- [ ] 5. Commit

---

## Chunk 5: Streaks System

**Goal:** Hábitos + Gráfico de calor + Contador

### Task 5.1: Habit Model + Firestore

**Files:**
- Create: `lib/domain/entities/habit.dart`
- Create: `lib/data/models/habit_model.dart`
- Create: `lib/data/datasources/firestore/habit_datasource.dart`
- Create: `lib/data/repositories/habit_repository_impl.dart`
- Create: `lib/domain/repositories/habit_repository.dart`

**Steps:**
- [ ] 1. Crear Habit entity:
```dart
class Habit {
  final String id;
  final String name;
  final String? icon;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckIn;
  final List<DateTime> checkInHistory;
  final bool isActive;
}
```

- [ ] 2. Crear datasource + repository
- [ ] 3. Commit

---

### Task 5.2: StreaksBloc + Heatmap + UI

**Files:**
- Create: `lib/presentation/blocs/streaks/streaks_bloc.dart`
- Create: `lib/presentation/widgets/heatmap_chart.dart`
- Create: `lib/presentation/widgets/streak_counter.dart`
- Create: `lib/presentation/screens/streaks/widgets/habit_card.dart`
- Modify: `lib/presentation/screens/streaks/streaks_screen.dart`

**Steps:**
- [ ] 1. Crear StreaksBloc con lógica de racha (si pierde día → reset to 0)
- [ ] 2. Crear HeatmapChart (52 semanas × 7 días)
- [ ] 3. Crear StreakCounter (número grande con 🔥)
- [ ] 4. Crear HabitCard con toggle check-in
- [ ] 5. Commit

---

## Chunk 6: Courses

**Goal:** Materias + Progreso

### Task 6.1: Course Model + Firestore

**Files:**
- Create: `lib/domain/entities/course.dart`
- Create: `lib/data/models/course_model.dart`
- Create: `lib/data/datasources/firestore/course_datasource.dart`
- Create: `lib/data/repositories/course_repository_impl.dart`
- Create: `lib/domain/repositories/course_repository.dart`

**Steps:**
- [ ] 1. Crear Course entity:
```dart
class Course {
  final String id;
  final String name;
  final Color color;
  final String? professor;
  final List<Schedule> schedule; // día y hora
  final String? notes;
  final double progress; // 0.0 - 1.0
}
```

- [ ] 2. Crear datasource + repository
- [ ] 3. Commit

---

### Task 6.2: CourseBloc + UI

**Files:**
- Create: `lib/presentation/blocs/course/course_bloc.dart`
- Create: `lib/presentation/widgets/course_card.dart`
- Modify: `lib/presentation/screens/courses/courses_screen.dart`

**Steps:**
- [ ] 1. Crear CourseBloc
- [ ] 2. Crear CourseCard con progress bar
- [ ] 3. Crear CoursesScreen con lista de CourseCards
- [ ] 4. Commit

---

## Chunk 7: Modo Zen + polish

**Goal:** Modo Zen completo + offline + UI polish

### Task 7.1: Modo Zen

**Files:**
- Create: `lib/presentation/screens/zen/zen_mode_screen.dart`
- Create: `lib/presentation/widgets/zen_mode_toggle.dart`
- Modify: `lib/presentation/blocs/settings/settings_cubit.dart`

**Steps:**
- [ ] 1. Crear ZenModeScreen (fondo oscuro #111827, hora grande, siguiente evento, tarea activa)
- [ ] 2. Crear ZenModeToggle widget (FAB o gesture)
- [ ] 3. Commit

---

### Task 7.2: Offline Support

**Files:**
- Modify: `lib/data/datasources/firestore/*_datasource.dart` (agregar offline persistence)
- Create: `lib/core/utils/connectivity_service.dart`

**Steps:**
- [ ] 1. Habilitar Firestore offline persistence en main.dart:
```dart
Firestore.instance.settings = Settings(persistenceEnabled: true);
```
- [ ] 2. Crear ConnectivityService para detectar offline/online
- [ ] 3. Mostrar indicador de conexión en UI
- [ ] 4. Commit

---

### Task 7.3: UI Polish

**Files:**
- Modificar various screens para consistencia
- Add: `lib/presentation/widgets/empty_state.dart`
- Add: `lib/presentation/widgets/loading_indicator.dart`
- Add: `lib/presentation/widgets/error_widget.dart`

**Steps:**
- [ ] 1. Agregar estados vacíos y loading a cada screen
- [ ] 2. Agregar manejo de errores consistente
- [ ] 3. Commit

---

## Verificación de Implementación

Para verificar que todo está completo:

```bash
# 1. Auth funciona
flutter test test/auth/

# 2. Calendar sincroniza
# Crear evento en app → aparece en Google Calendar
# Crear evento en Google → aparece en app

# 3. Tasks CRUD
flutter test test/tasks/

# 4. Streaks se resetean a 0 al perder día
# Simular perder un día → verificar currentStreak = 0

# 5. Cursos con progreso
flutter test test/courses/

# 6. Offline funciona
# Desconectar internet → app funciona → reconectar → sync
```

---

## Archivos a Crear/Modificar (Resumen)

| Fase | Archivos |
|------|----------|
| Foundation | pubspec.yaml, main.dart, theme/*, constants/* |
| Auth | auth_datasource.dart, auth_repository, AuthBloc, login_screen |
| Navegación | bottom_nav_bar.dart, router.dart, app.dart, 5 screens |
| Calendar | google_calendar_datasource, CalendarBloc, calendar_grid, event_card |
| Tasks | task.dart, task_model, task_datasource, TaskBloc, task_tile |
| Streaks | habit.dart, habit_datasource, StreaksBloc, heatmap_chart, streak_counter |
| Courses | course.dart, course_datasource, CourseBloc, course_card |
| Zen | zen_mode_screen, zen_mode_toggle |
| Offline | connectivity_service, datasource updates |

**Total archivos a crear: ~40-50**

---

## Notas para Usuario (Setup Requerido)

1. **Firebase Console:**
   - Crear proyecto Firebase
   - Habilitar Authentication (Google + Email)
   - Crear Firestore database
   - Descargar google-services.json (Android) / GoogleService-Info.plist (iOS)

2. **Google Cloud Console:**
   - Crear proyecto
   - Habilitar Google Calendar API
   - Crear OAuth 2.0 credentials
   - Configurar redirect URIs

3. **Flutter:**
   - flutter pub get
   - flutter doctor
   - Configurar SHA-1 para Android
