import 'package:app/tool/planning/gate_checker.dart';
import 'package:app/tool/planning/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskId parsing', () {
    test('parses full task ID PHASE-01-PLAN-02-T01', () {
      final id = TaskId.parse('PHASE-01-PLAN-02-T01');
      expect(id.phase, 'PHASE-01');
      expect(id.plan, 'PHASE-01-PLAN-02');
      expect(id.task, 'PHASE-01-PLAN-02-T01');
      expect(id.taskNumber, 1);
    });

    test('parses PHASE-00-PLAN-01-T23', () {
      final id = TaskId.parse('PHASE-00-PLAN-01-T23');
      expect(id.phase, 'PHASE-00');
      expect(id.plan, 'PHASE-00-PLAN-01');
      expect(id.task, 'PHASE-00-PLAN-01-T23');
      expect(id.taskNumber, 23);
    });

    test('rejects invalid task ID format', () {
      expect(() => TaskId.parse('INVALID'), throwsA(anything));
      expect(() => TaskId.parse('PHASE-1-PLAN-2-T3'), throwsA(anything));
      expect(() => TaskId.parse('PHASE-01-PLAN-02'), throwsA(anything));
    });
  });

  group('Validation factor rules', () {
    test('allows only 1.0, 0.7, 0.4, 0.0', () {
      for (final factor in [1.0, 0.7, 0.4, 0.0]) {
        final task = TaskEntry(
          taskId: 'PHASE-01-PLAN-02-T01',
          planId: 'PHASE-01-PLAN-02',
          phaseId: 'PHASE-01',
          impact: 3,
          riskClosed: 4,
          effort: 2,
          verifiability: 5,
          dependencyUnlock: 2,
          validationFactor: factor,
          required: true,
        );
        expect(task.validatedScore.isFinite, isTrue);
      }
    });

    test('rejects invalid validation factors', () {
      expect(
        () => TaskEntry.withValidation(
          taskId: 'PHASE-01-PLAN-02-T01',
          planId: 'PHASE-01-PLAN-02',
          phaseId: 'PHASE-01',
          impact: 3,
          riskClosed: 4,
          effort: 2,
          verifiability: 5,
          dependencyUnlock: 2,
          validationFactor: 0.5,
          required: true,
        ),
        throwsA(anything),
      );
      expect(
        () => TaskEntry.withValidation(
          taskId: 'PHASE-01-PLAN-02-T01',
          planId: 'PHASE-01-PLAN-02',
          phaseId: 'PHASE-01',
          impact: 3,
          riskClosed: 4,
          effort: 2,
          verifiability: 5,
          dependencyUnlock: 2,
          validationFactor: 0.85,
          required: true,
        ),
        throwsA(anything),
      );
    });
  });

  group('Status validation', () {
    test('accepts valid statuses', () {
      for (final status in [
        'pending',
        'in_progress',
        'validated',
        'partial',
        'blocked',
      ]) {
        final entry = TaskScoreEntry(
          taskId: 'PHASE-01-PLAN-02-T01',
          status: TaskStatus.parse(status),
          severity: Severity.note,
          validatedScore: 10.0,
        );
        expect(entry.status.value, status);
      }
    });

    test('rejects invalid status', () {
      expect(() => TaskStatus.parse('completed'), throwsA(anything));
      expect(() => TaskStatus.parse('done'), throwsA(anything));
      expect(() => TaskStatus.parse('PASSED'), throwsA(anything));
    });
  });

  group('Severity validation', () {
    test('accepts valid severities', () {
      for (final severity in ['critical', 'major', 'minor', 'note']) {
        final entry = TaskScoreEntry(
          taskId: 'PHASE-01-PLAN-02-T01',
          status: TaskStatus.pending,
          severity: Severity.parse(severity),
          validatedScore: 10.0,
        );
        expect(entry.severity.value, severity);
      }
    });

    test('rejects invalid severity', () {
      expect(() => Severity.parse('blocking'), throwsA(anything));
    });
  });
}
