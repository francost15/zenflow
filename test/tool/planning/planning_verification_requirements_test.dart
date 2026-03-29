import 'dart:io' as io;

import 'package:app/tool/planning/gate_checker.dart';
import 'package:app/tool/planning/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Missing root planning files are rejected', () {
    test('ROADMAP.md missing required columns is rejected', () async {
      final tmpDir = io.Directory.systemTemp.createTempSync('planning_root_');
      io.File('${tmpDir.path}/ROADMAP.md').writeAsStringSync('# Invalid');
      io.File('${tmpDir.path}/STATE.md').writeAsStringSync(
        '## Current Phase\n## Score Snapshot',
      );
      io.File('${tmpDir.path}/SCORECARD.md').writeAsStringSync(
        '## Task Scores\n| Task ID | Plan ID | Estimated |',
      );
      io.File('${tmpDir.path}/AGENT_POLICY.md').writeAsStringSync(
        '## Score Bands\n## Skill Rules',
      );

      final errors = validateRootPlanningFiles(tmpDir.path);
      expect(errors.any((error) => error.contains('ROADMAP.md')), true);

      tmpDir.deleteSync(recursive: true);
    });

    test('STATE.md missing required sections is rejected', () async {
      final tmpDir = io.Directory.systemTemp.createTempSync('planning_root_');
      io.File('${tmpDir.path}/ROADMAP.md').writeAsStringSync(
        '## Phases\n| Phase ID | Target Score | Closure Score |',
      );
      io.File('${tmpDir.path}/STATE.md').writeAsStringSync('# Invalid');
      io.File('${tmpDir.path}/SCORECARD.md').writeAsStringSync(
        '## Task Scores\n| Task ID | Plan ID | Estimated |',
      );
      io.File('${tmpDir.path}/AGENT_POLICY.md').writeAsStringSync(
        '## Score Bands\n## Skill Rules',
      );

      final errors = validateRootPlanningFiles(tmpDir.path);
      expect(errors.any((error) => error.contains('STATE.md')), true);

      tmpDir.deleteSync(recursive: true);
    });

    test('SCORECARD.md missing required columns is rejected', () async {
      final tmpDir = io.Directory.systemTemp.createTempSync('planning_root_');
      io.File('${tmpDir.path}/ROADMAP.md').writeAsStringSync(
        '## Phases\n| Phase ID | Target Score | Closure Score |',
      );
      io.File('${tmpDir.path}/STATE.md').writeAsStringSync(
        '## Current Phase\n## Score Snapshot',
      );
      io.File('${tmpDir.path}/SCORECARD.md').writeAsStringSync('# Invalid');
      io.File('${tmpDir.path}/AGENT_POLICY.md').writeAsStringSync(
        '## Score Bands\n## Skill Rules',
      );

      final errors = validateRootPlanningFiles(tmpDir.path);
      expect(errors.any((error) => error.contains('SCORECARD.md')), true);

      tmpDir.deleteSync(recursive: true);
    });

    test('AGENT_POLICY.md missing required sections is rejected', () async {
      final tmpDir = io.Directory.systemTemp.createTempSync('planning_root_');
      io.File('${tmpDir.path}/ROADMAP.md').writeAsStringSync(
        '## Phases\n| Phase ID | Target Score | Closure Score |',
      );
      io.File('${tmpDir.path}/STATE.md').writeAsStringSync(
        '## Current Phase\n## Score Snapshot',
      );
      io.File('${tmpDir.path}/SCORECARD.md').writeAsStringSync(
        '## Task Scores\n| Task ID | Plan ID | Estimated |',
      );
      io.File('${tmpDir.path}/AGENT_POLICY.md').writeAsStringSync('# Invalid');

      final errors = validateRootPlanningFiles(tmpDir.path);
      expect(errors.any((error) => error.contains('AGENT_POLICY.md')), true);

      tmpDir.deleteSync(recursive: true);
    });
  });

  group('Verification and dependency requirements', () {
    test('blocks phase closure when required verification file missing', () {
      final result = evaluatePhaseGateWithVerification(
        PhaseEntry(
          phaseId: 'PHASE-01',
          plans: [_plan()],
          targetScore: 16,
          requiredVerificationFiles: const ['PHASE-01-VERIFICATION.md'],
          closedDependencies: const ['PHASE-00'],
        ),
        getDefaultClosedDependenciesForPhase,
      );

      expect(result.passed, false);
      expect(
        result.blockers.any((blocker) => blocker.contains('verification artifact')),
        true,
      );
    });

    test('allows phase closure when verification file exists', () async {
      final tmpDir = io.Directory.systemTemp.createTempSync('gate_test_');
      final verificationFile =
          io.File('${tmpDir.path}/PHASE-01-VERIFICATION.md')
            ..writeAsStringSync('# Verification');

      final result = evaluatePhaseGateWithVerification(
        PhaseEntry(
          phaseId: 'PHASE-01',
          plans: [_plan()],
          targetScore: 16,
          requiredVerificationFiles: [verificationFile.path],
          closedDependencies: const ['PHASE-00'],
        ),
        getDefaultClosedDependenciesForPhase,
      );

      expect(result.passed, true);
      tmpDir.deleteSync(recursive: true);
    });

    test('blocks phase advancement when dependency phase not closed', () {
      final result = evaluatePhaseGateWithVerification(
        PhaseEntry(
          phaseId: 'PHASE-01',
          plans: [_plan()],
          targetScore: 16,
          closedDependencies: const [],
        ),
        getDefaultClosedDependenciesForPhase,
      );

      expect(result.passed, false);
      expect(
        result.blockers.any((blocker) => blocker.contains('Open dependency phases')),
        true,
      );
    });

    test('allows phase advancement when all dependencies closed', () {
      final result = evaluatePhaseGateWithVerification(
        PhaseEntry(
          phaseId: 'PHASE-01',
          plans: [_plan()],
          targetScore: 16,
          closedDependencies: const ['PHASE-00'],
        ),
        getDefaultClosedDependenciesForPhase,
      );

      expect(result.passed, true);
    });
  });
}

PlanEntry _plan() {
  return const PlanEntry(
    planId: 'PHASE-01-PLAN-01',
    phaseId: 'PHASE-01',
    tasks: [
      TaskEntry(
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
      ),
    ],
  );
}
