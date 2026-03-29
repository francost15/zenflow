import 'package:app/tool/planning/gate_checker.dart';
import 'package:app/tool/planning/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Score computation', () {
    test('estimated_score = sum of five dimensions', () {
      final task = _taskEntry(validationFactor: 1.0);
      expect(task.estimatedScore, 16);
    });

    test('validated_score = estimated * validation_factor', () {
      final task = _taskEntry(validationFactor: 1.0);
      expect(task.validatedScore, 16.0);
    });

    test('validated_score with 0.7 factor', () {
      final task = _taskEntry(validationFactor: 0.7);
      expect(task.validatedScore, 11.2);
    });
  });

  group('Rounding rules', () {
    test('task validated score may be fractional to one decimal place', () {
      expect(_taskEntry(validationFactor: 0.7).validatedScore, 11.2);
    });

    test('plan validated total rounds to one decimal place', () {
      final plan = PlanEntry(
        planId: 'PHASE-01-PLAN-02',
        phaseId: 'PHASE-01',
        tasks: [
          _taskEntry(validationFactor: 1.0),
          const TaskEntry(
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
        ],
      );
      expect(plan.validatedTotal, 26.0);
    });

    test('phase validated total rounds to one decimal place', () {
      final phase = PhaseEntry(
        phaseId: 'PHASE-01',
        plans: [
          PlanEntry(
            planId: 'PHASE-01-PLAN-01',
            phaseId: 'PHASE-01',
            tasks: [
              _taskEntry(validationFactor: 1.0, taskId: 'PHASE-01-PLAN-01-T01'),
            ],
          ),
          PlanEntry(
            planId: 'PHASE-01-PLAN-02',
            phaseId: 'PHASE-01',
            tasks: [_taskEntry(validationFactor: 0.7)],
          ),
        ],
        targetScore: 32,
      );
      expect(phase.validatedTotal, 27.2);
    });
  });

  group('closure_score computation', () {
    test('closure_score = ceil(target_score * 0.90)', () {
      expect(computeClosureScore(16), 15.0);
      expect(computeClosureScore(32), 29.0);
      expect(computeClosureScore(33), 30.0);
      expect(computeClosureScore(44), 40.0);
    });
  });

  group('Score bands - agent rules', () {
    test('Band 1 (0-8): max 1 agent', () {
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

TaskEntry _taskEntry({
  required double validationFactor,
  String taskId = 'PHASE-01-PLAN-02-T01',
}) {
  return TaskEntry(
    taskId: taskId,
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
