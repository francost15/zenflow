# ROADMAP

## Phases
| Phase ID | Objective | Dependencies | Target Score | Closure Score | Hard Gate Conditions | Verification Expectations |
|----------|-----------|-------------|-------------|---------------|---------------------|--------------------------|
| PHASE-00 | Bootstrap governance | - | 44 | 40 | Bootstrap artifacts exist and validated | Gate checker passes PHASE-00 |
| PHASE-01 | Sync consistency | PHASE-00 | 40 | 36 | PHASE-00 closed, consistency tests pass | flutter analyze, regression tests |
| PHASE-02 | Reconciliation + self-healing | PHASE-00, PHASE-01 | 23 | 21 | PHASE-01 closed, backfill logic verified | integration tests, backfill verification |
| PHASE-03 | Honest sync UX + observability | PHASE-00, PHASE-01, PHASE-02 | 33 | 30 | PHASE-02 closed, UX state tests pass | UI state verification, observability checks |
| PHASE-04 | Governance hardening | PHASE-00, PHASE-01, PHASE-02, PHASE-03 | 43 | 39 | All prior phases closed, reusable templates validated | Template validation, system hardening tests |
| PHASE-05 | Calendar Views Enhancement | PHASE-04 | 25 | 22 | PHASE-04 closed, view toggle and quick date chips implemented | flutter analyze, manual UI verification |
| PHASE-06 | Performance Optimization | PHASE-05 | 28 | 25 | PHASE-05 closed, pagination and lazy loading working | flutter test, scroll performance |
| PHASE-07 | Voice Input & Accessibility | PHASE-06 | 22 | 20 | PHASE-06 closed, voice input and haptics functional | Manual voice input test, haptic feedback test |
| PHASE-08 | Polish & Animations | PHASE-07 | 20 | 18 | PHASE-07 closed, transitions and micro-interactions polished | Manual UI/UX review |
| PHASE-09 | Quality close-out (E2E, theme consistency, file size gates) | PHASE-08 | 48 | 43 | PHASE-08 closed, `flutter test` green including repo_structure | See PHASE-09-01-PLAN.md |
