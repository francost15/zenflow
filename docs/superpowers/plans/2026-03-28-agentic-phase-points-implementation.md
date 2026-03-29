# Agentic Phase + Points System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the reusable repo execution system from the approved spec, then use it to finish the remaining Google Calendar sync reliability phases.

**Architecture:** Implement the governance layer as persistent `.planning` ledgers plus a small Dart validation/gate-check tool so scoring and advancement are deterministic rather than narrative. Keep the existing Flutter data/domain/presentation structure for product code, but move sync repair and reconciliation into a dedicated service so task/calendar consistency logic stops expanding inside `TaskRepositoryImpl`.

**Tech Stack:** Flutter, Dart, flutter_test, Firebase Auth, Google Sign-In, Google Calendar API, Markdown planning artifacts, CLI tooling under `tool/`

---

## File Structure

### Governance / planning system

- Create: `.planning/ROADMAP.md` — canonical phase list, goals, dependencies, target/closure scores
- Create: `.planning/STATE.md` — active phase, owned tasks, blockers, next actions, score snapshot
- Create: `.planning/SCORECARD.md` — task/plan/phase score ledger
- Create: `.planning/AGENT_POLICY.md` — score bands, max-agent rules, escalation rules
- Create: `.planning/phases/PHASE-00/PHASE-00-PLAN-01.md` — bootstrap phase plan
- Create: `.planning/phases/PHASE-01/PHASE-01-PLAN-01.md` — sync service plan
- Create: `.planning/phases/PHASE-01/PHASE-01-PLAN-02.md` — auth-loss/reconnect plan
- Create: `.planning/phases/PHASE-02/PHASE-02-PLAN-01.md` — reconciliation plan
- Create: `.planning/phases/PHASE-03/PHASE-03-PLAN-01.md` — sync status UX plan
- Create: `.planning/phases/PHASE-03/PHASE-03-PLAN-02.md` — notice queue UX plan
- Create: `.planning/phases/PHASE-04/PHASE-04-PLAN-01.md` — ledger population plan
- Create: `.planning/phases/PHASE-04/PHASE-04-PLAN-02.md` — final verification plan
- Create: `tool/planning/models.dart` — typed models for phases/plans/tasks/score entries
- Create: `tool/planning/markdown_io.dart` — parse/write helpers for deterministic markdown schemas
- Create: `tool/planning/gate_checker.dart` — score math + gate evaluation
- Create: `tool/planning/check_gates.dart` — CLI entry point
- Test: `test/tool/planning/gate_checker_test.dart`

### Sync reliability core

- Create: `lib/data/services/task_calendar_sync_service.dart` — create/update/delete/reconcile/repair logic for task ↔ calendar links
- Modify: `lib/core/error/exceptions.dart` — typed sync/auth/reconciliation exceptions
- Modify: `lib/domain/repositories/task_repository.dart` — expose reconciliation-oriented operations if needed
- Modify: `lib/data/repositories/task_repository_impl.dart` — delegate consistency-sensitive calendar logic to the new service
- Modify: `lib/data/datasources/firestore/task_datasource.dart` — query unsynced tasks / persist repair updates
- Modify: `lib/data/datasources/google/google_calendar_datasource.dart` — explicit auth-loss handling instead of silent empty lists
- Modify: `lib/domain/repositories/calendar_repository.dart`
- Modify: `lib/data/repositories/calendar_repository_impl.dart`
- Test: `test/task_repository_impl_test.dart`
- Create: `test/calendar_bloc_test.dart`

### Auth + presentation sync honesty

- Modify: `lib/presentation/blocs/auth/auth_bloc.dart`
- Modify: `lib/presentation/blocs/auth/auth_state.dart`
- Modify: `lib/presentation/blocs/calendar/calendar_bloc.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/presentation/screens/home/home_screen.dart`
- Modify: `lib/presentation/screens/calendar/calendar_screen.dart`
- Modify: `lib/presentation/widgets/connection_indicator.dart`
- Create: `lib/presentation/widgets/sync_status_badge.dart`
- Modify: `test/auth_bloc_test.dart`
- Create: `test/sync_status_badge_test.dart`

