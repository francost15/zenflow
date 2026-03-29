# Agentic Phase Execution + Points System Design

## Purpose

Define a reusable execution framework for this repository that:

1. breaks work into explicit phases,
2. supports multiple parallel agents with governed autonomy,
3. uses a persistent internal points system to prioritize and control execution,
4. enforces hard gates before phase advancement,
5. applies immediately to the current Google Calendar sync hardening work, and
6. remains reusable for future project work.

This system is **for development operations**, not for end-user gamification.

---

## Goals

- Create a repo-native framework for phased execution.
- Score tasks, plans, and phases with a composite point model.
- Use score to drive both prioritization and execution policy.
- Persist execution state across sessions.
- Support safe multi-agent parallel work when tasks are isolated.
- Require verification before a task/plan/phase receives full completion credit.
- Use the framework immediately for the current sync/reliability roadmap.

## Non-goals

- No user-facing points or gamification.
- No generic PM tooling for other projects outside this repo.
- No enterprise ceremony overhead.
- No replacement of the current planning system; this extends it.

---

## Recommended Architecture

Use the existing planning structure as the base, then add an execution-governance layer.

### Core persisted artifacts

#### 1. `.planning/ROADMAP.md`
Primary roadmap by phase.

Extended responsibilities:
- phase objective,
- phase dependencies,
- target score,
- required completion score,
- hard gate conditions,
- verification expectations.

#### 2. `.planning/STATE.md`
Current operational state.

Responsibilities:
- active phase,
- active plans,
- blocked tasks,
- open issues,
- in-progress agent work,
- score earned vs score pending,
- next recommended actions.

#### 3. `.planning/SCORECARD.md` *(new)*
Persistent scoring ledger.

Responsibilities:
- task-level estimated score,
- task-level validated score,
- plan rollups,
- phase rollups,
- verification status references.

#### 4. `.planning/AGENT_POLICY.md` *(new)*
Execution policy for agents.

Responsibilities:
- when to use 1 vs multiple agents,
- what risk levels require specialist skills,
- what work can run in parallel,
- what requires checkpoints or reviews,
- what must be verified before merge/closure.

#### 5. `.planning/phases/<phase>/...`
Phase-local artifacts continue to exist:
- PLANs,
- SUMMARYs,
- VERIFICATION,
- UAT,
- optional per-phase score notes.

Per-phase score notes are informational only and never override `SCORECARD.md`.

### Canonical authority model

To avoid ambiguity, each artifact has one authority domain:

- `ROADMAP.md` = canonical source for phase list, phase order, dependencies, phase goals, closure thresholds.
- `*-PLAN.md` = canonical source for task definitions, task IDs, verification requirements, file ownership.
- `SCORECARD.md` = canonical source for estimated and validated scores.
- `*-VERIFICATION.md` and `*-UAT.md` = canonical source for completion evidence and open closure blockers.
- `STATE.md` = canonical source for current execution status only (never the source of truth for requirements or score math).

If files disagree:
1. verification/UAT evidence wins over status claims,
2. scorecard wins over ad hoc summaries for score values,
3. plans win over state for task definition,
4. roadmap wins over state for phase order.

### Stable identifiers

Every tracked unit must have a stable ID:

- Phase: `PHASE-XX`
- Plan: `PHASE-XX-PLAN-YY`
- Task: `PHASE-XX-PLAN-YY-TNN`

Scores, verification, blockers, and summaries must reference these IDs exactly.

### Multi-agent update protocol

To keep markdown persistence safe under parallel work:

- Only the **lead/coordinator agent** updates `.planning/STATE.md` and `.planning/SCORECARD.md`.
- Worker agents may write only:
  - task-local notes,
  - plan summaries,
  - verification reports,
  - implementation code.
- Worker agents do **not** edit the shared live ledgers directly.
- Coordinator integrates worker results, then updates shared ledgers in one pass.

This makes the root planning files single-writer artifacts and avoids collision-heavy concurrent edits.

---

## Composite Point Model

Every task receives a score across five dimensions, each from **0 to 5**.

### Dimensions

