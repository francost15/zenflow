import 'dart:io' as io;

class TaskId {
  final String phase;
  final String plan;
  final String task;
  final int taskNumber;

  const TaskId({
    required this.phase,
    required this.plan,
    required this.task,
    required this.taskNumber,
  });

  static final _pattern = RegExp(r'^PHASE-(\d{2})-PLAN-(\d{2})-T(\d{2})$');

  static TaskId parse(String id) {
    final match = _pattern.firstMatch(id);
    if (match == null) {
      throw FormatException('Invalid task ID format: $id');
    }
    final phaseNum = int.parse(match.group(1)!);
    final planNum = int.parse(match.group(2)!);
    final taskNum = int.parse(match.group(3)!);
    if (phaseNum < 0 || planNum < 0 || taskNum < 0) {
      throw FormatException('Invalid task ID format: $id');
    }
    return TaskId(
      phase: 'PHASE-${phaseNum.toString().padLeft(2, '0')}',
      plan:
          'PHASE-${phaseNum.toString().padLeft(2, '0')}-PLAN-${planNum.toString().padLeft(2, '0')}',
      task:
          'PHASE-${phaseNum.toString().padLeft(2, '0')}-PLAN-${planNum.toString().padLeft(2, '0')}-T${taskNum.toString().padLeft(2, '0')}',
      taskNumber: taskNum,
    );
  }
}

enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  validated('validated'),
  partial('partial'),
  blocked('blocked');

  final String value;
  const TaskStatus(this.value);

  static TaskStatus parse(String s) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == s,
      orElse: () => throw FormatException('Invalid task status: $s'),
    );
  }
}

enum Severity {
  critical('critical'),
  major('major'),
  minor('minor'),
  note('note');

  final String value;
  const Severity(this.value);

  static Severity parse(String s) {
    return Severity.values.firstWhere(
      (e) => e.value == s,
      orElse: () => throw FormatException('Invalid severity: $s'),
    );
  }

  bool blocksClosure() => this == Severity.critical || this == Severity.major;
}

class Issue {
  final Severity severity;
  final String id;
  final String description;

  const Issue({
    required this.severity,
    required this.id,
    required this.description,
  });
}

class TaskEntry {
  final String taskId;
  final String planId;
  final String phaseId;
  final int impact;
  final int riskClosed;
  final int effort;
  final int verifiability;
  final int dependencyUnlock;
  final double validationFactor;
  final bool required;

  const TaskEntry({
    required this.taskId,
    required this.planId,
    required this.phaseId,
    required this.impact,
    required this.riskClosed,
    required this.effort,
    required this.verifiability,
    required this.dependencyUnlock,
    this.validationFactor = 1.0,
    this.required = true,
  });

  factory TaskEntry.withValidation({
    required String taskId,
    required String planId,
    required String phaseId,
    required int impact,
    required int riskClosed,
    required int effort,
    required int verifiability,
    required int dependencyUnlock,
    double validationFactor = 1.0,
    bool required = true,
  }) {
    if (!allowedValidationFactors.contains(validationFactor)) {
      throw FormatException(
        'validationFactor must be one of $allowedValidationFactors, got $validationFactor',
      );
    }
    return TaskEntry(
      taskId: taskId,
      planId: planId,
      phaseId: phaseId,
      impact: impact,
      riskClosed: riskClosed,
      effort: effort,
      verifiability: verifiability,
      dependencyUnlock: dependencyUnlock,
      validationFactor: validationFactor,
      required: required,
    );
  }

  int get estimatedScore =>
      impact + riskClosed + effort + verifiability + dependencyUnlock;

  double get validatedScore => estimatedScore * validationFactor;
}

class TaskScoreEntry {
  final String taskId;
  final TaskStatus status;
  final Severity severity;
  final double validatedScore;
  final String? evidence;

  const TaskScoreEntry({
    required this.taskId,
    required this.status,
    required this.severity,
    required this.validatedScore,
    this.evidence,
  });
}

class PlanEntry {
  final String planId;
  final String phaseId;
  final List<TaskEntry> tasks;

  const PlanEntry({
    required this.planId,
    required this.phaseId,
    required this.tasks,
  });

  int get estimatedTotal => tasks.fold(0, (sum, t) => sum + t.estimatedScore);

  double get validatedTotal {
    final total = tasks.fold(0.0, (sum, t) => sum + t.validatedScore);
    return double.parse(total.toStringAsFixed(1));
  }
}

