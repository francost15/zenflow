# ZenFlow 📱

**Tu agenda personal conectada a Google Calendar con seguimiento de hábitos y rachas**

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-9.x-orange?logo=firebase)
![License](https://img.shields.io/badge/license-MIT-green)

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

1. Coloca `google-services.json` en:
   ```
   android/app/google-services.json
   ```

2. Edita `android/build.gradle`:
   ```groovy
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```

3. Edita `android/app/build.gradle`:
   ```groovy
   plugins {
       id 'com.google.gms.google-services'
   }
   ```

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

### 5. Variables de Entorno (Opcional)

Crea `.env` en la raíz si necesitas configuración custom:

```env
FIREBASE_API_KEY=tu-api-key
FIREBASE_PROJECT_ID=tu-project-id
GOOGLE_CLIENT_ID=tu-client-id
```

### 6. Ejecutar

```bash
# Desarrollo
flutter run

# Build release
flutter build apk --release
flutter build ios --release
```

---

## 📱 Screenshots

soon

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