1. **Impact**
   - How much the task moves the product toward the real goal.

2. **Risk Closed**
   - How much uncertainty, fragility, inconsistency, or failure surface is removed.

3. **Effort**
   - Cost/complexity of implementation and coordination.

4. **Verifiability**
   - How strongly the result can be proven via tests, analyze/build, logs, or UX evidence.

5. **Dependency Unlock**
   - How much downstream work becomes possible once this task is done.

### Dimension rubric

Use the same scoring rubric every session:

#### Impact
- `0` = cosmetic/no meaningful movement
- `1` = small local improvement
- `3` = meaningful feature or reliability gain
- `5` = phase-defining or user-critical outcome

#### Risk Closed
- `0` = no meaningful risk removed
- `1` = minor cleanup / small certainty gain
- `3` = closes a real failure mode or ambiguity
- `5` = removes critical inconsistency, data risk, auth risk, or repeated blocker

#### Effort
- `0` = trivial
- `1` = very small isolated change
- `3` = medium multi-file implementation
- `5` = complex, cross-cutting, or high-coordination work

#### Verifiability
- `0` = cannot currently be verified well
- `1` = manual confidence only
- `3` = targeted tests or strong observable checks
- `5` = strong automated verification with clear pass/fail evidence

#### Dependency Unlock
- `0` = unlocks nothing
- `1` = helps but not required downstream
- `3` = unlocks a meaningful next step
- `5` = hard prerequisite for major downstream work

### Effort interpretation

Effort increases execution rigor, but **does not automatically mean higher priority**.

- Priority ordering is driven primarily by `impact + risk_closed + dependency_unlock`.
- Effort influences:
  - expected execution cost,
  - whether to split work,
  - whether more review/verification is needed.

### Score types

#### Estimated Score
Assigned before execution.

Used for:
- ordering work,
- deciding number of agents,
- deciding required rigor,
- forecasting phase closure effort.

#### Validated Score
Assigned after execution and verification.

Used for:
- actual progress accounting,
- phase advancement,
- postmortem accuracy,
- future planning calibration.

### Completion rule

A task does **not** receive full validated score until required verification is complete.

Possible outcomes:
- **100% validated** — implementation + verification + no blocking defects,
- **70% validated** — all required verification commands pass, but unresolved issues remain and they are only `minor` or `note`,
- **40% validated** — implementation exists but required verification is incomplete,
- **0% validated** — failed, blocked, reverted, or contradicted by evidence.

### Score formulas

For a given task:

`estimated_score = impact + risk_closed + effort + verifiability + dependency_unlock`

`validated_score = estimated_score * validation_factor`

Where `validation_factor` is one of:
- `1.0`
- `0.7`
- `0.4`
- `0.0`

No custom percentages are allowed.

---

## Hard Gates

Hard gates are mandatory. A phase cannot advance unless all required gate conditions are met.

### Task gate
- implementation complete,
- required tests run,
- required static checks run,
- blocking issues resolved,
- validated score assigned.

#### Executable definitions
- **Required tests** = all test commands explicitly listed in the task `verify` section.
- **Required static checks** = all static-check commands explicitly listed in the task `verify` section.
- **Blocking issue** = any issue causing wrong behavior, data inconsistency, failing required verification, broken auth, broken destructive action, or false-success UX.
- **Required verification commands** = commands explicitly listed under the task or plan `verify` section.

Rule:
- if a task changes behavior, its `verify` section must include at least one targeted regression test command,
- if a task touches Dart files, its `verify` section must include the repo-standard `flutter analyze` command for those files.

### Plan gate
- all required tasks complete,
- integration across tasks verified,
- no unresolved critical or major defects,
- validated score reaches minimum threshold.

#### Plan closure threshold
Default plan gate:
- no task at `0% validated` if marked required,
- at least `85%` of the plan’s total estimated score must be validated,
- all required verification commands in the plan must pass.

### Phase gate
- all blocking plans complete,
- phase-level verification complete,
- no open critical or major issues,
- minimum validated phase score reached,
- dependency conditions satisfied for next phase.