---

## Initial governed phase / plan / task IDs and estimated scores

Seed these exact IDs into `SCORECARD.md` during Bootstrap:

| Task ID | Purpose | Impact | Risk Closed | Effort | Verifiability | Dependency Unlock | Estimated |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `PHASE-00-PLAN-01-T01` | Build gate checker | 5 | 5 | 3 | 5 | 5 | 23 |
| `PHASE-00-PLAN-01-T02` | Seed planning ledgers + governed phase plan files | 4 | 4 | 3 | 5 | 5 | 21 |
| `PHASE-01-PLAN-01-T01` | Extract task/calendar sync service | 4 | 5 | 4 | 4 | 4 | 21 |
| `PHASE-01-PLAN-02-T01` | Make auth-loss and reconnect explicit | 4 | 4 | 3 | 5 | 3 | 19 |
| `PHASE-02-PLAN-01-T01` | Reconcile unsynced tasks after link/reconnect | 5 | 5 | 4 | 4 | 5 | 23 |
| `PHASE-03-PLAN-01-T01` | Replace optimistic sync UI with real status badge | 4 | 4 | 3 | 4 | 3 | 18 |
| `PHASE-03-PLAN-02-T01` | Queue sync notices and destructive-action messaging | 3 | 4 | 2 | 4 | 2 | 15 |
| `PHASE-04-PLAN-01-T01` | Populate ledgers and governed verification artifacts | 4 | 4 | 3 | 5 | 4 | 20 |
| `PHASE-04-PLAN-02-T01` | Run verification pack and record validated scores | 5 | 5 | 3 | 5 | 5 | 23 |

Use these values exactly when bootstrapping the first scorecard.

---

## Chunk 1: Bootstrap Phase 0 — Make the governance system real

### Task `PHASE-00-PLAN-01-T01`: Build deterministic planning schema + gate checker

**Files:**
- Create: `tool/planning/models.dart`
- Create: `tool/planning/markdown_io.dart`
- Create: `tool/planning/gate_checker.dart`
- Create: `tool/planning/check_gates.dart`
- Test: `test/tool/planning/gate_checker_test.dart`

- [ ] **Step 1: Write the failing tests for score math and gates**

Create `test/tool/planning/gate_checker_test.dart` with focused cases for:
- parsing full task IDs like `PHASE-01-PLAN-02-T01`
- computing `estimated_score`
- applying only allowed validation factors (`1.0`, `0.7`, `0.4`, `0.0`)
- rounding validated task/plan/phase totals to one decimal place
- rejecting invalid score statuses and invalid severity labels
- blocking plan closure when any required task has `0.0`
- blocking phase closure when any `critical` or `major` issue is present
- computing `closure_score = ceil(target_score * 0.90)`

- [ ] **Step 2: Run the tests to confirm they fail for the right reason**

Run:
`flutter test test/tool/planning/gate_checker_test.dart`

Expected:
- test file fails because the models/checker/CLI do not exist yet

- [ ] **Step 3: Implement the smallest typed planning engine**

Implement:
- immutable models for phase/plan/task/score entries
- markdown table/section readers and writers matching the approved spec schemas exactly
- gate evaluation functions that:
  - derive `estimated_score`
  - derive `validated_score`
  - round validated totals to one decimal place
  - compute plan/phase totals
  - enforce `plan_validated >= 85% of plan_estimated` for plan closure
  - block closure when required verification artifacts are missing
  - block phase advancement when dependencies are still open
  - fail on unresolved `critical`/`major` severities
  - reject statuses outside `pending|in_progress|validated|partial|blocked`
  - reject severities outside `critical|major|minor|note`
  - verify score-band agent rules

In `tool/planning/check_gates.dart`, expose a CLI like:

```bash
dart run tool/planning/check_gates.dart --phase PHASE-01
```

Print machine-readable pass/fail lines; do not print free-form prose only.

- [ ] **Step 4: Run the tests again until green**

Run:
`flutter test test/tool/planning/gate_checker_test.dart`

