# ZenFlow 📱

**Tu agenda personal conectada a Google Calendar con seguimiento de hábitos y rachas**

Flutter
Firebase
License

---

## ✨ Características

### 📅 Calendario Unificado

- Sincronización bidireccional con Google Calendar
- Vista mensual y semanal
- Colores por evento

### ✅ Gestor de Tareas

- CRUD completo con prioridades (alta, media, baja)
- Fechas y horas límite
- Barra de progreso

### 🔥 Sistema de Rachas

- Gráfico de calor tipo GitHub (365 días)
- Contador de días consecutivos
- **Al perder un día, la racha se reinicia a 0** (sin excusas)

### 📚 Cursos/Materias

- Tarjetas por materia con colores personalizados
- Horarios de clase
- Barra de progreso por materia

### 🧘 Modo Zen

- Interfaz minimalista oscura
- Solo muestra: hora actual y siguiente evento
- Elimina distracciones

### 📴 Modo Offline

- Funciona sin conexión a internet
- Sincroniza cuando recupera conexión

---

## 🏗️ Arquitectura

```
lib/
├── main.dart                      # Entry point
├── app/
│   └── app.dart                  # App widget con BLoC providers
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Paleta de colores
│   │   └── app_strings.dart     # Strings reutilizables
│   ├── theme/
│   │   └── app_theme.dart      # Material 3 theme
│   └── utils/
│       └── connectivity_service.dart
├── data/
│   ├── datasources/
│   │   ├── firebase/
│   │   │   └── auth_datasource.dart
│   │   ├── firestore/
│   │   │   ├── task_datasource.dart
│   │   │   ├── habit_datasource.dart
│   │   │   └── course_datasource.dart
│   │   └── google/
│   │       └── google_calendar_datasource.dart
│   ├── models/
│   │   ├── task_model.dart
│   │   ├── habit_model.dart
│   │   └── course_model.dart
│   └── repositories/
│       └── *_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── task.dart
│   │   ├── habit.dart
│   │   └── course.dart
│   └── repositories/
│       └── *_repository.dart
└── presentation/
    ├── blocs/
    │   ├── auth/
    │   ├── task/
    │   ├── calendar/
    │   ├── streaks/
    │   └── course/
    ├── screens/
    │   ├── auth/login_screen.dart
    │   ├── home/home_screen.dart
    │   ├── calendar/calendar_screen.dart
    │   ├── streaks/streaks_screen.dart
    │   ├── courses/courses_screen.dart
    │   ├── profile/profile_screen.dart
    │   └── zen/zen_mode_screen.dart
    ├── widgets/
    │   ├── bottom_nav_bar.dart
    │   ├── task_tile.dart
    │   ├── heatmap_chart.dart
    │   ├── streak_counter.dart
    │   ├── course_card.dart
    │   └── dialogs/
    └── screens/streaks/widgets/
        └── habit_card.dart
```

---

## 🚀 Setup

### Prerequisites

- Flutter 3.x
- Dart 3.x
- Firebase CLI (opcional)
- Cuenta de Google Cloud

### 1. Clonar el Repo

```bash
git clone <repo-url>
cd app
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

#### Opción A: Firebase CLI (Recomendado)

```bash
# Instalar Firebase CLI si no lo tienes
npm install -g firebase-tools

# Login
firebase login

