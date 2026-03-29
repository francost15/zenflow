import 'package:app/tool/planning/gate_checker.dart';
import 'package:app/tool/planning/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plan gate - required task at 0.0 blocks closure', () {
    test('blocks plan closure when required task has 0.0', () {
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [_task(validationFactor: 0.0)],
      );

      final result = evaluatePlanGate(plan);

      expect(result.passed, false);
      expect(
        result.blockers.any((blocker) => blocker.contains('0.0 validation factor')),
        true,
      );
    });

    test('allows closure when no required task at 0.0', () {
      final result = evaluatePlanGate(
        PlanEntry(
          planId: 'PHASE-01-PLAN-02',
          phaseId: 'PHASE-01',
          tasks: [_task(validationFactor: 1.0)],
        ),
      );

      expect(result.passed, true);
      expect(result.blockers, isEmpty);
    });
  });

  group('Plan gate - 85% threshold', () {
    test('blocks closure when validated < 85% of estimated', () {
      final result = evaluatePlanGate(
        PlanEntry(
          planId: 'PHASE-01-PLAN-02',
          phaseId: 'PHASE-01',
          tasks: [_task(validationFactor: 0.7)],
        ),
      );

      expect(result.passed, false);
      expect(
        result.blockers.any((blocker) => blocker.contains('less than 85%')),
        true,
      );
    });

    test('allows closure when validated >= 85% of estimated', () {
      final result = evaluatePlanGate(
        PlanEntry(
          planId: 'PHASE-01-PLAN-02',
          phaseId: 'PHASE-01',
          tasks: [_task(validationFactor: 1.0)],
        ),
      );

      expect(result.passed, true);
    });
  });

  group('Phase gate - critical/major issues block closure', () {
    test('blocks phase closure when critical issue present', () {
      final result = evaluatePhaseGate(
        PhaseEntry(
          phaseId: 'PHASE-01',
          plans: [_plan(validationFactor: 1.0)],
          targetScore: 16,
          openIssues: const [
            Issue(
              severity: Severity.critical,
              id: 'ISSUE-1',
              description: 'Broken tests',
            ),
          ],
        ),
      );

      expect(result.passed, false);
      expect(result.blockers.any((blocker) => blocker.contains('critical')), true);
    });

    test('blocks phase closure when major issue present', () {
      final result = evaluatePhaseGate(
        PhaseEntry(
          phaseId: 'PHASE-01',
          plans: [_plan(validationFactor: 1.0)],
          targetScore: 16,
          openIssues: const [
            Issue(
              severity: Severity.major,
              id: 'ISSUE-2',
              description: 'Missing verification',
            ),
          ],
        ),
      );

      expect(result.passed, false);
      expect(result.blockers.any((blocker) => blocker.contains('major')), true);
    });

    test('allows closure with minor issues only', () {
      final result = evaluatePhaseGate(
        PhaseEntry(
          phaseId: 'PHASE-01',
          plans: [_plan(validationFactor: 1.0)],
          targetScore: 16,
          openIssues: const [
            Issue(
              severity: Severity.minor,
              id: 'ISSUE-3',
              description: 'Documentation typo',
            ),
          ],
        ),
      );

      expect(result.passed, true);
    });
  });
}

TaskEntry _task({required double validationFactor}) {
  return TaskEntry(
    taskId: 'PHASE-01-PLAN-02-T01',
    planId: 'PHASE-01-PLAN-02',
    phaseId: 'PHASE-01',
    impact: 3,
    riskClosed: 4,
    effort: 2,
    verifiability: 5,
    dependencyUnlock: 2,
    validationFactor: validationFactor,
    required: true,
  );
}

PlanEntry _plan({required double validationFactor}) {
  return PlanEntry(
    planId: 'PHASE-01-PLAN-01',
    phaseId: 'PHASE-01',
    tasks: [_task(validationFactor: validationFactor)],
  );
}