Expected:
- all gate-checker tests pass

- [ ] **Step 5: Smoke-test the CLI**

Run:
`dart run tool/planning/check_gates.dart --help`

Then:
`flutter analyze tool/planning/models.dart tool/planning/markdown_io.dart tool/planning/gate_checker.dart tool/planning/check_gates.dart test/tool/planning/gate_checker_test.dart`

Expected:
- exits successfully and documents supported arguments
- analyze is clean

- [ ] **Step 6: Commit**

```bash
git add tool/planning test/tool/planning/gate_checker_test.dart
git commit -m "feat: add planning gate checker"
```

### Task `PHASE-00-PLAN-01-T02`: Seed Bootstrap Phase 0 planning artifacts for current work

**Files:**
- Create: `.planning/ROADMAP.md`
- Create: `.planning/STATE.md`
- Create: `.planning/SCORECARD.md`
- Create: `.planning/AGENT_POLICY.md`
- Create: `.planning/phases/PHASE-00/PHASE-00-PLAN-01.md`
- Create: `.planning/phases/PHASE-00/PHASE-00-VERIFICATION.md`
- Create: `.planning/phases/PHASE-00/PHASE-00-SUMMARY.md`
- Create: `.planning/phases/PHASE-01/PHASE-01-PLAN-01.md`
- Create: `.planning/phases/PHASE-01/PHASE-01-PLAN-02.md`
- Create: `.planning/phases/PHASE-02/PHASE-02-PLAN-01.md`
- Create: `.planning/phases/PHASE-03/PHASE-03-PLAN-01.md`
- Create: `.planning/phases/PHASE-03/PHASE-03-PLAN-02.md`
- Create: `.planning/phases/PHASE-04/PHASE-04-PLAN-01.md`
- Create: `.planning/phases/PHASE-04/PHASE-04-PLAN-02.md`

- [ ] **Step 1: Write the failing validation test/fixture for empty planning artifacts**

Extend `test/tool/planning/gate_checker_test.dart` with fixtures asserting that missing required sections/columns in the four root planning files are rejected.

- [ ] **Step 2: Run the tests and confirm schema failures**

Run:
`flutter test test/tool/planning/gate_checker_test.dart`

Expected:
- failures complain about missing planning artifacts / missing required schema blocks

- [ ] **Step 3: Create the root planning files with real initial content**

Populate phases as:
- `PHASE-00` Bootstrap governance
- `PHASE-01` Sync consistency
- `PHASE-02` Reconciliation + self-healing
- `PHASE-03` Honest sync UX + observability
- `PHASE-04` Governance hardening

In `ROADMAP.md`, explicitly store for every phase:
- dependencies
- target score
- closure score
- hard gate conditions
- verification expectations

Seed `SCORECARD.md` with estimated entries for the current roadmap, not validated ones.

Inside each governed `*-PLAN.md` file, include:
- phase ID
- plan ID
- full task ID(s)
- `required: true`
- exact `verify` commands
- exact `files_modified`
- dependencies on earlier plans where applicable

Seed `AGENT_POLICY.md` with exact defaults from the spec:
- Band 1 max agents = 1
- Band 2 max agents = 2
- Band 3 max agents = 2
- Band 4 max agents = 1

Populate all required `AGENT_POLICY.md` sections explicitly:
- `Score Bands`
- `Skill Rules`
- `Shared File Rule`
- `Gate Escalation`

In `Shared File Rule`, write the single-writer/coordinator protocol exactly as approved in the spec.

Seed `STATE.md` with:
- current phase = `PHASE-00`
- current phase status = `in_progress`
- no claimed worker tasks yet
- estimated total derived from `SCORECARD.md`
- validated total initialized to `0.0`
- pending total derived from `SCORECARD.md`

Seed `ROADMAP.md` with these exact phase gate numbers:
- `PHASE-00`: `target_score = 44`, `closure_score = 40`
- `PHASE-01`: `target_score = 40`, `closure_score = 36`
- `PHASE-02`: `target_score = 23`, `closure_score = 21`
- `PHASE-03`: `target_score = 33`, `closure_score = 30`
- `PHASE-04`: `target_score = 43`, `closure_score = 39`

