import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/di/injection.dart';
import 'package:app/core/utils/connectivity_service.dart';
import 'package:app/domain/entities/task_sync_snapshot.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/auth/auth_bloc.dart';
import 'package:app/presentation/blocs/auth/auth_state.dart';
import 'package:app/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:app/presentation/blocs/calendar/calendar_state.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SyncStatus { connected, reconnect, offline, error, syncing }

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key, required this.status, this.customMessage});

  final SyncStatus status;
  final String? customMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(status), size: 14, color: _colorFor(status)),
          const SizedBox(width: 6),
          Text(
            customMessage ?? _textFor(status),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: _colorFor(status),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(SyncStatus status) {
    return switch (status) {
      SyncStatus.connected => Icons.check_circle_rounded,
      SyncStatus.reconnect => Icons.sync_rounded,
      SyncStatus.offline => Icons.cloud_off_rounded,
      SyncStatus.error => Icons.error_rounded,
      SyncStatus.syncing => Icons.sync_rounded,
    };
  }

  Color _colorFor(SyncStatus status) {
    return switch (status) {
      SyncStatus.connected => AppColors.success,
      SyncStatus.reconnect => AppColors.warning,
      SyncStatus.offline => AppColors.warning,
      SyncStatus.error => AppColors.error,
      SyncStatus.syncing => AppColors.accent,
    };
  }

  String _textFor(SyncStatus status) {
    return switch (status) {
      SyncStatus.connected => 'CONECTADO',
      SyncStatus.reconnect => 'RECONECTAR',
      SyncStatus.offline => 'SIN CONEXIÓN',
      SyncStatus.error => 'ERROR',
      SyncStatus.syncing => 'SINCRONIZANDO',
    };
  }
}

class SyncStatusBadgeWithLogic extends StatelessWidget {
  const SyncStatusBadgeWithLogic({super.key, this.onSyncTap});

  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, child) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, calendarState) {
                return BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, taskState) {
                    return FutureBuilder<TaskSyncSnapshot>(
                      future: getIt<TaskRepository>().getTaskSyncSnapshot(),
                      builder: (context, snapshot) {
                        final syncSnapshot =
                            snapshot.data ?? const TaskSyncSnapshot();
                        final status = _determineStatus(
                          authState,
                          calendarState,
                          syncSnapshot,
                        );
                        return GestureDetector(
                          onTap: onSyncTap,
                          child: SyncStatusBadge(
                            status: status,
                            customMessage: _badgeText(status, syncSnapshot),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  SyncStatus _determineStatus(
    AuthState authState,
    CalendarState calendarState,
    TaskSyncSnapshot syncSnapshot,
  ) {
    if (!ConnectivityService.instance.isOnline) {
      return SyncStatus.offline;
    }
    if (authState is AuthError || calendarState is CalendarError) {
      return SyncStatus.error;
    }
    if (syncSnapshot.hasFailures) {
      return SyncStatus.error;
    }
    if (syncSnapshot.hasPendingWork) {
      return SyncStatus.syncing;
    }
    if (calendarState is CalendarNeedsSignIn) {
      return SyncStatus.reconnect;
    }
    if (authState is AuthAuthenticated && authState.calendarLinked) {
      return SyncStatus.connected;
    }
    if (authState is AuthAuthenticated && !authState.calendarLinked) {
      return SyncStatus.reconnect;
    }
    return SyncStatus.reconnect;
  }

  String? _badgeText(SyncStatus status, TaskSyncSnapshot syncSnapshot) {
    return switch (status) {
      SyncStatus.syncing => 'SYNC ${syncSnapshot.pendingCount}',
      SyncStatus.error when syncSnapshot.hasFailures =>
        'FALLO ${syncSnapshot.failedCount}',
      _ => null,
    };
  }
}
