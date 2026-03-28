import 'package:flutter/material.dart';

class HeatmapChart extends StatelessWidget {
  final Map<DateTime, int> data;
  final int weeksToShow;

  const HeatmapChart({super.key, required this.data, this.weeksToShow = 52});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    const colors = [
      Color(0xFFEBEDF0),
      Color(0xFF9BE9A8),
      Color(0xFF40C463),
      Color(0xFF30A14E),
      Color(0xFF216E39),
    ];

    final startDate = today.subtract(Duration(days: weeksToShow * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: _buildMonthLabels(startDate, today)),
        const SizedBox(height: 4),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildWeeks(startDate, today, colors),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Less',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(width: 4),
            for (int i = 0; i < colors.length; i++)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            const SizedBox(width: 4),
            const Text(
              'More',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildMonthLabels(DateTime start, DateTime end) {
    final labels = <Widget>[];
    var current = DateTime(start.year, start.month);

    while (current.isBefore(end)) {
      labels.add(
        Text(
          _monthAbbr(current.month),
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      );
      current = DateTime(current.year, current.month + 1);
    }

    return labels;
  }

  List<Widget> _buildWeeks(DateTime start, DateTime end, List<Color> colors) {
    final weeks = <Widget>[];
    var currentWeekStart = start;

    while (currentWeekStart.weekday != DateTime.sunday) {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 1));
    }

    while (currentWeekStart.isBefore(end) ||
        currentWeekStart.isAtSameMomentAs(end)) {
      weeks.add(
        Column(
          children: List.generate(7, (dayIndex) {
            final date = currentWeekStart.add(Duration(days: dayIndex));
            if (date.isAfter(end)) {
              return const SizedBox(width: 12, height: 12);
            }
            final intensity = _getIntensity(date);
            return Tooltip(
              message:
                  '${date.month}/${date.day}: ${_getTooltipText(intensity)}',
              child: Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: colors[intensity],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      );
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    return weeks;
  }

  int _getIntensity(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (data.containsKey(normalizedDate)) {
      return data[normalizedDate]!.clamp(0, 4);
    }
    return 0;
  }

  String _getTooltipText(int intensity) {
    switch (intensity) {
      case 0:
        return 'No activity';
      case 1:
        return '1 habit';
      case 2:
        return '2 habits';
      case 3:
        return '3 habits';
      case 4:
        return '4+ habits';
      default:
        return 'No activity';
    }
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
