import 'dart:io';
import 'models.dart';
import 'markdown_io.dart';

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
    final result = await checkPhaseGate(targetPhase);
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
    final result = await checkPlanGate(targetPlan);
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
      final result = await checkPhaseGate(phase);
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

Future<GateResult> checkPhaseGate(String phaseId) async {
  final scorecardFile = File('.planning/SCORECARD.md');
  if (!scorecardFile.existsSync()) {
    return GateResult(
      passed: false,
      blockers: ['SCORECARD.md not found at .planning/SCORECARD.md'],
    );
  }

  final content = scorecardFile.readAsStringSync();
  final tasks = MarkdownReader.parseTaskScores(content);
  final plans = MarkdownReader.parsePlanRollups(content, tasks);
  final phases = MarkdownReader.parsePhaseRollups(content, plans);

  final phase = phases.where((p) => p.phaseId == phaseId).firstOrNull;
  if (phase == null) {
    return GateResult(
      passed: false,
      blockers: ['Phase $phaseId not found in SCORECARD.md'],
    );
  }

  return evaluatePhaseGate(phase);
}

Future<GateResult> checkPlanGate(String planId) async {
  final parts = planId.split('-');
  if (parts.length < 2) {
    return const GateResult(
      passed: false,
      blockers: ['Invalid plan ID format'],
    );
  }

  final phaseId = '${parts[0]}-${parts[1]}';
  final planFile = File('.planning/phases/$phaseId/$planId.md');

  if (!planFile.existsSync()) {
    return GateResult(
      passed: false,
      blockers: ['Plan file not found at .planning/phases/$phaseId/$planId.md'],
    );
  }

  final content = planFile.readAsStringSync();
  final tasks = MarkdownReader.parseTaskScores(content);
  final planTasks = tasks.where((t) => t.planId == planId).toList();

  if (planTasks.isEmpty) {
    return GateResult(
      passed: false,
      blockers: ['No tasks found for plan $planId'],
    );
  }

  final plan = PlanEntry(planId: planId, phaseId: phaseId, tasks: planTasks);
  return evaluatePlanGate(plan);
}
