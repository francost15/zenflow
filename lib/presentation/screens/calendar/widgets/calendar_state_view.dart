import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/calendar/calendar.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/screens/calendar/widgets/event_card.dart';
import 'package:app/presentation/screens/calendar/widgets/event_detail_sheet.dart';
import 'package:app/presentation/screens/calendar/widgets/google_sign_in_button_widget.dart';
import 'package:app/presentation/widgets/dialogs/create_task_dialog.dart';
import 'package:app/presentation/widgets/dialogs/task_checkin_sheet.dart'; // We'll create this file next
import 'package:app/presentation/widgets/empty_state.dart';
import 'package:app/presentation/widgets/error_state.dart';
import 'package:app/presentation/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarStateView extends StatelessWidget {
  const CalendarStateView({
    super.key,
    required this.selectedDate,
    required this.onRetry,
    required this.onStartZenMode,
  });

  final DateTime selectedDate;
  final VoidCallback onRetry;
  final void Function(String taskName)? onStartZenMode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        if (state is CalendarNeedsSignIn) {
          return const _SignInState();
        }

        if (state is CalendarLoading) {
          return const LoadingIndicator();
        }

        if (state is CalendarError) {
          return ErrorState(
            title: 'Ups, algo salió mal',
            message: state.message,
            onRetry: onRetry,
          );
        }

        if (state is! CalendarLoaded) {
          return const SizedBox.shrink();
        }

        final eventsForSelectedDate = _eventsForSelectedDate(
          selectedDate,
          state.events,
        );
        if (eventsForSelectedDate.isEmpty) {
          return const EmptyState(
            title: 'Día despejado',
            message: 'No tienes eventos para hoy.',
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: eventsForSelectedDate.length,
          itemBuilder: (context, index) {
            return EventCard(
              event: eventsForSelectedDate[index],
              onTap: () => _handleEventTap(
                context,
                eventsForSelectedDate[index],
                onStartZenMode,
              ),
              onStartZenMode: onStartZenMode,
              onDelete: (eventId) async {
                final taskRepo = context.read<TaskRepository>();
                final task = await taskRepo.getTaskByCalendarEventId(eventId);
                if (task != null && context.mounted) {
                  context.read<TaskBloc>().add(TaskDeleted(task));
                }
              },
            );
          },
        );
      },
    );
  }

  List<dynamic> _eventsForSelectedDate(
    DateTime selectedDate,
    List<dynamic> events,
  ) {
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final eventsByDate = <DateTime, List<dynamic>>{};
    for (final event in events) {
      final start = event.start?.dateTime ?? event.start?.date;
      if (start == null) {
        continue;
      }

      final eventDate = DateTime(start.year, start.month, start.day);
      eventsByDate[eventDate] = [...(eventsByDate[eventDate] ?? []), event];
    }

    return eventsByDate[normalizedDate] ?? const [];
  }

  Future<void> _handleEventTap(
    BuildContext context,
    dynamic event,
    void Function(String)? onStartZenMode,
  ) async {
    final eventId = event.id;
    if (eventId == null) return;

    final taskRepo = context.read<TaskRepository>();
    final task = await taskRepo.getTaskByCalendarEventId(eventId);

    if (!context.mounted) return;

    if (task == null) {
      showEventDetailSheet(
        context,
        event: event,
        onStartZenMode: onStartZenMode != null
            ? () => onStartZenMode(event.summary ?? 'Tarea')
            : null,
      );
      return;
    }

    final now = DateTime.now();
    final isPast = task.dueDate.isBefore(DateTime(now.year, now.month, now.day));

    if (isPast && task.status != TaskStatus.completed) {
      TaskCheckInSheet.show(context, task: task);
    } else {
      TaskEditorSheet.show(context, initialTask: task);
    }
  }
}

class _SignInState extends StatelessWidget {
  const _SignInState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 40,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Conecta tu Calendario',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Sincroniza tus eventos de Google para organizar tu día.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const GoogleSignInButtonWidget(),
          ],
        ),
      ),
    );
  }
}
