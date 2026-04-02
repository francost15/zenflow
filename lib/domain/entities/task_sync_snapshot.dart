import 'package:equatable/equatable.dart';

class TaskSyncSnapshot extends Equatable {
  const TaskSyncSnapshot({
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastError,
    this.lastAttemptAt,
  });

  final int pendingCount;
  final int failedCount;
  final String? lastError;
  final DateTime? lastAttemptAt;

  bool get hasPendingWork => pendingCount > 0;
  bool get hasFailures => failedCount > 0;

  @override
  List<Object?> get props => [
    pendingCount,
    failedCount,
    lastError,
    lastAttemptAt,
  ];
}
