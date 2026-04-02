part of 'app_redesign_test.dart';

void registerAppRedesignTests() {
  testWidgets(
    'StreaksScreen shows the heatmap and habit emoji without achievements clutter',
    (tester) async {
      final today = DateTime.now();
      final habitRepository = FakeHabitRepository(
        habits: [
          Habit(
            id: 'habit-1',
            name: 'Lectura profunda',
            icon: '📚',
            currentStreak: 5,
            longestStreak: 9,
            lastCheckIn: today,
            checkInHistory: [today.subtract(const Duration(days: 1)), today],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => StreaksBloc(habitRepository),
            child: const StreaksScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(HeatmapChart), findsOneWidget);
      expect(find.text('📚'), findsOneWidget);
      expect(find.text('HÁBITOS DE PROTOCOLO'), findsOneWidget);
      expect(find.text('LOGROS Y ESTADÍSTICAS'), findsNothing);
    },
  );

  testWidgets(
    'ProfileScreen shows achievements after moving them out of streaks',
    (tester) async {
      final authBloc = AuthBloc(
        FakeAuthRepository(
          user: const FakeUser(
            uidValue: 'user-1',
            displayNameValue: 'Franco',
            emailValue: 'franco@example.com',
          ),
        ),
        FakeCalendarRepository(),
        FakeTaskRepository(tasks: const []),
      )..add(AuthCheckRequested());

      final habitRepository = FakeHabitRepository(
        habits: [
          Habit(
            id: 'habit-1',
            name: 'Meditación',
            icon: '🧘',
            currentStreak: 14,
            longestStreak: 21,
            lastCheckIn: DateTime.now(),
            checkInHistory: List.generate(
              14,
              (index) => DateTime.now().subtract(Duration(days: index)),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider(create: (_) => StreaksBloc(habitRepository)),
            ],
            child: const ProfileScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Perfil y estadísticas'), findsOneWidget);
      expect(find.text('LOGROS Y ESTADÍSTICAS'), findsOneWidget);
      expect(find.text('ENCENDIDO'), findsOneWidget);
      expect(find.text('RACHA ACTUAL'), findsOneWidget);
    },
  );

  testWidgets(
    'CoursesScreen renders derived progress and upcoming class data',
    (tester) async {
      final now = DateTime.now();
      final nextWeekday = now.weekday == DateTime.sunday
          ? DateTime.monday
          : now.weekday + 1;
      final course = Course(
        id: 'course-1',
        name: 'Matemáticas',
        color: Colors.blue,
        professor: 'Dra. Soto',
        schedule: [
          Schedule(
            dayOfWeek: nextWeekday,
            startTime: const TimeOfDay(hour: 9, minute: 0),
            endTime: const TimeOfDay(hour: 10, minute: 30),
          ),
        ],
        notes: 'Repasar integrales',
        createdAt: now,
      );
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Resolver guía',
          dueDate: now.add(const Duration(days: 1)),
          status: TaskStatus.pending,
          courseId: course.id,
          createdAt: now,
          updatedAt: now,
        ),
        Task(
          id: 'task-2',
          title: 'Entregar quiz',
          dueDate: now.add(const Duration(days: 2)),
          status: TaskStatus.completed,
          courseId: course.id,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => CourseBloc(
              FakeCourseRepository(courses: [course]),
              FakeTaskRepository(tasks: tasks),
            ),
            child: const CoursesScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Hub de cursos'), findsOneWidget);
      expect(find.text('Matemáticas'), findsWidgets);
      expect(find.text('Dra. Soto'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.textContaining('Próxima clase'), findsWidgets);
    },
  );

  testWidgets('CourseDetailSheet exposes a visible delete action', (
    tester,
  ) async {
    final now = DateTime.now();
    final course = Course(
      id: 'course-1',
      name: 'Historia',
      color: Colors.deepOrange,
      professor: 'Mtro. Vega',
      createdAt: now,
    );
    final overview = CourseOverview(
      course: course,
      tasks: const [],
      pendingTasksCount: 0,
      completedTasksCount: 0,
      derivedProgress: 0,
      nextClass: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CourseDetailSheet(
            overview: overview,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Eliminar materia'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
  });

  testWidgets(
    'TaskEditorSheet preloads existing task data and exposes delete',
    (tester) async {
      final now = DateTime.now();
      final course = Course(
        id: 'course-1',
        name: 'Historia',
        color: Colors.orange,
        createdAt: now,
      );
      final task = Task(
        id: 'task-1',
        title: 'Revisar capítulo 3',
        description: 'Anotar conceptos clave',
        dueDate: now,
        priority: TaskPriority.high,
        courseId: course.id,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => TaskBloc(FakeTaskRepository(tasks: [task])),
              ),
              BlocProvider(
                create: (_) => CourseBloc(
                  FakeCourseRepository(courses: [course]),
                  FakeTaskRepository(tasks: [task]),
                ),
              ),
            ],
            child: Scaffold(body: TaskEditorSheet(initialTask: task)),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Editar tarea'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
      expect(find.text('GUARDAR CAMBIOS'), findsOneWidget);
      expect(find.text('Revisar capítulo 3'), findsOneWidget);
      expect(find.text('Anotar conceptos clave'), findsOneWidget);
    },
  );
}