Populate all required `STATE.md` sections explicitly:
- `Current Phase`
- `Active Plans`
- `Agent Assignments`
- `Blockers`
- `Next Actions`
- `Score Snapshot`
- `Updated By`

- [ ] **Step 4: Verify schema + gate bootstrap**

Run:
`dart run tool/planning/check_gates.dart --phase PHASE-00`

Then:
`flutter analyze tool/planning/models.dart tool/planning/markdown_io.dart tool/planning/gate_checker.dart tool/planning/check_gates.dart test/tool/planning/gate_checker_test.dart`

Expected:
- command succeeds and reports Bootstrap Phase 0 as not yet closed but structurally valid
- analyze is clean

- [ ] **Step 5: Write Bootstrap verification and summary artifacts from actual results**

Record the commands run, their results, Bootstrap gate status, and the next unlocked phase in:
- `.planning/phases/PHASE-00/PHASE-00-VERIFICATION.md`
- `.planning/phases/PHASE-00/PHASE-00-SUMMARY.md`

- [ ] **Step 6: Commit**

```bash
git add .planning test/tool/planning/gate_checker_test.dart
git commit -m "docs: bootstrap planning ledgers"
```

## Chunk 2: Phase 1–2 product work — finish sync consistency, reconciliation, and self-healing

### Task `PHASE-01-PLAN-01-T01`: Extract task/calendar consistency into a dedicated sync service

**Files:**
- Create: `lib/data/services/task_calendar_sync_service.dart`
- Modify: `lib/core/error/exceptions.dart`
- Modify: `lib/data/repositories/task_repository_impl.dart`
- Modify: `lib/domain/repositories/task_repository.dart`
- Modify: `lib/data/datasources/firestore/task_datasource.dart`
- Modify: `test/task_repository_impl_test.dart`

- [ ] **Step 1: Write failing repository tests for the remaining consistency gaps**

Add tests for:
- reconnect-time backfill of a task with `calendarEventId == null`
- update-time self-heal when linked event returns `404`
- delete-time behavior when remote event is missing vs remote delete truly fails
- reconcile operation processing multiple unsynced tasks without duplicating already-linked tasks

- [ ] **Step 2: Run the repository tests to confirm red**

Run:
`flutter test test/task_repository_impl_test.dart`

Expected:
- new tests fail because no reconciliation/self-healing service exists yet

- [ ] **Step 3: Implement `TaskCalendarSyncService`**

Move the branching logic out of `TaskRepositoryImpl` into a focused service with methods like:

```dart
Future<Task> createAndLink(Task task);
Future<Task> updateAndSync(Task task);
Future<void> deleteAndUnlink(Task task);
Future<ReconciliationResult> reconcileUnsyncedTasks(List<Task> tasks);
```

Requirements:
- repository remains the Firestore source of truth
- service handles remote create/update/delete/repair logic
- `404` on update means recreate the missing event, persist the new `calendarEventId`, and continue
- successful remote event creation followed by local persistence failure must roll back the remote event
- true remote delete failure must not remove the local task

- [ ] **Step 4: Re-run the repository tests until green**

Run:
`flutter test test/task_repository_impl_test.dart`

Then:
`flutter analyze lib/data/services/task_calendar_sync_service.dart lib/core/error/exceptions.dart lib/data/repositories/task_repository_impl.dart lib/domain/repositories/task_repository.dart lib/data/datasources/firestore/task_datasource.dart test/task_repository_impl_test.dart`

Expected:
- all existing and new repository sync tests pass
- analyze is clean

- [ ] **Step 5: Commit**

```bash
git add lib/data/services lib/data/repositories/task_repository_impl.dart lib/core/error/exceptions.dart lib/domain/repositories/task_repository.dart lib/data/datasources/firestore/task_datasource.dart test/task_repository_impl_test.dart
git commit -m "feat: add task calendar sync service"
```

### Task `PHASE-01-PLAN-02-T01`: Make auth loss and manual reconnect explicit instead of silent

