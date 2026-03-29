/// Centralized UI strings for the ZenFlow app.
/// Currently supports Spanish (es) as primary language.
class AppStrings {
  AppStrings._();

  // ─── App ───────────────────────────────────────────────────────────────────

  static const String appName = 'ZenFlow';
  static const String appTagline = 'Tu organizador estudiantil gamificado';

  // ─── Auth ─────────────────────────────────────────────────────────────────

  static const String loginWithGoogle = 'Iniciar con Google';
  static const String logout = 'Cerrar Sesión';
  static const String user = 'Usuario';

  // ─── Navigation ────────────────────────────────────────────────────────────

  static const String agenda = 'Agenda';
  static const String protocol = 'PROTOCOL';

  // ─── Tasks ─────────────────────────────────────────────────────────────────

  static const String newTask = 'Nueva Tarea';
  static const String taskTitleHint = '¿En qué vas a enfocarte?';
  static const String taskDescriptionHint = 'Notas adicionales (opcional)...';
  static const String focusParameters = 'PARÁMETROS DE ENFOQUE';
  static const String noTasksToday = 'No hay tareas para hoy';
  static const String tapToAddTask = 'Toca + para agregar una tarea';
  static const String addTask = 'Agregar Tarea';
  static const String close = 'Cerrar';
  static const String deleteTask = 'Eliminar tarea';
  static const String confirmDeleteTask = '¿Estás seguro?';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String retry = 'Reintentar';
  static const String enterTask = 'INGRESAR TAREA';
  static const String enterTaskTitle = 'Ingresa un título para la tarea';
  static const String withoutTime = 'Sin hora';
  static const String priorityHigh = 'HIGH';
  static const String priorityMedium = 'MEDIUM';
  static const String priorityLow = 'LOW';

  // ─── Streaks ───────────────────────────────────────────────────────────────

  static const String currentFocusStreak = 'CURRENT FOCUS STREAK';
  static const String days = 'DAYS';

  // ─── Calendar ───────────────────────────────────────────────────────────────

  static const String sync = 'Sync';
  static const String syncActive = 'SYNC ACTIVE';
  static const String connectGoogleCalendar = 'Conecta tu Google Calendar';
  static const String toSeeEvents = 'Para ver tus eventos';
  static const String noEventsFor = 'No hay eventos para';

  // ─── Courses ───────────────────────────────────────────────────────────────

  static const String newCourse = 'Nuevo Curso';
  static const String noCourses = 'No hay cursos';
  static const String addCourse = 'Agregar Curso';

  // ─── Errors ────────────────────────────────────────────────────────────────

  static const String genericError = 'Ocurrió un error. Intenta de nuevo';
  static const String networkError = 'Error de conexión. Verifica tu internet';
  static const String permissionError =
      'No tienes permiso para realizar esta acción';
  static const String taskAlreadyExists = 'Esta tarea ya existe';

  // ─── Days of week ──────────────────────────────────────────────────────────

  static const List<String> weekDaysLetters = [
    'L',
    'M',
    'X',
    'J',
    'V',
    'S',
    'D',
  ];

  // ─── Task priorities ───────────────────────────────────────────────────────

  static const String priority01 = 'Priority 01';
  static const String priority02 = 'Priority 02';
  static const String standard = 'Standard';

  // ─── Zen Mode ─────────────────────────────────────────────────────────────

  static const String zenMode = 'ZEN MODE';
  static const String focusMode = 'Focus Mode';
}
