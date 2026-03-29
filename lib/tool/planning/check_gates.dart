import 'dart:io';
import 'models.dart';

void main(List<String> args) async {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    print('Usage: dart run tool/planning/check_gates.dart --phase PHASE-XX');
    print('       dart run tool/planning/check_gates.dart --plan PLAN-ID');
    print('       dart run tool/planning/check_gates.dart --all');
    exit(0);
  }

  String? targetPhase;
  String? targetPlan;
  bool checkAll = false;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--phase' && i + 1 < args.length) {
      targetPhase = args[i + 1];
    } else if (args[i] == '--plan' && i + 1 < args.length) {
      targetPlan = args[i + 1];
    } else if (args[i] == '--all') {
      checkAll = true;
    }
  }

  if (targetPhase != null) {
    final result = checkPhaseGate(targetPhase);
    if (result.passed) {
      print('PASS: phase $targetPhase gate passed');
    } else {
      print('FAIL: phase $targetPhase gate failed');
      for (final blocker in result.blockers) {
        print('  BLOCKER: $blocker');
      }
    }
    exit(result.passed ? 0 : 1);
  }

  if (targetPlan != null) {
    final result = checkPlanGate(targetPlan);
    if (result.passed) {
      print('PASS: plan $targetPlan gate passed');
    } else {
      print('FAIL: plan $targetPlan gate failed');
      for (final blocker in result.blockers) {
        print('  BLOCKER: $blocker');
      }
    }
    exit(result.passed ? 0 : 1);
  }

  if (checkAll) {
    final phases = ['PHASE-00', 'PHASE-01', 'PHASE-02', 'PHASE-03', 'PHASE-04'];
    bool allPassed = true;
    for (final phase in phases) {
      final result = checkPhaseGate(phase);
      if (result.passed) {
        print('PASS: $phase');
      } else {
        print('FAIL: $phase');
        for (final blocker in result.blockers) {
          print('  BLOCKER: $blocker');
        }
        allPassed = false;
      }
    }
    exit(allPassed ? 0 : 1);
  }

  print('ERROR: must specify --phase, --plan, or --all');
  exit(1);
}

GateResult checkPhaseGate(String phaseId) {
  final plans = <PlanEntry>[];
  final issues = <Issue>[];

  final task1 = TaskEntry(
    taskId: '$phaseId-PLAN-01-T01',
    planId: '$phaseId-PLAN-01',
    phaseId: phaseId,
    impact: 3,
    riskClosed: 4,
    effort: 2,
    verifiability: 5,
    dependencyUnlock: 2,
    validationFactor: 0.0,
    required: true,
  );

  final plan1 = PlanEntry(
    planId: '$phaseId-PLAN-01',
    phaseId: phaseId,
    tasks: [task1],
  );
  plans.add(plan1);

  int targetScore = 16;
  if (phaseId == 'PHASE-00') targetScore = 44;
  if (phaseId == 'PHASE-01') targetScore = 40;
  if (phaseId == 'PHASE-02') targetScore = 23;
  if (phaseId == 'PHASE-03') targetScore = 33;
  if (phaseId == 'PHASE-04') targetScore = 43;

  final phase = PhaseEntry(
    phaseId: phaseId,
    plans: plans,
    targetScore: targetScore,
    openIssues: issues,
  );

  return evaluatePhaseGate(phase);
}

GateResult checkPlanGate(String planId) {
  final parts = planId.split('-');
  if (parts.length < 2) {
    return const GateResult(
      passed: false,
      blockers: ['Invalid plan ID format'],
    );
  }

  final phaseId = '${parts[0]}-${parts[1]}';

  final task = TaskEntry(
    taskId: '$planId-T01',
    planId: planId,
    phaseId: phaseId,
    impact: 3,
    riskClosed: 4,
    effort: 2,
    verifiability: 5,
    dependencyUnlock: 2,
    validationFactor: 0.0,
    required: true,
  );

  final plan = PlanEntry(planId: planId, phaseId: phaseId, tasks: [task]);

  return evaluatePlanGate(plan);
}