**Files:**
- Modify: `lib/data/datasources/google/google_calendar_datasource.dart`
- Modify: `lib/domain/repositories/calendar_repository.dart`
- Modify: `lib/data/repositories/calendar_repository_impl.dart`
- Modify: `lib/presentation/blocs/auth/auth_bloc.dart`
- Modify: `lib/presentation/blocs/auth/auth_state.dart`
- Modify: `lib/presentation/blocs/calendar/calendar_bloc.dart`
- Modify: `test/auth_bloc_test.dart`
- Create: `test/calendar_bloc_test.dart`
- Create: `.planning/phases/PHASE-01/PHASE-01-VERIFICATION.md`
- Create: `.planning/phases/PHASE-01/PHASE-01-SUMMARY.md`

- [ ] **Step 1: Write failing calendar bloc tests for explicit reconnect behavior**

Cover cases for:
- connect canceled/denied -> `CalendarNeedsSignIn`
- token/auth loss during fetch -> `CalendarNeedsSignIn` instead of `CalendarLoaded([])`
- reconnect after authorization success -> loaded events
- persisted Firebase session restores truthful `calendarLinked` state without pretending success

- [ ] **Step 2: Run the bloc tests and confirm red**

Run:
`flutter test test/calendar_bloc_test.dart`

Expected:
- failures show the datasource/repository still hide auth loss as empty events

- [ ] **Step 3: Implement typed auth-loss signaling**

In `GoogleCalendarDatasource`:
- stop returning `[]` for auth-loss scenarios
- throw a typed exception for auth required / auth expired
- keep non-auth operational failures distinct

In `CalendarBloc`:
- map auth-required exceptions to `CalendarNeedsSignIn`
- map non-auth failures to `CalendarError`

In `AuthBloc`:
- keep persisted-session `AuthCheckRequested` aligned with real calendar link state
- do not mark `calendarLinked: true` unless authorization is actually present

- [ ] **Step 4: Run tests and analyze**

Run:
`flutter test test/calendar_bloc_test.dart`

Then:
`flutter analyze lib/data/datasources/google/google_calendar_datasource.dart lib/domain/repositories/calendar_repository.dart lib/data/repositories/calendar_repository_impl.dart lib/presentation/blocs/auth/auth_bloc.dart lib/presentation/blocs/auth/auth_state.dart lib/presentation/blocs/calendar/calendar_bloc.dart test/auth_bloc_test.dart test/calendar_bloc_test.dart`

Expected:
- tests green, analyze clean

- [ ] **Step 5: Write Phase 1 verification and summary artifacts**

Record the passing commands, remaining issues, and closure recommendation in:
- `.planning/phases/PHASE-01/PHASE-01-VERIFICATION.md`
- `.planning/phases/PHASE-01/PHASE-01-SUMMARY.md`

- [ ] **Step 6: Commit**

```bash
git add lib/data/datasources/google/google_calendar_datasource.dart lib/domain/repositories/calendar_repository.dart lib/data/repositories/calendar_repository_impl.dart lib/presentation/blocs/auth/auth_bloc.dart lib/presentation/blocs/auth/auth_state.dart lib/presentation/blocs/calendar/calendar_bloc.dart test/auth_bloc_test.dart test/calendar_bloc_test.dart
git commit -m "fix: surface calendar auth loss explicitly"
```

### Task `PHASE-02-PLAN-01-T01`: Trigger reconciliation after login and manual calendar connect

**Files:**
- Modify: `lib/presentation/blocs/auth/auth_bloc.dart`
- Modify: `lib/presentation/blocs/auth/auth_state.dart`
- Modify: `lib/presentation/blocs/calendar/calendar_bloc.dart`
- Modify: `lib/data/repositories/task_repository_impl.dart` *(or service entrypoint only, if the repository exposes reconciliation)*
- Modify: `test/auth_bloc_test.dart`
- Modify: `test/calendar_bloc_test.dart`
- Create: `.planning/phases/PHASE-02/PHASE-02-VERIFICATION.md`
- Create: `.planning/phases/PHASE-02/PHASE-02-SUMMARY.md`

