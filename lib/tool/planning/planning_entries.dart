class TaskId {
  const TaskId({
    required this.phase,
    required this.plan,
    required this.task,
    required this.taskNumber,
  });

  static final _pattern = RegExp(r'^PHASE-(\d{2})-PLAN-(\d{2})-T(\d{2})$');

  final String phase;
  final String plan;
  final String task;
  final int taskNumber;

  static TaskId parse(String id) {
    final match = _pattern.firstMatch(id);
    if (match == null) {
      throw FormatException('Invalid task ID format: $id');
    }

    final phaseNumber = int.parse(match.group(1)!);
    final planNumber = int.parse(match.group(2)!);
    final taskNumber = int.parse(match.group(3)!);

    return TaskId(
      phase: _formatPhaseId(phaseNumber),
      plan: '${_formatPhaseId(phaseNumber)}-PLAN-${_twoDigits(planNumber)}',
      task:
          '${_formatPhaseId(phaseNumber)}-PLAN-${_twoDigits(planNumber)}-T${_twoDigits(taskNumber)}',
      taskNumber: taskNumber,
    );
  }
}

enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  validated('validated'),
  partial('partial'),
  blocked('blocked');

  const TaskStatus(this.value);

  final String value;

  static TaskStatus parse(String rawStatus) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == rawStatus,
      orElse: () => throw FormatException('Invalid task status: $rawStatus'),
    );
  }
}

enum Severity {
  critical('critical'),
  major('major'),
  minor('minor'),
  note('note');

  const Severity(this.value);

  final String value;

  static Severity parse(String rawSeverity) {
    return Severity.values.firstWhere(
      (severity) => severity.value == rawSeverity,
      orElse: () => throw FormatException('Invalid severity: $rawSeverity'),
    );
  }

  bool blocksClosure() => this == Severity.critical || this == Severity.major;
}

class Issue {
  const Issue({
    required this.severity,
    required this.id,
    required this.description,
  });

  final Severity severity;
  final String id;
  final String description;
}

class TaskEntry {
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

  int get estimatedScore =>
      impact + riskClosed + effort + verifiability + dependencyUnlock;

  double get validatedScore => estimatedScore * validationFactor;
}

class TaskScoreEntry {
  const TaskScoreEntry({
    required this.taskId,
    required this.status,
    required this.severity,
    required this.validatedScore,
    this.evidence,
  });

  final String taskId;
  final TaskStatus status;
  final Severity severity;
  final double validatedScore;
  final String? evidence;
}

class PlanEntry {
  const PlanEntry({
    required this.planId,
    required this.phaseId,
    required this.tasks,
  });

  final String planId;
  final String phaseId;
  final List<TaskEntry> tasks;

  int get estimatedTotal =>
      tasks.fold(0, (sum, task) => sum + task.estimatedScore);

  double get validatedTotal {
    final total = tasks.fold(0.0, (sum, task) => sum + task.validatedScore);
    return double.parse(total.toStringAsFixed(1));
  }
}

class PhaseEntry {
  const PhaseEntry({
    required this.phaseId,
    required this.plans,
    required this.targetScore,
    this.openIssues = const [],
    this.closedDependencies = const [],
    this.requiredVerificationFiles = const [],
  });

  final String phaseId;
  final List<PlanEntry> plans;
  final int targetScore;
  final List<Issue> openIssues;
  final List<String> closedDependencies;
  final List<String> requiredVerificationFiles;

  int get estimatedTotal =>
      plans.fold(0, (sum, plan) => sum + plan.estimatedTotal);

  double get validatedTotal {
    final total = plans.fold(0.0, (sum, plan) => sum + plan.validatedTotal);
    return double.parse(total.toStringAsFixed(1));
  }
}

class GateResult {
  const GateResult({
    required this.passed,
    this.blockers = const [],
    this.warnings = const [],
  });

  final bool passed;
  final List<String> blockers;
  final List<String> warnings;
}

final Set<double> allowedValidationFactors = {1.0, 0.7, 0.4, 0.0};

String _formatPhaseId(int phaseNumber) {
  return 'PHASE-${_twoDigits(phaseNumber)}';
}

String _twoDigits(int number) => number.toString().padLeft(2, '0');
