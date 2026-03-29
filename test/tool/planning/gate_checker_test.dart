import 'package:flutter_test/flutter_test.dart';
import 'package:gate_checker/planning/models.dart';
import 'package:gate_checker/planning/gate_checker.dart';

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

  group('Score computation', () {
    test('estimated_score = sum of five dimensions', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        required: true,
      );
      expect(task.estimatedScore, 16);
    });

    test('validated_score = estimated * validation_factor', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 1.0,
        required: true,
      );
      expect(task.validatedScore, 16.0);
    });

    test('validated_score with 0.7 factor', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 0.7,
        required: true,
      );
      expect(task.validatedScore, 11.2);
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
        expect(task.validatedScore, isFinite);
      }
    });

    test('rejects invalid validation factors', () {
      expect(
        () => TaskEntry(
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
        () => TaskEntry(
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

  group('Rounding rules', () {
    test('task validated score may be fractional to one decimal place', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 0.7,
        required: true,
      );
      expect(task.validatedScore, 11.2);
    });

    test('plan validated total rounds to one decimal place', () {
      final entries = [
        TaskEntry(
          taskId: 'PHASE-01-PLAN-02-T01',
          planId: 'PHASE-01-PLAN-02',
          phaseId: 'PHASE-01',
          impact: 3,
          riskClosed: 4,
          effort: 2,
          verifiability: 5,
          dependencyUnlock: 2,
          validationFactor: 0.7,
          required: true,
        ),
        TaskEntry(
          taskId: 'PHASE-01-PLAN-02-T02',
          planId: 'PHASE-01-PLAN-02',
          phaseId: 'PHASE-01',
          impact: 2,
          riskClosed: 3,
          effort: 1,
          verifiability: 3,
          dependencyUnlock: 1,
          validationFactor: 1.0,
          required: true,
        ),
      ];
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: entries,
      );
      expect(plan.validatedTotal, 15.2);
    });

    test('phase validated total rounds to one decimal place', () {
      final task1 = TaskEntry(
        taskId: 'PHASE-01-PLAN-01-T01',
        planId: 'PHASE-01-PLAN-01',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 1.0,
        required: true,
      );
      final task2 = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 0.7,
        required: true,
      );
      final phase = PhaseEntry(
        phaseId: 'PHASE-01',
        plans: [
          PlanEntry(
            planId: 'PHASE-01-PLAN-01',
            phaseId: 'PHASE-01',
            tasks: [task1],
          ),
          PlanEntry(
            planId: 'PHASE-01-PLAN-02',
            phaseId: 'PHASE-01',
            tasks: [task2],
          ),
        ],
        targetScore: 32,
      );
      expect(phase.validatedTotal, 25.2);
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
      for (final sev in ['critical', 'major', 'minor', 'note']) {
        final entry = TaskScoreEntry(
          taskId: 'PHASE-01-PLAN-02-T01',
          status: TaskStatus.validated,
          severity: Severity.parse(sev),
          validatedScore: 10.0,
        );
        expect(entry.severity.value, sev);
      }
    });

    test('rejects invalid severity', () {
      expect(() => Severity.parse('error'), throwsA(anything));
      expect(() => Severity.parse('warning'), throwsA(anything));
      expect(() => Severity.parse('BLOCKING'), throwsA(anything));
    });
  });

  group('Plan gate - required task at 0.0 blocks closure', () {
    test('blocks plan closure when required task has 0.0', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 0.0,
        required: true,
      );
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [task],
      );
      final result = evaluatePlanGate(plan);
      expect(result.passed, false);
      expect(result.blockers.any((b) => b.contains('0.0')), true);
    });

    test('allows closure when no required task at 0.0', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 0.7,
        required: true,
      );
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [task],
      );
      final result = evaluatePlanGate(plan);
      expect(result.passed, true);
    });
  });

  group('Plan gate - 85% threshold', () {
    test('blocks closure when validated < 85% of estimated', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 0.4,
        required: true,
      );
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [task],
      );
      final result = evaluatePlanGate(plan);
      expect(result.passed, false);
    });

    test('allows closure when validated >= 85% of estimated', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 1.0,
        required: true,
      );
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [task],
      );
      final result = evaluatePlanGate(plan);
      expect(result.passed, true);
    });
  });

  group('Phase gate - critical/major issues block closure', () {
    test('blocks phase closure when critical issue present', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 1.0,
        required: true,
      );
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [task],
      );
      final phase = PhaseEntry(
        phaseId: 'PHASE-01',
        plans: [plan],
        targetScore: 16,
        openIssues: [
          Issue(
            severity: Severity.critical,
            id: 'PHASE-01-PLAN-02-T01',
            description: 'Test issue',
          ),
        ],
      );
      final result = evaluatePhaseGate(phase);
      expect(result.passed, false);
    });

    test('blocks phase closure when major issue present', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 1.0,
        required: true,
      );
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [task],
      );
      final phase = PhaseEntry(
        phaseId: 'PHASE-01',
        plans: [plan],
        targetScore: 16,
        openIssues: [
          Issue(
            severity: Severity.major,
            id: 'PHASE-01-PLAN-02-T01',
            description: 'Test issue',
          ),
        ],
      );
      final result = evaluatePhaseGate(phase);
      expect(result.passed, false);
    });

    test('allows closure with minor issues only', () {
      final task = TaskEntry(
        taskId: 'PHASE-01-PLAN-02-T01',
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        impact: 3,
        riskClosed: 4,
        effort: 2,
        verifiability: 5,
        dependencyUnlock: 2,
        validationFactor: 1.0,
        required: true,
      );
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [task],
      );
      final phase = PhaseEntry(
        phaseId: 'PHASE-01',
        plans: [plan],
        targetScore: 16,
        openIssues: [
          Issue(
            severity: Severity.minor,
            id: 'PHASE-01-PLAN-02-T01',
            description: 'Minor issue',
          ),
        ],
      );
      final result = evaluatePhaseGate(phase);
      expect(result.passed, true);
    });
  });

  group('closure_score computation', () {
    test('closure_score = ceil(target_score * 0.90)', () {
      expect(computeClosureScore(100), 90);
      expect(computeClosureScore(44), 40);
      expect(computeClosureScore(45), 41);
      expect(computeClosureScore(23), 21);
      expect(computeClosureScore(33), 30);
      expect(computeClosureScore(43), 39);
    });
  });

  group('Score bands - agent rules', () {
    test('Band 1 (0-8): max 1 agent', () {
      expect(getMaxAgents(5), 1);
      expect(getMaxAgents(8), 1);
    });

    test('Band 2 (9-15): max 2 agents', () {
      expect(getMaxAgents(9), 2);
      expect(getMaxAgents(15), 2);
    });

    test('Band 3 (16-20): max 2 agents', () {
      expect(getMaxAgents(16), 2);
      expect(getMaxAgents(20), 2);
    });

    test('Band 4 (21-25): max 1 agent', () {
      expect(getMaxAgents(21), 1);
      expect(getMaxAgents(25), 1);
    });
  });
}
