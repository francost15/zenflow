import 'package:app/core/utils/connectivity_service.dart';
import 'package:app/presentation/blocs/auth/auth_state.dart';
import 'package:app/presentation/blocs/calendar/calendar_state.dart';
import 'package:app/presentation/widgets/sync_status_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ConnectivityService.instance.setOnline(true);
  });

  testWidgets('calendar linked + online shows connected badge', (tester) async {
    final user = FakeUser();
    final now = DateTime.now();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SyncStatusBadge(
            authState: AuthAuthenticated(user, calendarLinked: true),
            calendarState: CalendarLoaded(events: [], start: now, end: now),
          ),
        ),
      ),
    );

    expect(find.text('CONECTADO'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets(
    'auth signed in but calendar not linked shows reconnect-needed badge',
    (tester) async {
      final user = FakeUser();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              authState: AuthAuthenticated(user, calendarLinked: false),
              calendarState: CalendarNeedsSignIn(),
            ),
          ),
        ),
      );

      expect(find.text('RECONECTAR'), findsOneWidget);
      expect(find.byIcon(Icons.sync_problem_rounded), findsOneWidget);
    },
  );

  testWidgets('offline shows offline indicator with degraded sync state', (
    tester,
  ) async {
    ConnectivityService.instance.setOnline(false);
    final user = FakeUser();
    final now = DateTime.now();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SyncStatusBadge(
            authState: AuthAuthenticated(user, calendarLinked: true),
            calendarState: CalendarLoaded(events: [], start: now, end: now),
          ),
        ),
      ),
    );

    expect(find.text('SIN CONEXIÓN'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });

  testWidgets('auth error shows explicit warning state, NOT SYNC ACTIVE', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SyncStatusBadge(
            authState: AuthError('Auth failed'),
            calendarState: CalendarNeedsSignIn(),
          ),
        ),
      ),
    );

    expect(find.text('ERROR'), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    expect(find.text('ACTIVO'), findsNothing);
  });

  testWidgets('calendar error shows explicit warning state, NOT SYNC ACTIVE', (
    tester,
  ) async {
    final user = FakeUser();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SyncStatusBadge(
            authState: AuthAuthenticated(user, calendarLinked: true),
            calendarState: CalendarError('Calendar failed'),
          ),
        ),
      ),
    );

    expect(find.text('ERROR'), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    expect(find.text('ACTIVO'), findsNothing);
  });
}

class FakeUser implements User {
  @override
  String get uid => 'user-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
