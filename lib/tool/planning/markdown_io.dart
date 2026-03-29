import 'package:app/tool/planning/models.dart';

class MarkdownReader {
  static String extractSection(String content, String sectionName) {
    final lines = content.split('\n');
    bool inSection = false;
    final buffer = StringBuffer();

    for (final line in lines) {
      if (line.startsWith('## $sectionName')) {
        inSection = true;
        continue;
      }
      if (inSection) {
        if (line.startsWith('## ') || line.startsWith('# ')) {
          break;
        }
        buffer.writeln(line);
      }
    }

    return buffer.toString().trim();
  }

  static List<Map<String, String>> parseTable(String tableContent) {
    final lines = tableContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return [];

    final headerLine = lines.first;
    if (!headerLine.startsWith('|')) return [];

    final headers = headerLine
        .split('|')
        .map((h) => h.trim())
        .where((h) => h.isNotEmpty)
        .toList();

    final result = <Map<String, String>>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (!line.startsWith('|')) continue;
      if (line.startsWith('|---')) continue;

      final values = line
          .split('|')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList();

      final row = <String, String>{};
      for (int j = 0; j < headers.length && j < values.length; j++) {
        row[headers[j]] = values[j];
      }
      result.add(row);
    }

    return result;
  }

  static List<TaskEntry> parseTaskScores(String content) {
    final section = extractSection(content, 'Task Scores');
    final rows = parseTable(section);
    final tasks = <TaskEntry>[];

    for (final row in rows) {
      final factorStr = row['Validation Factor'] ?? '1.0';
      final factor = double.parse(factorStr);
      if (!allowedValidationFactors.contains(factor)) {
        throw FormatException('Invalid validation factor: $factor');
      }

      tasks.add(
        TaskEntry(
          taskId: row['Task ID'] ?? '',
          planId: row['Plan ID'] ?? '',
          phaseId: row['Phase ID'] ?? '',
          impact: int.parse(row['Impact'] ?? '0'),
          riskClosed: int.parse(row['Risk Closed'] ?? '0'),
          effort: int.parse(row['Effort'] ?? '0'),
          verifiability: int.parse(row['Verifiability'] ?? '0'),
          dependencyUnlock: int.parse(row['Dependency Unlock'] ?? '0'),
          validationFactor: factor,
          required: true,
        ),
      );
    }

    return tasks;
  }

  static List<PlanEntry> parsePlanRollups(
    String content,
    List<TaskEntry> tasks,
  ) {
    final section = extractSection(content, 'Plan Rollups');
    final rows = parseTable(section);
    final plans = <PlanEntry>[];

    for (final row in rows) {
      final planId = row['Plan ID'] ?? '';
      final phaseId = row['Phase ID'] ?? '';
      final planTasks = tasks.where((t) => t.planId == planId).toList();

      plans.add(PlanEntry(planId: planId, phaseId: phaseId, tasks: planTasks));
    }

    return plans;
  }

  static List<PhaseEntry> parsePhaseRollups(
    String content,
    List<PlanEntry> plans,
  ) {
    final section = extractSection(content, 'Phase Rollups');
    final rows = parseTable(section);
    final phases = <PhaseEntry>[];

    for (final row in rows) {
      final phaseId = row['Phase ID'] ?? '';
      final targetScore =
          int.tryParse(row['Target Score'] ?? row['Estimated'] ?? '0') ?? 0;
      final phasePlans = plans.where((p) => p.phaseId == phaseId).toList();

      phases.add(
        PhaseEntry(
          phaseId: phaseId,
          plans: phasePlans,
          targetScore: targetScore,
        ),
      );
    }

    return phases;
  }
}

class MarkdownWriter {
  static String writeTaskScoresTable(List<TaskEntry> tasks) {
    final buffer = StringBuffer();
    buffer.writeln('## Task Scores');
    buffer.writeln(
      '| Task ID | Plan ID | Phase ID | Impact | Risk Closed | Effort | Verifiability | Dependency Unlock | Estimated | Validation Factor | Validated | Severity | Evidence | Status |',
    );
    buffer.writeln(
      '|---------|---------|---------|--------|-------------|--------|---------------|------------------|-----------|-------------------|-----------|----------|----------|--------|',
    );

    for (final task in tasks) {
      final validated = task.validatedScore.toStringAsFixed(1);
      buffer.writeln(
        '| ${task.taskId} | ${task.planId} | ${task.phaseId} | ${task.impact} | ${task.riskClosed} | ${task.effort} | ${task.verifiability} | ${task.dependencyUnlock} | ${task.estimatedScore} | ${task.validationFactor} | $validated | note | | pending |',
      );
    }

    return buffer.toString();
  }

  static String writePlanRollupsTable(List<PlanEntry> plans) {
    final buffer = StringBuffer();
    buffer.writeln('## Plan Rollups');
    buffer.writeln(
      '| Plan ID | Phase ID | Estimated | Validated | Gate Status | Evidence |',
    );
    buffer.writeln(
      '|---------|---------|-----------|-----------|-------------|----------|',
    );

    for (final plan in plans) {
      final validated = plan.validatedTotal.toStringAsFixed(1);
      buffer.writeln(
        '| ${plan.planId} | ${plan.phaseId} | ${plan.estimatedTotal} | $validated | open | |',
      );
    }

    return buffer.toString();
  }

  static String writePhaseRollupsTable(List<PhaseEntry> phases) {
    final buffer = StringBuffer();
    buffer.writeln('## Phase Rollups');
    buffer.writeln(
      '| Phase ID | Estimated | Closure Score | Validated | Gate Status | Evidence |',
    );
    buffer.writeln(
      '|----------|-----------|---------------|-----------|-------------|----------|',
    );

    for (final phase in phases) {
      final closureScore = computeClosureScore(phase.targetScore);
      final validated = phase.validatedTotal.toStringAsFixed(1);
      buffer.writeln(
        '| ${phase.phaseId} | ${phase.estimatedTotal} | $closureScore | $validated | open | |',
      );
    }

    return buffer.toString();
  }
}
