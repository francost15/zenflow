import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/calendar/calendar_bloc.dart';
import '../../blocs/calendar/calendar_event.dart';
import '../../blocs/calendar/calendar_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/event_card.dart';
import 'widgets/google_sign_in_button_widget.dart';

class CalendarScreen extends StatefulWidget {
  final void Function(String taskName)? onStartZenMode;

  const CalendarScreen({super.key, this.onStartZenMode});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    final start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final end = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    context.read<CalendarBloc>().add(
      CalendarLoadRequested(start: start, end: end),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Agenda', style: theme.textTheme.headlineMedium),
                  const Spacer(),
                  _SyncButton(onTap: _loadEvents),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Day Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _DayStrip(
                selectedDate: _selectedDate,
                isDark: isDark,
                onDateSelected: (date) => setState(() => _selectedDate = date),
                onWeekChanged: (date) {
                  setState(() => _selectedDate = date);
                  _loadEvents();
                },
              ),
            ),
            const SizedBox(height: 8),
            // Events
            Expanded(
              child: BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  if (state is CalendarNeedsSignIn) {
                    return _NeedsSignInView(isDark: isDark);
                  }
                  if (state is CalendarLoading) {
                    return const LoadingIndicator();
                  }
                  if (state is CalendarError) {
                    return ErrorState(
                      message: state.message,
                      onRetry: _loadEvents,
                    );
                  }
                  if (state is CalendarLoaded) {
                    return _EventsView(
                      events: state.events,
                      selectedDate: _selectedDate,
                      isDark: isDark,
                      theme: theme,
                      onStartZenMode: widget.onStartZenMode,
                    );
                  }
                  return const LoadingIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SyncButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync, size: 14, color: AppColors.accentBlue),
            const SizedBox(width: 6),
            Text(
              'Sync',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedsSignInView extends StatelessWidget {
  final bool isDark;
  const _NeedsSignInView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 64,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 16),
          Text('Conecta tu Google Calendar', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Para ver tus eventos', style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          const GoogleSignInButtonWidget(),
        ],
      ),
    );
  }
}

class _EventsView extends StatelessWidget {
  final List<dynamic> events;
  final DateTime selectedDate;
  final bool isDark;
  final ThemeData theme;
  final void Function(String)? onStartZenMode;

  const _EventsView({
    required this.events,
    required this.selectedDate,
    required this.isDark,
    required this.theme,
    this.onStartZenMode,
  });

  @override
  Widget build(BuildContext context) {
    final eventsByDate = <DateTime, List<dynamic>>{};
    for (final event in events) {
      final start = event.start?.dateTime ?? event.start?.date;
      if (start != null) {
        final date = DateTime(start.year, start.month, start.day);
        eventsByDate[date] = [...(eventsByDate[date] ?? []), event];
      }
    }

    final selectedEvents =
        eventsByDate[DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        )] ??
        [];

    if (selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay eventos para ${DateFormat('d MMMM').format(selectedDate)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: EventCard(
          event: selectedEvents[index],
          onStartZenMode: onStartZenMode,
        ),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  final DateTime selectedDate;
  final bool isDark;
  final void Function(DateTime) onDateSelected;
  final void Function(DateTime) onWeekChanged;

  const _DayStrip({
    required this.selectedDate,
    required this.isDark,
    required this.onDateSelected,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          onPressed: () =>
              onWeekChanged(selectedDate.subtract(const Duration(days: 7))),
        ),
        ...List.generate(5, (index) {
          final date = monday.add(Duration(days: index));
          final isSelected =
              date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;
          final isToday = _isToday(date);

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.darkBackground)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdayLetter(date.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: isSelected
                            ? (isDark ? AppColors.darkBackground : Colors.white)
                            : (isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? (isDark ? AppColors.darkBackground : Colors.white)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          onPressed: () =>
              onWeekChanged(selectedDate.add(const Duration(days: 7))),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _weekdayLetter(int weekday) {
    const letters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return letters[weekday - 1];
  }
}