- [ ] **Step 1: Write the failing orchestration tests**

Add tests asserting:
- fresh login with successful calendar link also triggers reconciliation for unsynced tasks
- manual calendar connect also triggers reconciliation
- login still succeeds if reconciliation fails; notice is surfaced, not silent

- [ ] **Step 2: Run the auth + calendar tests to see the missing orchestration**

Run:
`flutter test test/auth_bloc_test.dart`

Then:
`flutter test test/calendar_bloc_test.dart`

Expected:
- new orchestration tests fail because reconnect does not reconcile yet

- [ ] **Step 3: Implement the orchestration**

Requirements:
- on successful Google login + linked calendar, call reconciliation once
- on successful manual calendar connect, call reconciliation once
- return a result object or notice string describing repaired/created/skipped items
- do not hard-fail login for reconciliation warnings

- [ ] **Step 4: Re-run the auth + calendar tests**

Run:
`flutter test test/auth_bloc_test.dart && flutter test test/calendar_bloc_test.dart`

Then:
`flutter analyze lib/presentation/blocs/auth/auth_bloc.dart lib/presentation/blocs/auth/auth_state.dart lib/presentation/blocs/calendar/calendar_bloc.dart lib/data/repositories/task_repository_impl.dart test/auth_bloc_test.dart test/calendar_bloc_test.dart`

Expected:
- both files pass
- analyze is clean

- [ ] **Step 5: Write Phase 2 verification and summary artifacts**

