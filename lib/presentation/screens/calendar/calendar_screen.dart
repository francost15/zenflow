import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/calendar/calendar_bloc.dart';
import '../../blocs/calendar/calendar_event.dart';
import '../../blocs/calendar/calendar_state.dart';
import 'widgets/event_card.dart';
import 'widgets/google_sign_in_button_widget.dart';

class CalendarScreen extends StatefulWidget {
  final void Function(String taskName)? onStartZenMode;

  const CalendarScreen({super.key, this.onStartZenMode});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
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
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Agenda', style: theme.textTheme.headlineMedium),
                  const Spacer(),
                  // Sync button
                  GestureDetector(
                    onTap: _loadEvents,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Day Strip ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDayStrip(theme, isDark),
            ),
            const SizedBox(height: 8),

            // ─── Events ───
            Expanded(
              child: BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  if (state is CalendarNeedsSignIn) {
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
                          Text(
                            'Conecta tu Google Calendar',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Para ver tus eventos',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 24),
                          const GoogleSignInButtonWidget(),
                        ],
                      ),
                    );
                  }

                  if (state is CalendarLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }

                  if (state is CalendarError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadEvents,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CalendarLoaded) {
                    final eventsByDate = <DateTime, List<dynamic>>{};
                    for (final event in state.events) {
                      final start = event.start?.dateTime ?? event.start?.date;
                      if (start != null) {
                        final date = DateTime(start.year, start.month, start.day);
                        eventsByDate[date] = [
                          ...(eventsByDate[date] ?? []),
                          event,
                        ];
                      }
                    }

                    final selectedDateEvents =
                        eventsByDate[DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                        )] ??
                        [];

                    if (selectedDateEvents.isEmpty) {
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
                              'No hay eventos para ${DateFormat('d MMMM').format(_selectedDate)}',
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
                      itemCount: selectedDateEvents.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: EventCard(
                            event: selectedDateEvents[index],
                            onStartZenMode: widget.onStartZenMode,
                          ),
                        );
                      },
                    );
                  }

                  return Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayStrip(ThemeData theme, bool isDark) {
    // Show current week centered on selected day
    final monday = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Row(
      children: [
        // Previous week
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 7));
              _focusedMonth = _selectedDate;
            });
            _loadEvents();
          },
        ),
        ...List.generate(5, (index) {
          final date = monday.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final isToday = _isToday(date);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
              },
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
                            ? (isDark
                                ? AppColors.darkBackground
                                : Colors.white)
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
                            ? (isDark
                                ? AppColors.darkBackground
                                : Colors.white)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        // Next week
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 7));
              _focusedMonth = _selectedDate;
            });
            _loadEvents();
          },
        ),
      ],
    );
  }

  String _weekdayLetter(int weekday) {
    const letters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return letters[weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
