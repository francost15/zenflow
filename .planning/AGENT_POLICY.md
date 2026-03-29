# AGENT POLICY

## Score Bands
| Band | Score Range | Max Agents | Review Required | Parallel Allowed |
|------|-------------|------------|----------------|-----------------|
| Band 1 | 0-8 | 1 | no | no |
| Band 2 | 9-15 | 2 | no | yes |
| Band 3 | 16-20 | 2 | yes | conditional |
| Band 4 | 21-25 | 1 | yes | no |

## Skill Rules
| Condition | Required Skill |
|-----------|----------------|
| Bug or unexpected behavior | systematic-debugging |
| Behavior change or regression | test-driven-development |
| Isolated multi-track work | dispatching-parallel-agents |
| Before declaring closure | verification-before-completion |
| Implementation planning | writing-plans |

## Shared File Rule
Single-writer / coordinator protocol:
- Only the lead/coordinator agent updates `.planning/STATE.md` and `.planning/SCORECARD.md`.
- Worker agents may write only: task-local notes, plan summaries, verification reports, implementation code.
- Worker agents do NOT edit the shared live ledgers directly.
- Coordinator integrates worker results, then updates shared ledgers in one pass.

## Gate Escalation
| Severity | Effect |
|----------|--------|
| critical | Blocks task validation, plan closure, phase closure |
| major | Blocks task validation, plan closure, phase closure |
| minor | Caps validation factor at 0.7 |
| note | No blocking effect |