#### Phase closure threshold
Each phase defines two numbers:

- **target score** = total expected score if everything planned is fully closed
- **closure score** = minimum validated score required to advance

Rule:
- `target_score` is aspirational and used for planning accuracy,
- `closure_score` is the hard minimum to advance,
- advancing below `target_score` is allowed only if `closure_score` is met and all hard gate conditions are satisfied.

Default closure rule:
- `closure_score = 90% of target_score` unless phase explicitly overrides.

If a gate fails:
- phase does not advance,
- missing conditions are written to `STATE.md`,
- score is not fully awarded,
- next actions are explicitly defined.

---

## Agent Governance

The point system is not just descriptive; it controls how agents are used.

### Recommended execution policy

#### Policy bands by estimated score

##### Band 1 — `0-8`
- 1 agent or direct execution,
- minimal overhead,
- standard verification.
- max agents: `1`

##### Band 2 — `9-15`
- parallel agents allowed,
- each agent owns exclusive files or independent concerns,
- mandatory summary + integration verification.
- max agents: `2`

##### Band 3 — `16-20`
- strong verification requirements,
- explicit review before closure,
- avoid parallel edits to the same files,
- use specialist skills where applicable.
- max agents: `2`

##### Band 4 — `21-25`
- prefer serial execution,
- require backward compatibility checks,
- require integration verification after task completion.
- max agents: `1`

### Isolation rule for multiple agents

Parallel agents are allowed only when:
- they do not edit the same files,
- they do not depend on each other’s in-flight outputs,
- their verification can run independently.

Otherwise work is serialized.

### Coordinator promotion procedure

Worker result promotion into shared ledgers is deterministic:

0. coordinator claims the task by recording owner + owned task ID in `STATE.md`,
1. worker completes code/tests/report,
2. worker writes task-local summary or verification artifact,
3. coordinator reads worker artifact,
4. coordinator updates `STATE.md`,
5. coordinator updates `SCORECARD.md`,
6. coordinator checks gates,
7. coordinator decides advancement/block.

No worker writes directly to the shared root ledgers.

### Skill expectations

- **systematic-debugging** for failures or unexpected behavior.
- **test-driven-development** for behavior changes and regressions.
- **dispatching-parallel-agents** for isolated multi-track work.
- **verification-before-completion** before declaring closure.
- **writing-plans** for implementation planning.

---

## Phase Model for Current Work

This framework should immediately structure the current sync/reliability roadmap.

### Bootstrap Phase 0 — Minimal Governance Enablement
Scope:
- create `SCORECARD.md`,
- create `AGENT_POLICY.md`,
- extend `ROADMAP.md` and `STATE.md` with score/gate fields,
- establish IDs, thresholds, and gate rules.

Purpose:
- make the governance system operational before Phases 1–3 execute under it.

### Phase 1 — Consistency of Existing Sync Paths
Scope:
- create/update/delete/toggle consistency,
- persistent login relink,
- truthful auth/link outcomes,
- failure rollback where possible.

Completion target:
- current task/calendar sync paths behave consistently,
- regressions covered,
- no misleading success signals for the implemented paths.

### Phase 2 — Reconciliation + Self-Healing
Scope:
- reconnect-time backfill,
- repair missing `calendarEventId`,
- recover from broken or stale event links,
- improve behavior after auth loss.

Completion target:
- unsynced tasks can be reconciled,
- broken links do not remain permanently broken without repair paths.

### Phase 3 — Honest Sync UX + Observability
Scope:
- real connection state in UI,
- explicit disconnected/error states,
- remove misleading “active sync” messaging,
- surface actionable recovery guidance.

Completion target:
- user can distinguish connected / disconnected / degraded states.

### Phase 4 — Reusable Repo Execution System
Scope:
- harden and extend the bootstrap framework,
- add reusable templates and stronger automation around score/gate flow,
- finalize the long-term reusable operating model.

Completion target:
- future project work can be planned and executed with the same score/gate system.

---

## Required file schemas

### `.planning/SCORECARD.md`
Required format:

