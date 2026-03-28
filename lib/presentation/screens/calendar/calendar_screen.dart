import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/calendar/calendar_bloc.dart';
import '../../blocs/calendar/calendar_event.dart';
import '../../blocs/calendar/calendar_state.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/event_card.dart';
import 'widgets/google_sign_in_button_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMMM yyyy').format(_focusedMonth),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
              _loadEvents();
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
              _loadEvents();
            },
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime.now();
                _selectedDate = DateTime.now();
              });
              _loadEvents();
            },
          ),
        ],
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          if (state is CalendarNeedsSignIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 80,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Conecta tu Google Calendar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para ver tus eventos',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const GoogleSignInButtonWidget(),
                ],
              ),
            );
          }

          if (state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
            // Group events by date
            final eventsByDate = <DateTime, List<dynamic>>{};
            for (final event in state.events) {
              final start = event.start?.dateTime ?? event.start?.date;
              if (start != null) {
                final date = DateTime(start.year, start.month, start.day);
                eventsByDate[date] = [...(eventsByDate[date] ?? []), event];
              }
            }

            // Get events for selected date
            final selectedDateEvents = eventsByDate[_selectedDate] ?? [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CalendarGrid(
                    selectedDate: _selectedDate,
                    focusedMonth: _focusedMonth,
                    events: eventsByDate,
                    onDateSelected: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                ),
                const Divider(),
                Expanded(
                  child: selectedDateEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay eventos para ${DateFormat('d MMMM').format(_selectedDate)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: selectedDateEvents.length,
                          itemBuilder: (context, index) {
                            return EventCard(event: selectedDateEvents[index]);
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
