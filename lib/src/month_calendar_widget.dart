import 'dart:core';

import 'package:cr_calendar/src/contract.dart';
import 'package:cr_calendar/src/extensions/datetime_ext.dart';
import 'package:cr_calendar/src/models/event_count_keeper.dart';
import 'package:cr_calendar/src/utils/event_utils.dart';
import 'package:cr_calendar/src/widgets/day_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../cr_calendar.dart';
import '../src/internal/pair.dart';

/// Calendar days grid
class MonthCalendarWidget extends StatefulWidget {
  const MonthCalendarWidget({
    required this.overflowedEvents,
    required this.weekCount,
    required this.begin,
    required this.end,
    required this.beginOffset,
    required this.daysInMonth,
    required this.itemWidth,
    required this.itemHeight,
    required this.controller,
    required this.onDaySelected,
    required this.onRangeSelected,
    required this.touchMode,
    required this.weeksToShow,
    this.currentDay,
    this.dayItemBuilder,
    this.onDayTap,
    super.key,
  });

  final DayItemBuilder? dayItemBuilder;
  final int? currentDay;
  final NotFittedPageEventCount overflowedEvents;
  final int weekCount;
  final Jiffy begin;
  final Jiffy end;
  final int beginOffset;
  final int daysInMonth;
  final double itemWidth;
  final double itemHeight;
  final CrCalendarController controller;
  final Function(Jiffy)? onDayTap;
  final Function(List<CalendarEventModel>, Jiffy)? onDaySelected;
  final Function(List<CalendarEventModel>)? onRangeSelected;
  final TouchMode touchMode;
  final List<int> weeksToShow;

  @override
  MonthCalendarWidgetState createState() => MonthCalendarWidgetState();
}

class MonthCalendarWidgetState extends State<MonthCalendarWidget> {
  Pair<int, int>? _selectedRangeIndices;

  CrCalendarController get _controller => widget.controller;

  @override
  void initState() {
    _controller.addListener(rebuild);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _resolveRangeCoordinates();
    return Column(children: _buildWeeks());
  }

  void rebuild() {
    _selectedRangeIndices = null;
    setState(() {});
  }

  void _resolveRangeCoordinates() {
    final beginRange = _controller.selectedRange.begin;
    final endRange = _controller.selectedRange.end;

    if (beginRange == null ||
        endRange == null ||
        widget.begin.isAfter(endRange.toJiffy()) ||
        widget.end.isBefore(beginRange.toJiffy())) {
      return;
    }

    final beginDiff = beginRange.difference(widget.begin.dateTime).inDays;
    final endDiff = endRange.difference(widget.begin.dateTime).inDays;
    _selectedRangeIndices = Pair(beginDiff, endDiff);
  }

  bool _isDateInRange(int index) {
    final indices = _selectedRangeIndices;
    if (indices != null) {
      return index >= indices.first && index <= indices.second;
    }
    return false;
  }

  bool _isDateFirstRange(int index) => index == _selectedRangeIndices?.first;

  bool _isDateLastRange(int index) => index == _selectedRangeIndices?.second;

  /// Checks if day is selected
  bool _isSelectedDate(int index) {
    final selectedDay = _controller.selectedDate?.toJiffy();
    if (selectedDay != null) {
      if (selectedDay.isSameOrAfter(widget.begin) &&
          selectedDay.isSameOrBefore(widget.end)) {
        if (Jiffy.parseFromJiffy(widget.begin)
            .add(days: index)
            .isSame(selectedDay)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns pair of day date and flag is current month contains this day
  Pair<int, bool> _getDisplayDay(int index) {
    final consideringPrevMonth = widget.begin.date + index;
    if (consideringPrevMonth <= widget.begin.daysInMonth &&
        widget.begin.date != 1) {
      return Pair(consideringPrevMonth, false);
    }
    final commonDay = index - widget.beginOffset + 1;
    if (commonDay <= widget.daysInMonth) {
      return Pair(commonDay, true);
    }
    return Pair(commonDay - widget.daysInMonth, false);
  }

  /// Build weeks
  List<Widget> _buildWeeks() {
    final weeks = List.generate(
      widget.weekCount,
      (index) => Container(
        height: widget.itemHeight,
        child: Row(
          children: _buildDays(widget.weeksToShow[index], index),
        ),
      ),
    );

    return weeks;
  }

  /// Build days in week
  List<Widget> _buildDays(int week, int row) {
    final days = List.generate(Contract.kWeekDaysCount, (i) {
      final index = week * Contract.kWeekDaysCount + i;
      final day = _getDisplayDay(index);
      final column = index % Contract.kWeekDaysCount;
      final tappedDate = Jiffy.parseFromJiffy(widget.begin).add(days: index);

      return GestureDetector(
        onTap: () {
          widget.onDayTap?.call(tappedDate);
          if (widget.touchMode == TouchMode.singleTap) {
            _performDaySelecting(tappedDate);
          } else if (widget.touchMode == TouchMode.rangeSelection) {
            _calculateRange(tappedDate.dateTime);
            rebuild();
          }
        },
        child: DayItemWidget(
          width: widget.itemWidth,
          body: widget.dayItemBuilder != null
              ? widget.dayItemBuilder?.call(
                  DayItemProperties(
                    dayNumber: day.first,
                    isInMonth: day.second,
                    isCurrentDay: day.first == widget.currentDay && day.second,
                    notFittedEventsCount:
                        widget.overflowedEvents.weeks[row].eventCount[column],
                    isSelected: _isSelectedDate(index),
                    isInRange: _isDateInRange(index),
                    isFirstInRange: _isDateFirstRange(index),
                    isLastInRange: _isDateLastRange(index),
                    date: tappedDate.dateTime,
                  ),
                )
              : DayItem(
                  isCurrentDay: day.first == widget.currentDay && day.second,
                  day: day.first,
                  isWithinMonth: day.second,
                  isWithinRange: _isDateInRange(index),
                  isSelectedDay: _isSelectedDate(index),
                  nonFitEventCount:
                      widget.overflowedEvents.weeks[row].eventCount[column],
                ),
        ),
      );
    });
    return days;
  }

  void _performDaySelecting(Jiffy jiffyDay) {
    final events =
        calculateAvailableEventsForDate(_controller.events ?? [], jiffyDay);

    _controller.selectedDate = jiffyDay.dateTime;
    widget.onDaySelected?.call(events, jiffyDay);

    rebuild();
  }

  void _calculateRange(DateTime tappedDay) {
    final begin = _controller.selectedRange.begin;
    final end = _controller.selectedRange.end;

    _controller.selectedDate = tappedDay;
    if (begin == null ||
        tappedDay.isBefore(begin) ||
        tappedDay.isAtSameMomentAs(begin)) {
      _controller.selectedRange
        ..begin = tappedDay
        ..end = null;
      _useOnRangeSelectedCallback();
      return;
    }
    if (end == null) {
      _controller.selectedRange.end = tappedDay;
    } else {
      _controller.selectedRange
        ..begin = tappedDay
        ..end = null;
    }
    _useOnRangeSelectedCallback();
  }

  void _useOnRangeSelectedCallback() {
    widget.onRangeSelected?.call(calculateAvailableEventsForRange(
      _controller.events ?? [],
      _controller.selectedRange.begin?.toJiffy(),
      _controller.selectedRange.end?.toJiffy() ??
          _controller.selectedRange.begin?.toJiffy(),
    ));
  }
}
