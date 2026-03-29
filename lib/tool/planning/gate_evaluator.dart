import 'dart:io' as io;

import 'package:app/tool/planning/planning_entries.dart';
import 'package:app/tool/planning/planning_scoring.dart';

GateResult evaluatePlanGate(PlanEntry plan) {
  final blockers = <String>[];

  for (final task in plan.tasks) {
    if (task.required && task.validationFactor == 0.0) {
      blockers.add('Required task ${task.taskId} has 0.0 validation factor');
    }
  }

  final validatedPercentage = plan.estimatedTotal > 0
      ? plan.validatedTotal / plan.estimatedTotal
      : 0.0;
  if (validatedPercentage < 0.85) {
    blockers.add(
      'Validated score ${plan.validatedTotal} is less than 85% of estimated ${plan.estimatedTotal}',
    );
  }

  return GateResult(passed: blockers.isEmpty, blockers: blockers);
}

GateResult evaluatePhaseGate(PhaseEntry phase) {
  final blockers = <String>[];

  for (final issue in phase.openIssues) {
    if (issue.severity.blocksClosure()) {
      blockers.add(
        'Unresolved ${issue.severity.value} issue on ${issue.id}: ${issue.description}',
      );
    }
  }

  final closureScore = computeClosureScore(phase.targetScore);
  if (phase.validatedTotal < closureScore) {
    blockers.add(
      'Validated score ${phase.validatedTotal} is below closure score $closureScore',
    );
  }

  return GateResult(passed: blockers.isEmpty, blockers: blockers);
}

GateResult evaluatePhaseGateWithVerification(
  PhaseEntry phase,
  List<String> Function(String) getClosedDependenciesForPhase,
) {
  final baseResult = evaluatePhaseGate(phase);
  final blockers = List<String>.from(baseResult.blockers);
  final warnings = List<String>.from(baseResult.warnings);

  final missingFiles = findMissingVerificationFiles(
    phase.requiredVerificationFiles,
  );
  if (missingFiles.isNotEmpty) {
    blockers.add(
      'Missing required verification artifacts: ${missingFiles.join(', ')}',
    );
  }

  final requiredDependencies = phase.closedDependencies.isEmpty
      ? getClosedDependenciesForPhase(phase.phaseId)
      : phase.closedDependencies;
  final openDependencies = findOpenDependencies(
    requiredDependencies,
    phase.closedDependencies,
  );
  if (openDependencies.isNotEmpty) {
    blockers.add(
      'Open dependency phases must be closed before advancement: ${openDependencies.join(', ')}',
    );
  }

  return GateResult(
    passed: blockers.isEmpty,
    blockers: blockers,
    warnings: warnings,
  );
}

List<String> findMissingVerificationFiles(List<String> requiredFiles) {
  return requiredFiles
      .where((filePath) => !io.File(filePath).existsSync())
      .toList();
}

List<String> findOpenDependencies(
  List<String> requiredDependencies,
  List<String> closedDependencies,
) {
  return requiredDependencies
      .where((dependency) => !closedDependencies.contains(dependency))
      .toList();
}

List<String> getDefaultClosedDependenciesForPhase(String phaseId) {
  final phaseNumber = int.tryParse(phaseId.split('-')[1]) ?? 0;
  return [
    for (var index = 0; index < phaseNumber; index += 1)
      'PHASE-${index.toString().padLeft(2, '0')}',
  ];
}

List<String> validateRootPlanningFiles(String basePath) {
  final errors = <String>[];
  _validateRoadmapFile(errors, basePath);
  _validateStateFile(errors, basePath);
  _validateScorecardFile(errors, basePath);
  _validatePolicyFile(errors, basePath);
  return errors;
}

void _validateRoadmapFile(List<String> errors, String basePath) {
  final roadmapFile = io.File('$basePath/ROADMAP.md');
  if (!roadmapFile.existsSync()) {
    errors.add('ROADMAP.md is missing');
    return;
  }

  final content = roadmapFile.readAsStringSync();
  if (!content.contains('## Phases') ||
      !content.contains('| Phase ID |') ||
      !content.contains('Target Score') ||
      !content.contains('Closure Score')) {
    errors.add('ROADMAP.md missing required phases table columns');
  }
}

void _validateStateFile(List<String> errors, String basePath) {
  final stateFile = io.File('$basePath/STATE.md');
  if (!stateFile.existsSync()) {
    errors.add('STATE.md is missing');
    return;
  }

  final content = stateFile.readAsStringSync();
  if (!content.contains('## Current Phase') ||
      !content.contains('## Score Snapshot')) {
    errors.add('STATE.md missing required sections');
  }
}

void _validateScorecardFile(List<String> errors, String basePath) {
  final scorecardFile = io.File('$basePath/SCORECARD.md');
  if (!scorecardFile.existsSync()) {
    errors.add('SCORECARD.md is missing');
    return;
  }

  final content = scorecardFile.readAsStringSync();
  if (!content.contains('## Task Scores') ||
      !content.contains('| Task ID |') ||
      !content.contains('| Plan ID |') ||
      !content.contains('Estimated |')) {
    errors.add('SCORECARD.md missing required table columns');
  }
}

void _validatePolicyFile(List<String> errors, String basePath) {
  final policyFile = io.File('$basePath/AGENT_POLICY.md');
  if (!policyFile.existsSync()) {
    errors.add('AGENT_POLICY.md is missing');
    return;
  }

  final content = policyFile.readAsStringSync();
  if (!content.contains('## Score Bands') ||
      !content.contains('## Skill Rules')) {
    errors.add('AGENT_POLICY.md missing required sections');
  }
}
