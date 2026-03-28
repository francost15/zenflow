# ZenFlow - Spec Design

**Fecha:** 2026-03-28  
**Proyecto:** ZenFlow - Gestor Personal con Google Calendar  
**Enfoque:** MVP Azul (Recomendado)

---

## 1. Concepto & Visión

**ZenFlow** es un centro de control personal que combina Google Calendar con seguimiento de hábitos y progreso académico. La app prioriza claridad sobre complejidad: una interfaz zen donde nada distrae, pero todo está accesible. El usuario siente que tiene control total sobre su tiempo y progreso.

**Usuario objetivo:** Estudiante profesional que necesita organizar cursos, trabajo, hábitos y ver su progreso sin perderse en distracciones.

---

## 2. Design Language

### Aesthetic Direction
Material Design 3 con enfoque "zen" - espacios amplios, colores suaves, tipografía clara. Inspirado en apps como Notion y Linear.

### Color Palette
- **Primary:** #6366F1 (Indigo)
- **Secondary:** #10B981 (Emerald - para rachas/completado)
- **Accent:** #F59E0B (Amber - para alertas/prioridades)
- **Background:** #FAFAFA (off-white)
- **Surface:** #FFFFFF
- **Text Primary:** #1F2937
- **Text Secondary:** #6B7280
- **Error:** #EF4444

### Typography
- **Headings:** Inter (700)
- **Body:** Inter (400, 500)
- **Monospace:** JetBrains Mono (para números/estadísticas)

### Spatial System
- Base unit: 8px
- Padding: 16px, 24px, 32px
- Border radius: 12px (cards), 8px (buttons), 24px (FAB)

### Motion Philosophy
- Transiciones suaves: 200-300ms ease-out
- Micro-interacciones en botones y tarjetas
- Sin animaciones distractoras en Modo Zen

---

## 3. Layout & Structure

### Navegación Principal (Bottom Navigation)
1. **Hoy** - Vista del día con eventos y tareas
2. **Calendario** - Vista mensual/semanal
3. **Rachas** - Gráfico de calor + calendario de puntos
4. **Cursos** - Materias, horarios, progreso
5. **Perfil** - Configuración, Google sync, modo zen

### Screens Principales

#### 3.1 Screen: Hoy (Home)
- Header con fecha actual y saludo personalizado
- Lista de eventos del día (de Google Calendar)
- Tareas del día con checkboxes
- Widget de racha activa (mini)
- FAB para agregar tarea rápida

#### 3.2 Screen: Calendario
- Selector de vista: Mes / Semana
- Grid de calendario con puntos de color por tipo
- Tap en día = lista de eventos detallada
- Sincronización bidireccional con Google Calendar

#### 3.3 Screen: Rachas
- Gráfico de calor tipo GitHub (365 días)
- Contador de racha actual (grande, centrado)
- Calendario del mes con días marcados
- Lista de hábitos activos
- Al perder racha: se reinicia a 0 (sin excusas)

#### 3.4 Screen: Cursos
- Tarjetas por materia (nombre, color, horario)
- Lista de tareas/exámenes por materia
- Barra de progreso por materia
- Vista de calendario con todas las clases

#### 3.5 Modo Zen
- Toggle en perfil o gesto rápido
- Oculta todos los distractores
- Solo muestra: hora actual, siguiente evento, tarea activa
- Fondo oscuro, tipografía grande

---

## 4. Features & Interactions

### 4.1 Autenticación Firebase + Google
- Login con Google (prioridad)
- Crear cuenta email/password (backup)
- Persistencia de sesión

### 4.2 Google Calendar Sync
- OAuth 2.0 con Google Calendar API
- Permisos: read/write calendar events
- Sincronización en background (cada 15 min)
- Conflict resolution: Google es source of truth

### 4.3 Gestión de Tareas
- CRUD de tareas
- Campos: título, descripción, fecha, hora, prioridad, materia asociada
- Estados: pending, in_progress, completed
- Sub-tareas opcionales
- Notificaciones locales

### 4.4 Sistema de Rachas
- Hábitos definidos por usuario
- Check-in diario (manual o automático basado en tareas)
- Gráfico de calor: verde oscuro = días consecutivos
- Contador visible en Home
- **Regla: al perder un día, racha = 0**

