import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime? selectedDay;
  final DateTime? focusedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final bool enableRangeSelection;
  final ValueChanged<DateTime>? onDaySelected;
  final Function(DateTime, DateTime)? onRangeSelected;

  const CalendarWidget({
    super.key,
    this.selectedDay,
    this.focusedDay,
    this.rangeStart,
    this.rangeEnd,
    this.enableRangeSelection = false,
    this.onDaySelected,
    this.onRangeSelected,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay ?? DateTime.now();
    _selectedDay = widget.selectedDay;
    _rangeStart = widget.rangeStart;
    _rangeEnd = widget.rangeEnd;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        rangeStartDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        rangeHighlightColor: Colors.greenAccent,
        outsideDaysVisible: true,
        weekendTextStyle: TextStyle(color: Colors.red),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: const Icon(Icons.chevron_left, size: 24),
        rightChevronIcon: const Icon(Icons.chevron_right, size: 24),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        if (widget.onDaySelected != null) {
          widget.onDaySelected!(selectedDay);
        }
      },
      onRangeSelected: widget.enableRangeSelection
          ? (start, end, focusedDay) {
        setState(() {
          _rangeStart = start;
          _rangeEnd = end;
          _focusedDay = focusedDay;
        });
        if (widget.onRangeSelected != null && start != null && end != null) {
          widget.onRangeSelected!(start, end);
        }
      }
          : null,
    );
  }
}