```markdown
# SCORECARD

## Task Scores
| Task ID | Plan ID | Phase ID | Impact | Risk Closed | Effort | Verifiability | Dependency Unlock | Estimated | Validation Factor | Validated | Severity | Evidence | Status |

## Plan Rollups
| Plan ID | Phase ID | Estimated | Validated | Gate Status | Evidence |

## Phase Rollups
| Phase ID | Estimated | Closure Score | Validated | Gate Status | Evidence |
```

Allowed status values:
- `pending`
- `in_progress`
- `validated`
- `partial`
- `blocked`

Column rules:
- `Task ID` must use the full ID format `PHASE-XX-PLAN-YY-TNN`
- `Severity` means highest unresolved issue severity for that task
- `Evidence` must be a repo-relative path to a verification artifact or summary file

### `.planning/STATE.md`
Required format:

```markdown
# STATE

## Current Phase
- id: PHASE-XX
- status: pending|in_progress|blocked|ready_for_close|closed

## Active Plans
- PHASE-XX-PLAN-YY — status — owner

## Agent Assignments
- agent/task identifier — owned task IDs

## Blockers
- severity — referenced ID — description

## Next Actions
- ordered actionable items

## Score Snapshot
- estimated_total:
- validated_total:
- pending_total:

## Updated By
- actor:
- timestamp:
```

### `.planning/AGENT_POLICY.md`
Required format:

```markdown
# AGENT POLICY

## Score Bands
| Band | Score Range | Max Agents | Review Required | Parallel Allowed |

## Skill Rules
| Condition | Required Skill |

## Shared File Rule
<explicit single-writer and exclusive ownership rules>

## Gate Escalation
| Severity | Effect |
```

### `*-PLAN.md`
Required plan elements:

- phase ID
- plan ID
- task IDs using full IDs (`PHASE-XX-PLAN-YY-TNN`)
- `required: true|false` on each task
- exact `verify` command list for each required task
- explicit `files_modified`
- explicit dependencies

Task numbering semantics:
- `TNN` means the task suffix inside the full task ID, sequential two-digit within a plan (`T01`, `T02`, `T03`, ...).

### Phase verification artifact
Each phase must produce at least one verification artifact containing:

- phase ID
- commands run
- command result
- unresolved blockers
- closure recommendation

Required format:

```markdown
# VERIFICATION

## Phase
- id: PHASE-XX

## Commands
- command:
- result: pass|fail

## Open Issues
- severity — referenced ID — description

## Closure
- recommendation: close|do_not_close
- reason:
```

Required filename pattern:
- `.planning/phases/<phase-id>/<phase-id>-VERIFICATION.md`

---

## Scoring Rollup Rules

### Task rollup
`task_estimated = impact + risk_closed + effort + verifiability + dependency_unlock`

`task_validated <= task_estimated`

### Plan rollup
Sum of task validated scores, adjusted by:
- integration verified: required condition, not a bonus,
- critical or major issues open: hard block,
- incomplete verification: validated score cap remains at task level.

Formula:

`plan_estimated = sum(task_estimated)`

`plan_validated = sum(task_validated)`

### Phase rollup
Sum of plan validated scores, adjusted by:
- open blockers cause gate failure,
- unresolved minor/note issues only may leave contributing tasks at `70%`,
- missing required verification artifacts block closure.

Formula:

`phase_estimated = sum(plan_estimated)`

`phase_validated = sum(plan_validated)`

### Severity taxonomy

Only four severities are allowed:

- **critical** = data loss, broken auth, destructive inconsistency, failing required verification, false-success destructive UX
- **major** = wrong behavior without destructive impact, required feature incomplete
- **minor** = non-blocking issue with correct core behavior still intact
- **note** = observation or cleanup suggestion only

Gate alignment rule:
- `critical` and `major` both block full task validation,
- `critical` and `major` both block plan closure,
- `critical` and `major` both block phase closure.

### Validation factor rules

Validation factor is fully deterministic:

