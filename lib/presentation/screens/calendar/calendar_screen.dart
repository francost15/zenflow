import 'package:app/presentation/blocs/calendar/calendar.dart';
import 'package:app/presentation/screens/calendar/widgets/calendar_grid.dart';
import 'package:app/presentation/screens/calendar/widgets/calendar_state_view.dart';
import 'package:app/presentation/screens/calendar/widgets/calendar_week_strip.dart';
import 'package:app/presentation/screens/calendar/widgets/quick_date_chips.dart';
import 'package:app/presentation/screens/calendar/widgets/view_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.onStartZenMode});

  final void Function(String taskName)? onStartZenMode;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _focusedWeekStart;
  bool _isMonthlyView = false;

  @override
  void initState() {
    super.initState();
    _focusedWeekStart = _startOfSelectedWeek(_selectedDate);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalendarHeader(
              focusedWeekStart: _focusedWeekStart,
              onMoveWeek: _moveWeek,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CalendarViewToggle(
                isMonthly: _isMonthlyView,
                onChanged: (isMonthly) {
                  setState(() => _isMonthlyView = isMonthly);
                },
              ),
            ),
            const SizedBox(height: 12),
            QuickDateChips(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                  _focusedWeekStart = _startOfSelectedWeek(date);
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isMonthlyView ? _buildMonthlyView() : _buildWeeklyView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CalendarWeekStrip(
            focusedWeekStart: _focusedWeekStart,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: CalendarStateView(
            selectedDate: _selectedDate,
            onRetry: _loadEvents,
            onStartZenMode: widget.onStartZenMode,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, state) {
                final eventsMap = <DateTime, List<dynamic>>{};
                if (state is CalendarLoaded) {
                  for (final event in state.events) {
                    final start = event.start?.dateTime ?? event.start?.date;
                    if (start != null) {
                      final key = DateTime(start.year, start.month, start.day);
                      eventsMap.putIfAbsent(key, () => []).add(event);
                    }
                  }
                }
                return CalendarGrid(
                  selectedDate: _selectedDate,
                  focusedMonth: _focusedWeekStart,
                  events: eventsMap,
                  onDateSelected: (date) {
                    setState(() => _selectedDate = date);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: CalendarStateView(
              selectedDate: _selectedDate,
              onRetry: _loadEvents,
              onStartZenMode: widget.onStartZenMode,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _startOfSelectedWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }

  void _loadEvents() {
    final start = DateTime(_focusedWeekStart.year, _focusedWeekStart.month, 1);
    final end = DateTime(
      _focusedWeekStart.year,
      _focusedWeekStart.month + 1,
      0,
    );
    context.read<CalendarBloc>().add(
      CalendarLoadRequested(start: start, end: end),
    );
  }

  void _moveWeek(int weeks) {
    setState(() {
      _focusedWeekStart = _focusedWeekStart.add(Duration(days: weeks * 7));
    });
    _loadEvents();
  }
}