class PhaseEntry {
  final String phaseId;
  final List<PlanEntry> plans;
  final int targetScore;
  final List<Issue> openIssues;
  final List<String> closedDependencies;
  final List<String> requiredVerificationFiles;

  const PhaseEntry({
    required this.phaseId,
    required this.plans,
    required this.targetScore,
    this.openIssues = const [],
    this.closedDependencies = const [],
    this.requiredVerificationFiles = const [],
  });

  int get estimatedTotal => plans.fold(0, (sum, p) => sum + p.estimatedTotal);

  double get validatedTotal {
    final total = plans.fold(0.0, (sum, p) => sum + p.validatedTotal);
    return double.parse(total.toStringAsFixed(1));
  }
}

class GateResult {
  final bool passed;
  final List<String> blockers;
  final List<String> warnings;

  const GateResult({
    required this.passed,
    this.blockers = const [],
    this.warnings = const [],
  });
}

final Set<double> allowedValidationFactors = {1.0, 0.7, 0.4, 0.0};

double computeClosureScore(int targetScore) {
  return (targetScore * 0.90).ceilToDouble();
}

int getMaxAgents(int estimatedScore) {
  if (estimatedScore <= 8) return 1;
  if (estimatedScore <= 15) return 2;
  if (estimatedScore <= 20) return 2;
  return 1;
}

GateResult evaluatePlanGate(PlanEntry plan) {
  final blockers = <String>[];
  final warnings = <String>[];

  for (final task in plan.tasks) {
    if (task.required && task.validationFactor == 0.0) {
      blockers.add('Required task ${task.taskId} has 0.0 validation factor');
    }
  }

  final validatedPct = plan.estimatedTotal > 0
      ? plan.validatedTotal / plan.estimatedTotal
      : 0.0;

  if (validatedPct < 0.85) {
    blockers.add(
      'Validated score ${plan.validatedTotal} is less than 85% of estimated ${plan.estimatedTotal}',
    );
  }

  return GateResult(
    passed: blockers.isEmpty,
    blockers: blockers,
    warnings: warnings,
  );
}

GateResult evaluatePhaseGate(PhaseEntry phase) {
  final blockers = <String>[];
  final warnings = <String>[];

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

  return GateResult(
    passed: blockers.isEmpty,
    blockers: blockers,
    warnings: warnings,
  );
}

List<String> findMissingVerificationFiles(List<String> requiredFiles) {
  return requiredFiles.where((file) {
    final f = io.File(file);
    return !f.existsSync();
  }).toList();
}

List<String> findOpenDependencies(
  List<String> requiredDependencies,
  List<String> closedDependencies,
) {
  return requiredDependencies
      .where((dep) => !closedDependencies.contains(dep))
      .toList();
}

GateResult evaluatePhaseGateWithVerification(
  PhaseEntry phase,
  List<String> Function(String) getClosedDependenciesForPhase,
) {
  final result = evaluatePhaseGate(phase);

  final missingFiles = findMissingVerificationFiles(
    phase.requiredVerificationFiles,
  );
  if (missingFiles.isNotEmpty) {
    result.blockers.add(
      'Missing required verification artifacts: ${missingFiles.join(', ')}',
    );
  }

  final requiredDeps = phase.closedDependencies.isEmpty
      ? getClosedDependenciesForPhase(phase.phaseId)
      : phase.closedDependencies;
  final openDeps = findOpenDependencies(requiredDeps, phase.closedDependencies);
  if (openDeps.isNotEmpty) {
    result.blockers.add(
      'Open dependency phases must be closed before advancement: ${openDeps.join(', ')}',
    );
  }

  return GateResult(
    passed: result.passed && missingFiles.isEmpty && openDeps.isEmpty,
    blockers: result.blockers,
    warnings: result.warnings,
  );
}

const _phaseDependencies = {
  'PHASE-00': <String>[],
  'PHASE-01': ['PHASE-00'],
  'PHASE-02': ['PHASE-00', 'PHASE-01'],
  'PHASE-03': ['PHASE-00', 'PHASE-01', 'PHASE-02'],
  'PHASE-04': ['PHASE-00', 'PHASE-01', 'PHASE-02', 'PHASE-03'],
};

List<String> getDefaultClosedDependenciesForPhase(String phaseId) {
  final phaseNum = int.tryParse(phaseId.split('-')[1]) ?? 0;
  final closedDeps = <String>[];
  for (int i = 0; i < phaseNum; i++) {
    closedDeps.add('PHASE-${i.toString().padLeft(2, '0')}');
  }
  return closedDeps;
}