- `1.0` if all required verification commands pass and there are no unresolved `critical` or `major` issues
- `0.7` if all required verification commands pass and unresolved issues are only `minor` or `note`
- `0.4` if implementation exists but one or more required verification commands were not run
- `0.0` if any required verification command fails, or any unresolved `critical`/`major` issue exists, or the task is blocked/reverted

No other factors are allowed.

Interpolated dimension scores:
- `2` and `4` are allowed when the task clearly falls between anchor levels.

### Advancement rule
Each phase defines:
- **target score**,
- **minimum closure score**,
- **required gate checks**.

Phase closes only when all three are satisfied.

---

## Operational Loop

1. Plan work by phase.
2. Score tasks before execution.
3. Assign agent strategy from score/risk profile.
4. Execute tasks.
5. Verify tasks.
6. Assign validated score.
7. Recompute plan and phase status.
8. Check hard gates.
9. Advance only if gate passes.

This loop must persist to repo files so future sessions can continue without losing state.

### Lightweight cadence

To avoid process bloat:

- update `STATE.md` only when status meaningfully changes,
- update `SCORECARD.md` when a task moves to partial/validated/blocked,
- do not create extra docs beyond roadmap/state/scorecard/policy plus normal phase artifacts,
- keep tasks small enough that scoring is fast.

---

## Worked example

Example task: `PHASE-01-PLAN-02-T01` — “Sync task status toggle to Google Calendar”

- impact = `3`
- risk_closed = `4`
- effort = `2`
- verifiability = `5`
- dependency_unlock = `2`

`estimated_score = 16`

If implementation lands and targeted regression tests + analyze pass with no blocking issues:

`validated_score = 16 * 1.0 = 16`

If code lands but verification is incomplete:

`validated_score = 16 * 0.4 = 6.4`

This shows how a task can be visibly “worked on” without being allowed to fully count toward phase closure.

---

## Initial Implementation Recommendation

Implement in this order:

1. Execute Bootstrap Phase 0.
2. Apply the model to the current sync roadmap.
3. Execute sync phases under the new governance system.
4. Harden the system for future project work.

### Bootstrapping rule for current roadmap

When introducing this system into an existing roadmap:

1. assign `PHASE-XX` IDs to existing roadmap phases in order,
2. map existing plans to `PHASE-XX-PLAN-YY`,
3. assign full task IDs within each plan as `PHASE-XX-PLAN-YY-T01`, `...-T02`, ...,
4. populate estimated scores before execution resumes,
5. populate validated scores only from existing verification evidence.

### Phase score math

By default:

- `target_score = sum(plan_estimated)`
- `closure_score = ceil(target_score * 0.90)`

If scope changes:

1. plan estimates are recalculated,
2. `target_score` is recalculated from the new plan totals,
3. `closure_score` is recalculated immediately,
4. the change must be recorded in `ROADMAP.md` and `STATE.md`.

The coordinator is responsible for recalculating and recording these values.

### Required verification command convention

The framework is reusable, but verification commands are repo-specific.

For this Flutter/Dart repo, the default minimum static verification command format is:

`flutter analyze <space-separated touched dart files>`

If non-Dart files introduce their own tooling requirements, the task/plan must list those commands explicitly in its `verify` section.

### Numeric rounding and display

- task validated score may be fractional to one decimal place
- plan and phase validated totals are rounded to one decimal place
- `closure_score` and `target_score` are stored as integers

---

## Risks

- Over-scoring can become bureaucracy if tasks are too small.
- Gates that are too strict can stall flow.
- Agent parallelism without file ownership rules can create conflicts.
- Score inflation can make the system meaningless unless validated score remains evidence-based.

Mitigation:
- use simple 0–5 scoring,
- keep plans small,
- require evidence before validated score,
- treat critical failures as score blockers.

---

## Success Criteria

This design is successful when:

- the repo has a reusable phase execution framework,
- tasks/plans/phases carry persistent points,
- points influence both prioritization and execution policy,
- hard gates block unsafe advancement,
- multi-agent execution is explicitly governed,
- current sync work can be executed as phased work inside this framework after Bootstrap Phase 0,
- future sessions can resume the system from repo state alone.