### 4.5 Gestión de Cursos
- CRUD de materias
- Campos: nombre, color, horario semanal, profesor, notas
- Asociación con eventos del calendario
- Tareas/exámenes por materia

### 4.6 Modo Offline
- Firestore offline persistence enabled
- Queue de cambios para sync cuando online
- Indicador de estado de conexión
- Conflictos: last-write-wins con timestamp

### 4.7 Modo Zen
- Activar/desactivar desde cualquier screen
- UI minimalista: hora grande, siguiente evento, tarea activa
- Sin notificaciones en modo zen (silencioso)

---

## 5. Component Inventory

### BottomNavBar
- 5 items con iconos
- Estado activo: color primary
- Badge en "Hoy" si hay tareas pendientes

### EventCard
- Hora, título, ubicación (si existe)
- Color de borde según tipo (curso, personal, trabajo)
- Tap → expande detalles

### TaskTile
- Checkbox, título, fecha
- Prioridad: color dot (alta=rojo, media=amarillo, baja=gris)
- Swipe right = complete, swipe left = delete

### HabitCard
- Icono + nombre del hábito
- Contador de racha
- Estado: checked today / not checked
- Tap = toggle check-in

### CourseCard
- Color strip lateral
- Nombre, horarios de clase
- Progreso visual (bar)
- Tap = expandir tareas

### HeatmapChart
- 52 semanas × 7 días grid
- Escala de verde: #EBEDF0, #9BE9A8, #40C463, #30A14E, #216E39
- Tooltip con fecha y detalle

### StreakCounter
- Número grande centrado
- Icono 🔥
- Texto: "días consecutivos"

### CalendarGrid
- Month view con días numerados
- Puntos de color debajo de fecha
- Día seleccionado: circle highlight

### ZenModeOverlay
- Fondo: #111827
- Hora: 72px, blanco
- Siguiente evento: 18px, gris
- Tarea activa: 24px, primary color

---

## 6. Technical Approach

### Stack
- **Frontend:** Flutter 3.x (Material 3)
- **Backend:** Firebase (Auth, Firestore, Functions)
- **API:** Google Calendar API v3
- **State:** flutter_bloc (BLoC pattern)
- **Local DB:** SharedPreferences (settings), Firestore offline

### Arquitectura
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
│       ├── firebase/
│       └── google_calendar/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── screens/
    ├── widgets/
    └── blocs/
```

### Firebase Setup
- Auth: Google + Email
- Firestore collections:
  - users/{uid}/tasks
  - users/{uid}/habits
  - users/{uid}/courses
  - users/{uid}/settings
- Offline: Firestore persistence enabled
- Security: uid-based access only

### Google Calendar Integration
- google_sign_in package
- googleapis package para Calendar API
- OAuth flow integrado con Firebase Auth
- Sync bidireccional via Firebase Functions (ideal) o client-side

### Offline Strategy
1. Firestore enablePersistence()
2. Network status listener
3. Cuando online: flush queue de cambios
4. Conflictos: server timestamp wins

---

## 7. Fases de Desarrollo (MVP Azul)

### Fase 1: Foundation
- Proyecto Flutter + Firebase setup
- Auth con Google
- Estructura de carpetas
- Theme base

### Fase 2: Calendario
- Google Calendar OAuth
- Listar eventos
- Vista mensual
- Sync básico

### Fase 3: Tareas
- CRUD tareas
- Asociación con días
- Checkbox completion

### Fase 4: Rachas
- Sistema de hábitos
- Check-in diario
- Gráfico de calor
- Contador de streak

### Fase 5: Cursos
- CRUD materias
- Asociación con calendario
- Progreso visual

### Fase 6: polish
- Modo Zen
- Offline completo
- Notificaciones
- UI polish

---

## 8. Success Metrics

- Login funcional con Google ✓
- Calendario sincronizado con Google ✓
- Tareas se crean y completan ✓
- Rachas se trackean y resetean correctamente ✓
- Cursos visibles con progreso ✓
- Modo offline funciona ✓
- Modo Zen accessible ✓