# Inicializar Firebase en el proyecto
firebase init
```

Selecciona:

- **Authentication** → Google, Email/Password
- **Firestore** → Create database

#### Opción B: Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto
3. Habilita **Authentication**:
  - Proveedor: **Google**
  - Proveedor: **Email/Password**
4. Crea **Firestore Database**:
  - Modo: **Start in test mode** (para desarrollo)
  - Ubicación: La más cercana a ti
5. Registra tu app:
  - Android: Añade app → descarga `google-services.json`
  - iOS: Añade app → descarga `GoogleService-Info.plist`

#### Configurar Android

1. Descarga `google-services.json` desde Firebase Console y colócalo en `android/app/google-services.json` (no lo subas al repositorio: está en `.gitignore`). Puedes partir de `android/app/google-services.json.example` como referencia de estructura.

2. **Solo si compilas para Web o escritorio (Linux/Windows/macOS):** copia `.env.example` a `.env`, rellena las variables `FIREBASE_WEB_*` (y las compartidas) y usa `flutter run --dart-define-from-file=.env`. **En Android e iOS no hace falta** el `.env` para arrancar: Firebase toma la config nativa de `google-services.json` / plist.

3. El plugin **Google Services** ya está referenciado en `android/settings.gradle.kts` y `android/app/build.gradle.kts`; no hace falta duplicar la configuración clásica de Groovy salvo que cambies de estructura.

**Seguridad:** si este repositorio alguna vez fue público con claves en el historial, en [Firebase Console](https://console.firebase.google.com/) → Project settings → General, considera **restringir la API key** (HTTP referrers / apps) y revisar clientes OAuth.

#### Configurar iOS

1. Coloca `GoogleService-Info.plist` en:
  ```
   ios/Runner/GoogleService-Info.plist
  ```
2. En Xcode:
  - Right click Runner → **Add Files to Runner**
  - Selecciona `GoogleService-Info.plist`
  - **Copy items if needed** ✓

### 4. Configurar Google Calendar API

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto (o usa uno existente)
3. Habilita **Google Calendar API**:
  - Ve a **APIs & Services** → **Library**
  - Busca "Google Calendar API"
  - Click **Enable**
4. Configura OAuth Consent:
  - **APIs & Services** → **OAuth consent screen**
  - User Type: **External**
  - App name: ZenFlow
   -Scopes: `../auth/calendar.readonly` y `../auth/calendar`
5. Crea OAuth Credentials:
  - **APIs & Services** → **Credentials**
  - **Create Credentials** → **OAuth client ID**
  - Application type: **Web application** (o Android/iOS según tu caso)
  - Anota el **Client ID**

### 5. Variables de entorno (Firebase en Dart)

Para **Web y escritorio**, las claves van en `.env` y se inyectan con `--dart-define-from-file=.env` (ver [`.env.example`](.env.example)). Para **Android/iOS**, basta con los archivos nativos de Firebase; `.env` es opcional.

### 6. Ejecutar

```bash
# Android / iOS (usa google-services.json o plist)
flutter run

# Web o Linux/Windows/macOS (necesitas .env; ver sección 5)
flutter run -d chrome --dart-define-from-file=.env
flutter run -d linux --dart-define-from-file=.env

# Build release Android — sin .env en Dart
flutter build apk --release

# Build web / escritorio
flutter build web --dart-define-from-file=.env
```

---

## 📱 Screenshots

soon

---

## 💻 Linux (Flutter vía snap)

Si aparecen avisos como `GLIBC_2.38` o `Failed to load module: ... libgvfsdbus.so`, en muchos casos son solo ruido del entorno: el snap de Flutter enlaza contra una `libc` distinta a la del sistema. Si molestan o bloquean herramientas, instala Flutter con el [paquete oficial (tarball/git)](https://docs.flutter.dev/get-started/install/linux) o [FVM](https://fvm.app/) y prioriza ese `flutter` en tu `PATH` frente al de snap.

---

## 🧪 Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test widget_test.dart

# Integration tests
flutter test integration_test/
```

---

## 🤝 Contribuir

1. Fork el repo
2. Crea tu feature branch (`git checkout -b feature/nueva-funcion`)
3. Commit tus cambios (`git commit -m 'feat: agregar nueva funcion'`)
4. Push al branch (`git push origin feature/nueva-funcion`)
5. Abre un Pull Request

---

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para detalles.

---

## 🙏 Créditos

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Google Calendar API](https://developers.google.com/calendar)
- [Material Design 3](https://m3.material.io/)

---

Hecho con ❤️ para organizar tu vida