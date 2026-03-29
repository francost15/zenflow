import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/calendar/calendar.dart';
import 'package:app/presentation/screens/calendar/widgets/event_card.dart';
import 'package:app/presentation/screens/calendar/widgets/google_sign_in_button_widget.dart';
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
              onStartZenMode: onStartZenMode,
            );
          },
        );
      },
    );
  }

  List<dynamic> _eventsForSelectedDate(DateTime selectedDate, List<dynamic> events) {
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
