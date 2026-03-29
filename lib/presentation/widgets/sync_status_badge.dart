import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/utils/connectivity_service.dart';
import 'package:app/presentation/blocs/auth/auth_state.dart';
import 'package:app/presentation/blocs/calendar/calendar_state.dart';
import 'package:flutter/material.dart';

enum SyncStatus { connected, reconnectNeeded, offline, error }

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    super.key,
    required this.authState,
    required this.calendarState,
  });

  final AuthState authState;
  final CalendarState calendarState;

  SyncStatus get status {
    if (!_isOnline) {
      return SyncStatus.offline;
    }
    if (authState is AuthError) {
      return SyncStatus.error;
    }
    if (calendarState is CalendarError) {
      return SyncStatus.error;
    }
    if (authState is AuthAuthenticated &&
        calendarState is CalendarNeedsSignIn) {
      return SyncStatus.reconnectNeeded;
    }
    if (authState is AuthAuthenticated &&
        calendarState is CalendarLoaded &&
        (authState as AuthAuthenticated).calendarLinked) {
      return SyncStatus.connected;
    }
    if (calendarState is CalendarNeedsSignIn) {
      return SyncStatus.reconnectNeeded;
    }
    return SyncStatus.error;
  }

  bool get _isOnline => ConnectivityService.instance.isOnline;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, child) {
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
              Icon(_icon, size: 14, color: _color),
              const SizedBox(width: 6),
              Text(
                _label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: _color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData get _icon {
    switch (status) {
      case SyncStatus.connected:
        return Icons.check_circle_rounded;
      case SyncStatus.reconnectNeeded:
        return Icons.sync_problem_rounded;
      case SyncStatus.offline:
        return Icons.cloud_off_rounded;
      case SyncStatus.error:
        return Icons.warning_rounded;
    }
  }

  Color get _color {
    switch (status) {
      case SyncStatus.connected:
        return AppColors.success;
      case SyncStatus.reconnectNeeded:
        return AppColors.warning;
      case SyncStatus.offline:
        return AppColors.warning;
      case SyncStatus.error:
        return AppColors.error;
    }
  }

  String get _label {
    switch (status) {
      case SyncStatus.connected:
        return 'CONECTADO';
      case SyncStatus.reconnectNeeded:
        return 'RECONECTAR';
      case SyncStatus.offline:
        return 'SIN CONEXIÓN';
      case SyncStatus.error:
        return 'ERROR';
    }
  }
}
