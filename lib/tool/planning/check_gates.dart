import 'dart:io';

import 'package:app/tool/planning/models.dart';

void main(List<String> args) async {
  final options = _parseOptions(args);

  if (options.showHelp) {
    stdout.writeln('Usage: dart run tool/planning/check_gates.dart --phase PHASE-XX');
    stdout.writeln('       dart run tool/planning/check_gates.dart --plan PLAN-ID');
    stdout.writeln('       dart run tool/planning/check_gates.dart --all');
    exit(0);
  }

  if (options.targetPhase != null) {
    _emitGateResult(
      checkPhaseGate(options.targetPhase!),
      successMessage: 'PASS: phase ${options.targetPhase} gate passed',
      failureMessage: 'FAIL: phase ${options.targetPhase} gate failed',
    );
  }

  if (options.targetPlan != null) {
    _emitGateResult(
      checkPlanGate(options.targetPlan!),
      successMessage: 'PASS: plan ${options.targetPlan} gate passed',
      failureMessage: 'FAIL: plan ${options.targetPlan} gate failed',
    );
  }

  if (options.checkAll) {
    final phases = ['PHASE-00', 'PHASE-01', 'PHASE-02', 'PHASE-03', 'PHASE-04'];
    bool allPassed = true;
    for (final phase in phases) {
      final result = checkPhaseGate(phase);
      if (result.passed) {
        stdout.writeln('PASS: $phase');
      } else {
        stderr.writeln('FAIL: $phase');
        for (final blocker in result.blockers) {
          stderr.writeln('  BLOCKER: $blocker');
        }
        allPassed = false;
      }
    }
    exit(allPassed ? 0 : 1);
  }

  stderr.writeln('ERROR: must specify --phase, --plan, or --all');
  exit(1);
}

_CheckGatesOptions _parseOptions(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    return const _CheckGatesOptions(showHelp: true);
  }

  String? targetPhase;
  String? targetPlan;
  var checkAll = false;

  for (var index = 0; index < args.length; index += 1) {
    if (args[index] == '--phase' && index + 1 < args.length) {
      targetPhase = args[index + 1];
    } else if (args[index] == '--plan' && index + 1 < args.length) {
      targetPlan = args[index + 1];
    } else if (args[index] == '--all') {
      checkAll = true;
    }
  }

  return _CheckGatesOptions(
    targetPhase: targetPhase,
    targetPlan: targetPlan,
    checkAll: checkAll,
  );
}

Never _emitGateResult(
  GateResult result, {
  required String successMessage,
  required String failureMessage,
}) {
  if (result.passed) {
    stdout.writeln(successMessage);
  } else {
    stderr.writeln(failureMessage);
    for (final blocker in result.blockers) {
      stderr.writeln('  BLOCKER: $blocker');
    }
  }

  exit(result.passed ? 0 : 1);
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

class _CheckGatesOptions {
  const _CheckGatesOptions({
    this.targetPhase,
    this.targetPlan,
    this.checkAll = false,
    this.showHelp = false,
  });

  final String? targetPhase;
  final String? targetPlan;
  final bool checkAll;
  final bool showHelp;
}
