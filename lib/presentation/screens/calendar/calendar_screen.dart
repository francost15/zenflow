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
  DateTime _selectedDate = DateTime.now();
  late DateTime _focusedWeekStart;

  @override
  void initState() {
    super.initState();
    _focusedWeekStart = _startOfSelectedWeek(_selectedDate);
    _loadEvents();
  }

  DateTime _startOfSelectedWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day).subtract(
      Duration(days: date.weekday - 1),
    );
  }

  void _loadEvents() {
    // Load events for the current month and the next to ensure smooth transitions
    final start = DateTime(_focusedWeekStart.year, _focusedWeekStart.month, 1);
    final end = DateTime(_focusedWeekStart.year, _focusedWeekStart.month + 2, 0);
    context.read<CalendarBloc>().add(
      CalendarLoadRequested(start: start, end: end),
    );
  }

  void _moveWeek(int weeks) {
    setState(() {
      _focusedWeekStart = _focusedWeekStart.add(Duration(days: weeks * 7));
    });
    // Check if we need to load more events for the new month
    _loadEvents();
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agenda',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'es_ES').format(_focusedWeekStart).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildNavButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: () => _moveWeek(-1),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildNavButton(
                    icon: Icons.chevron_right_rounded,
                    onPressed: () => _moveWeek(1),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Day Strip ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDayStrip(theme, isDark),
            ),
            const SizedBox(height: 16),

            // ─── Events List ───
            Expanded(
              child: BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  if (state is CalendarNeedsSignIn) {
                    return _buildSignInState(theme, isDark);
                  }

                  if (state is CalendarLoading) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 3),
                    );
                  }

                  if (state is CalendarError) {
                    return _buildErrorState(theme, state.message);
                  }

                  if (state is CalendarLoaded) {
                    final eventsByDate = <DateTime, List<dynamic>>{};
                    for (final event in state.events) {
                      final start = event.start?.dateTime ?? event.start?.date;
                      if (start != null) {
                        final date = DateTime(start.year, start.month, start.day);
                        eventsByDate[date] = [...(eventsByDate[date] ?? []), event];
                      }
                    }

                    final selectedDateEvents = eventsByDate[DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                        )] ??
                        [];

                    if (selectedDateEvents.isEmpty) {
                      return _buildEmptyState(theme, isDark);
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: selectedDateEvents.length,
                      itemBuilder: (context, index) {
                        return EventCard(
                          event: selectedDateEvents[index],
                          onStartZenMode: widget.onStartZenMode,
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: AppColors.accent,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildDayStrip(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated.withValues(alpha: 0.5)
            : AppColors.lightSurfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final date = _focusedWeekStart.add(Duration(days: index));
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
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkSurface : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdayLetter(date.weekday),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? AppColors.accent
                            : isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${date.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        fontSize: 16,
                      ),
                    ),
                    if (isToday && !isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSignInState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 40,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Conecta tu Calendario',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Sincroniza tus eventos de Google para organizar tu día.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Día despejado',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No tienes eventos para hoy.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ups, algo salió mal', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: _loadEvents, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  String _weekdayLetter(int weekday) {
    const letters = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return letters[weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
