import 'package:cr_calendar/cr_calendar.dart';

/// Class with properties for building custom day item widget.
///
/// For making [CrCalendar] constructor more readable and smaller.
///
/// Used in [DayItemBuilder] typedef.
final class DayItemProperties {
  DayItemProperties({
    required this.dayNumber,
    required this.isInMonth,
    required this.isCurrentDay,
    required this.notFittedEventsCount,
    required this.isSelected,
    required this.isInRange,
    required this.isFirstInRange,
    required this.isLastInRange,
    required this.date,
  });

  final int dayNumber;
  final bool isInMonth;
  final bool isCurrentDay;
  final int notFittedEventsCount;
  final bool isSelected;
  final bool isInRange;
  final bool isFirstInRange;
  final bool isLastInRange;
  final DateTime date;
}
