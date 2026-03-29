# PHASE-00-PLAN-01

phase_id: PHASE-00
plan_id: PHASE-00-PLAN-01

## Task Scores

| Task ID | Plan ID | Phase ID | Impact | Risk Closed | Effort | Verifiability | Dependency Unlock | Estimated | Validation Factor | Required |
|---------|---------|---------|--------|-------------|--------|---------------|------------------|-----------|------------------|----------|
| PHASE-00-PLAN-01-T01 | PHASE-00-PLAN-01 | PHASE-00 | 5 | 5 | 3 | 5 | 5 | 23 | 0.0 | true |
| PHASE-00-PLAN-01-T02 | PHASE-00-PLAN-01 | PHASE-00 | 4 | 4 | 3 | 5 | 5 | 21 | 0.0 | true |

## Verify

```bash
dart test test/tool/planning/
dart run tool/planning/check_gates.dart --phase PHASE-00
```

## Files Modified

- lib/tool/planning/models.dart
- lib/tool/planning/markdown_io.dart
- lib/tool/planning/check_gates.dart
- tool/planning/check_gates.dart
- test/tool/planning/gate_checker_test.dart

## Dependencies

- None (PHASE-00 is the first phase)