Record reconciliation behavior, command output, and unresolved issues in:
- `.planning/phases/PHASE-02/PHASE-02-VERIFICATION.md`
- `.planning/phases/PHASE-02/PHASE-02-SUMMARY.md`

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/blocs/auth lib/presentation/blocs/calendar lib/data/repositories/task_repository_impl.dart test/auth_bloc_test.dart test/calendar_bloc_test.dart
git commit -m "feat: reconcile unsynced tasks after calendar link"
```

## Chunk 3: Phase 3 — honest sync UX + observability

### Task `PHASE-03-PLAN-01-T01`: Replace optimistic sync messaging with a real sync status projection

**Files:**
- Create: `lib/presentation/widgets/sync_status_badge.dart`
- Modify: `lib/presentation/screens/home/home_screen.dart`
- Modify: `lib/presentation/screens/calendar/calendar_screen.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/presentation/widgets/connection_indicator.dart`
- Create: `test/sync_status_badge_test.dart`

- [ ] **Step 1: Write the failing widget tests**

Cover these visual states:
- calendar linked + online -> connected badge
- auth signed in but calendar not linked -> reconnect-needed badge
- offline -> offline indicator + degraded sync state
- auth/calendar error -> explicit warning state, not `SYNC ACTIVE`

- [ ] **Step 2: Run the widget tests to confirm red**

Run:
`flutter test test/sync_status_badge_test.dart`

Expected:
- failures because no `SyncStatusBadge` exists and `HomeScreen` still hardcodes `SYNC ACTIVE`

- [ ] **Step 3: Implement the badge and wire it into the shell**

Requirements:
- derive state from `AuthState`, `CalendarState`, and online/offline state
- remove hardcoded `SYNC ACTIVE`
- mount `ConnectionIndicator` at app-shell level so offline state is always visible
- make the calendar screen show reconnect guidance when auth is lost

- [ ] **Step 4: Run widget tests and analyze**

Run:
`flutter test test/sync_status_badge_test.dart`

Then:
`flutter analyze lib/app/app.dart lib/presentation/screens/home/home_screen.dart lib/presentation/screens/calendar/calendar_screen.dart lib/presentation/widgets/connection_indicator.dart lib/presentation/widgets/sync_status_badge.dart test/sync_status_badge_test.dart`

Expected:
- tests pass, analyze clean

- [ ] **Step 5: Commit**

```bash
git add lib/app/app.dart lib/presentation/screens/home/home_screen.dart lib/presentation/screens/calendar/calendar_screen.dart lib/presentation/widgets/connection_indicator.dart lib/presentation/widgets/sync_status_badge.dart test/sync_status_badge_test.dart
git commit -m "feat: show honest calendar sync state"
```

### Task `PHASE-03-PLAN-02-T01`: Close the remaining notice/reporting gaps in task flows

**Files:**
- Modify: `lib/presentation/blocs/task/task_bloc.dart`
- Modify: `lib/presentation/blocs/task/task_state.dart`
- Modify: `lib/presentation/screens/home/home_screen.dart`
- Modify: `test/task_bloc_test.dart`
- Create: `.planning/phases/PHASE-03/PHASE-03-VERIFICATION.md`
- Create: `.planning/phases/PHASE-03/PHASE-03-SUMMARY.md`
- Create: `.planning/phases/PHASE-03/PHASE-03-UAT.md`

- [ ] **Step 1: Write failing tests for successive warnings and destructive-action notices**

Add tests covering:
- back-to-back task mutations do not overwrite earlier notices before surfacing them
- delete failures show a failure-style message, not a success-style message
- reconcile warnings are surfaced once and then cleared

- [ ] **Step 2: Run the task bloc tests to confirm red**

Run:
`flutter test test/task_bloc_test.dart`

Expected:
- failures demonstrate the current single-string pending notice behavior is insufficient

- [ ] **Step 3: Implement a small queued-notice mechanism**

Keep it minimal:
- do not create a global event bus
- use a queue/list in bloc state or an explicit pending-notice structure
- ensure destructive-action failures use language that matches actual persisted state

- [ ] **Step 4: Re-run the task bloc tests**

Run:
`flutter test test/task_bloc_test.dart`

Then:
`flutter analyze lib/presentation/blocs/task/task_bloc.dart lib/presentation/blocs/task/task_state.dart lib/presentation/screens/home/home_screen.dart test/task_bloc_test.dart`

Expected:
- tests pass
- analyze is clean

- [ ] **Step 5: Write Phase 3 verification, summary, and UAT artifacts**

Record:
- command evidence in `.planning/phases/PHASE-03/PHASE-03-VERIFICATION.md`
- implementation summary in `.planning/phases/PHASE-03/PHASE-03-SUMMARY.md`
- manual UI checks for sync badge/reconnect states in `.planning/phases/PHASE-03/PHASE-03-UAT.md`

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/blocs/task/task_bloc.dart lib/presentation/blocs/task/task_state.dart lib/presentation/screens/home/home_screen.dart test/task_bloc_test.dart
git commit -m "fix: queue task sync notices correctly"
```

## Chunk 4: Phase 4 — harden the reusable execution system and close the loop

### Task `PHASE-04-PLAN-01-T01`: Populate the planning ledgers for the sync roadmap and verify the first closure path

**Files:**
- Modify: `.planning/ROADMAP.md`
- Modify: `.planning/STATE.md`
- Modify: `.planning/SCORECARD.md`
- Modify: `.planning/AGENT_POLICY.md`
- Create: `.planning/templates/PLAN_TEMPLATE.md`
- Create: `.planning/templates/VERIFICATION_TEMPLATE.md`
- Create: `.planning/templates/SUMMARY_TEMPLATE.md`
- Create: `.planning/phases/PHASE-04/PHASE-04-VERIFICATION.md`
- Create: `.planning/phases/PHASE-04/PHASE-04-SUMMARY.md`

This template work is intentional Phase 4 hardening, not accidental process bloat.

- [ ] **Step 1: Fill in real IDs, scores, and closure thresholds for the current roadmap**

Use the approved spec exactly:
- full task IDs everywhere
- integer `target_score`
- integer `closure_score = ceil(target_score * 0.90)` unless explicitly overridden
- repo-relative evidence paths in `SCORECARD.md`

- [ ] **Step 2: Run the gate checker against each seeded phase**

Run:
`dart run tool/planning/check_gates.dart --phase PHASE-00`

Then:
`dart run tool/planning/check_gates.dart --phase PHASE-01`

Then:
`dart run tool/planning/check_gates.dart --phase PHASE-02`

