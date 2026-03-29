# PHASE-03-UAT.md

## User Acceptance Testing - Task Notice Queue

### Feature: Task Sync Notice Queue

### Test Scenarios

#### TC-03-01: Back-to-back task creation with sync failures
**Steps:**
1. Create a task with calendar sync configured but unavailable
2. Immediately create another task with same calendar condition
3. Observe first snackbar appears
4. Dismiss or wait for first snackbar
5. Observe second snackbar appears

**Expected Result:** Both sync warning messages are displayed (not just the last one)

#### TC-03-02: Delete failure displays correctly
**Steps:**
1. Create a task linked to Google Calendar
2. Delete the task when calendar sync is unavailable
3. Observe snackbar message

**Expected Result:** Error-style message indicating sync failure (amber background)

#### TC-03-03: Reconcile warning surfaced once
**Steps:**
1. Sign in with Google when calendar is unavailable
2. Observe reconcile warning snackbar
3. Navigate to home screen (loads tasks)
4. Observe no additional warning snackbars

**Expected Result:** Warning is shown once and cleared after consumption

### Test Environment
- Flutter app with mock repositories
- TaskBloc with notice queue implementation

### Success Criteria
- [x] All unit tests pass
- [x] Notice queue preserves FIFO ordering
- [x] No overwriting of earlier notices
- [x] Notices cleared after being consumed once
