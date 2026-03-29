# AGENT POLICY

## Score Bands
| Band | Score Range | Max Agents | Review Required | Parallel Allowed |
|------|-------------|------------|-----------------|------------------|
| Band 1 | 0-8 | 1 | No | No |
| Band 2 | 9-15 | 1 | No | No |
| Band 3 | 16-20 | 2 | Yes | Yes |
| Band 4 | 21-25 | 2 | Yes | Yes |
| Band 5 | 26+ | 1 | Yes | No |

## Skill Rules
| Condition | Required Skill |
|-----------|----------------|
| Debugging failures or unexpected behavior | systematic-debugging |
| Behavior changes and regressions | test-driven-development |
| Isolated multi-track work | dispatching-parallel-agents |
| Before declaring closure | verification-before-completion |
| Implementation planning | writing-plans |

## Shared File Rule
Single-writer and exclusive ownership rules:
- Each task has one designated owner who writes to shared ledgers
- Workers write to task-local artifacts only
- Coordinator promotes worker results to shared ledgers
- No worker writes directly to shared root ledgers (SCORECARD.md, STATE.md)

## Gate Escalation
| Severity | Effect |
|----------|--------|
| Gate failed | Phase does not advance, missing conditions written to STATE.md |
| Below closure_score | Score not fully awarded, next actions defined |
| Above closure_score, below target_score | Allowed if closure_score met and hard gate conditions satisfied |