Then:
`dart run tool/planning/check_gates.dart --phase PHASE-03`

Then:
`dart run tool/planning/check_gates.dart --phase PHASE-04`

Expected:
- Bootstrap may close once its own artifacts exist
- later phases remain open until code/verification evidence is present

- [ ] **Step 3: Write Phase 4 verification + summary artifacts**

Document the hardened templates/automation and current gate-check outcomes in:
- `.planning/phases/PHASE-04/PHASE-04-VERIFICATION.md`
- `.planning/phases/PHASE-04/PHASE-04-SUMMARY.md`

- [ ] **Step 4: Commit**

```bash
git add .planning
git commit -m "docs: seed phased scorecards and gate data"
```

### Task `PHASE-04-PLAN-02-T01`: Run the end-to-end verification pack and record validated scores

**Files:**
- Modify: `.planning/SCORECARD.md`
- Modify: `.planning/STATE.md`
- Modify: `.planning/phases/PHASE-00/PHASE-00-VERIFICATION.md`
- Modify: `.planning/phases/PHASE-01/PHASE-01-VERIFICATION.md`
- Modify: `.planning/phases/PHASE-02/PHASE-02-VERIFICATION.md`
- Modify: `.planning/phases/PHASE-03/PHASE-03-VERIFICATION.md`
- Modify: `.planning/phases/PHASE-04/PHASE-04-VERIFICATION.md`

- [ ] **Step 1: Run the focused product verification suite**

Run, at minimum:

```bash
flutter test test/task_repository_impl_test.dart
flutter test test/task_bloc_test.dart
flutter test test/auth_bloc_test.dart
flutter test test/calendar_bloc_test.dart
flutter test test/sync_status_badge_test.dart
flutter test test/init_dependencies_test.dart
flutter test test/auth_datasource_test.dart
flutter analyze lib/app/app.dart lib/core/error/exceptions.dart lib/data/datasources/google/google_calendar_datasource.dart lib/data/repositories/task_repository_impl.dart lib/presentation/blocs/auth/auth_bloc.dart lib/presentation/blocs/calendar/calendar_bloc.dart lib/presentation/blocs/task/task_bloc.dart lib/presentation/screens/home/home_screen.dart lib/presentation/screens/calendar/calendar_screen.dart lib/presentation/widgets/connection_indicator.dart lib/presentation/widgets/sync_status_badge.dart
dart run tool/planning/check_gates.dart --phase PHASE-00
dart run tool/planning/check_gates.dart --phase PHASE-01
dart run tool/planning/check_gates.dart --phase PHASE-02
dart run tool/planning/check_gates.dart --phase PHASE-03
dart run tool/planning/check_gates.dart --phase PHASE-04
```

- [ ] **Step 2: Record validation factors from evidence, not opinion**

For each task:
- use `1.0` only if all required verification commands pass and no `critical`/`major` issue remains
- use `0.7` only if verification passes but only `minor`/`note` issues remain
- use `0.4` only if implementation exists but required verification is incomplete
- use `0.0` if blocked, failed, reverted, or contradicted

- [ ] **Step 3: Update `STATE.md` with real next actions**

If PHASE-01 to PHASE-03 do not all close, record the exact blockers and the next task IDs to claim. Do not leave the file narrative-only.

- [ ] **Step 4: Commit**

```bash
git add .planning
git commit -m "docs: record validated scores and phase verification"
```

---

## Execution Notes

- Start with **Chunk 1**. Do not start sync product work before Bootstrap Phase 0 exists and validates.
- Use `@docs/superpowers/specs/2026-03-28-agentic-phase-points-design.md` as the governing spec during execution.
- Use `@superpowers:test-driven-development` for each behavior change.
- Use `@superpowers:verification-before-completion` before closing each chunk.
- Use `@superpowers:dispatching-parallel-agents` only for tasks with exclusive file ownership.
- After each chunk, request an internal code review before moving to the next chunk.

Plan complete and saved to `docs/superpowers/plans/2026-03-28-agentic-phase-points-implementation.md`. Ready to execute?
