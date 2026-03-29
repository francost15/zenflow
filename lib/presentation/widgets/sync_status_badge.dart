import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/connectivity_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/calendar/calendar_bloc.dart';
import '../blocs/calendar/calendar_state.dart';

enum SyncStatus { connected, reconnect, offline, error }

class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;
  final String? customMessage;

  const SyncStatusBadge({super.key, required this.status, this.customMessage});

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
    switch (status) {
      case SyncStatus.connected:
        return Icons.check_circle_rounded;
      case SyncStatus.reconnect:
        return Icons.sync_rounded;
      case SyncStatus.offline:
        return Icons.cloud_off_rounded;
      case SyncStatus.error:
        return Icons.error_rounded;
    }
  }

  Color _colorFor(SyncStatus status) {
    switch (status) {
      case SyncStatus.connected:
        return AppColors.success;
      case SyncStatus.reconnect:
        return AppColors.warning;
      case SyncStatus.offline:
        return AppColors.warning;
      case SyncStatus.error:
        return AppColors.error;
    }
  }

  String _textFor(SyncStatus status) {
    switch (status) {
      case SyncStatus.connected:
        return 'CONECTADO';
      case SyncStatus.reconnect:
        return 'RECONECTAR';
      case SyncStatus.offline:
        return 'SIN CONEXIÓN';
      case SyncStatus.error:
        return 'ERROR';
    }
  }
}

class SyncStatusBadgeWithLogic extends StatelessWidget {
  const SyncStatusBadgeWithLogic({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, child) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, calendarState) {
                final status = _determineStatus(authState, calendarState);
                return SyncStatusBadge(status: status);
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
  ) {
    if (!ConnectivityService.instance.isOnline) {
      return SyncStatus.offline;
    }

    if (authState is AuthError) {
      return SyncStatus.error;
    }

    if (calendarState is CalendarError) {
      return SyncStatus.error;
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
}
