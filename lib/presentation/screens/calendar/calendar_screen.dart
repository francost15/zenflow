import 'package:app/presentation/blocs/calendar/calendar.dart';
import 'package:app/presentation/screens/calendar/widgets/calendar_state_view.dart';
import 'package:app/presentation/screens/calendar/widgets/calendar_week_strip.dart';
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
            const SizedBox(height: 24),
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
        ),
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
      _focusedWeekStart.month + 2,
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
