import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/widgets/sync_status_badge.dart';

void main() {
  group('SyncStatusBadge', () {
    testWidgets('shows CONECTADO with check icon when connected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SyncStatusBadge(status: SyncStatus.connected)),
        ),
      );

      expect(find.text('CONECTADO'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows RECONECTAR with sync icon when reconnect needed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SyncStatusBadge(status: SyncStatus.reconnect)),
        ),
      );

      expect(find.text('RECONECTAR'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    });

    testWidgets('shows SIN CONEXIÓN with cloud_off icon when offline', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SyncStatusBadge(status: SyncStatus.offline)),
        ),
      );

      expect(find.text('SIN CONEXIÓN'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('shows ERROR with error icon for error state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SyncStatusBadge(status: SyncStatus.error)),
        ),
      );

      expect(find.text('ERROR'), findsOneWidget);
      expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    });

    testWidgets('displays custom message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              status: SyncStatus.connected,
              customMessage: 'CUSTOM TEXT',
            ),
          ),
        ),
      );

      expect(find.text('CUSTOM TEXT'), findsOneWidget);
    });
  });
}
