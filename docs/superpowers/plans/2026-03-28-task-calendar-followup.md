# Task Calendar Follow-up Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep Google Calendar in sync when tasks are created, updated, or deleted, and connect Calendar authorization during Google login.

**Architecture:** Extend the task domain model with a persisted `calendarEventId`, then let `TaskRepositoryImpl` coordinate Firestore persistence and Calendar side effects. Move login-time Calendar linking into auth orchestration so authentication succeeds even if Calendar authorization fails, and reset cached Calendar authorization on sign-out.

**Tech Stack:** Flutter, flutter_bloc, Firebase Auth, Cloud Firestore, google_sign_in, Google Calendar API, flutter_test

---

## Chunk 1: Task/Calendar Sync

### Task 1: Persist Calendar Event IDs

**Files:**
- Modify: `lib/domain/entities/task.dart`
- Modify: `lib/data/models/task_model.dart`

- [ ] Add `calendarEventId` to the task entity and Firestore model.
- [ ] Include it in serialization, deserialization, and `copyWith`.

### Task 2: Sync create/update/delete in the repository

**Files:**
- Modify: `lib/data/repositories/task_repository_impl.dart`
- Modify: `lib/domain/repositories/task_repository.dart`
- Modify: `lib/presentation/blocs/task/task_event.dart`
- Modify: `lib/presentation/blocs/task/task_bloc.dart`
- Modify: `lib/presentation/screens/home/home_screen.dart`

- [ ] Write failing tests for create/update/delete sync.
- [ ] Save created Calendar event IDs back into Firestore.
- [ ] Use the persisted event ID for update/delete sync.
- [ ] Keep Firestore as the source of truth and surface non-blocking warnings when Calendar sync fails.

## Chunk 2: Login-Time Calendar Authorization

### Task 3: Link Calendar during Google sign-in

**Files:**
- Modify: `lib/domain/repositories/calendar_repository.dart`
- Modify: `lib/data/repositories/calendar_repository_impl.dart`
- Modify: `lib/data/datasources/google/google_calendar_datasource.dart`
- Modify: `lib/presentation/blocs/auth/auth_bloc.dart`
- Modify: `lib/core/di/injection.dart`

- [ ] Write a failing auth bloc test showing Google login also triggers Calendar linking.
- [ ] Add the minimal Calendar authorization method needed for post-login linking.
- [ ] Keep login successful even if Calendar linking fails.
- [ ] Clear cached Calendar auth state on logout.

## Chunk 3: Verification

### Task 4: Regression coverage and analysis

**Files:**
- Modify: `test/task_repository_impl_test.dart`
- Create: `test/auth_bloc_test.dart`
- Modify: `test/task_bloc_test.dart`

- [ ] Run focused regression tests for task/calendar sync and login orchestration.
- [ ] Run `flutter analyze` on all touched files.
