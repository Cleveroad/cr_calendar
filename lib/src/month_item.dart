import 'package:cr_calendar/cr_calendar.dart';
import 'package:cr_calendar/src/contract.dart';
import 'package:cr_calendar/src/events_overlay.dart';
import 'package:cr_calendar/src/extensions/datetime_ext.dart';
import 'package:cr_calendar/src/models/event_count_keeper.dart';
import 'package:cr_calendar/src/month_calendar_widget.dart';
import 'package:cr_calendar/src/utils/event_utils.dart';
import 'package:cr_calendar/src/widgets/default_weekday_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import 'cr_date_picker_dialog.dart';

/// Calendar page
class MonthItem extends StatefulWidget {
  const MonthItem({
    required this.controller,
    required this.displayMonth,
    required this.maxEventLines,
    this.weekDaysBuilder,
    this.currentDay,
    this.onDaySelected,
    this.dayItemBuilder,
    this.forceSixWeek = false,
    this.eventBuilder,
    this.onRangeSelected,
    this.touchMode = TouchMode.singleTap,
    this.eventTopPadding = 0,
    this.onDayTap,
    this.firstWeekDay = WeekDay.sunday,
    super.key,
  });

  final int maxEventLines;
  final int? currentDay;
  final Function(List<CalendarEventModel>, Jiffy)? onDaySelected;
  final Function(List<CalendarEventModel>)? onRangeSelected;
  final Function(Jiffy)? onDayTap;
  final WeekDaysBuilder? weekDaysBuilder;
  final DayItemBuilder? dayItemBuilder;
  final bool forceSixWeek;
  final EventBuilder? eventBuilder;
  final CrCalendarController controller;
  final DateTime displayMonth;
  final double? eventTopPadding;
  final TouchMode touchMode;
  final WeekDay firstWeekDay;

  @override
  MonthItemState createState() => MonthItemState();
}

class MonthItemState extends State<MonthItem> {
  final _monthKey = GlobalKey<MonthCalendarWidgetState>();
  final _overflowedEvents = NotFittedPageEventCount();

  late int _weekCount;
  late Jiffy _beginRange;
  late Jiffy _endRange;
  late int _beginOffset;
  late int _daysInMonth;
  late List<WeekDrawer> _weeksEvents;

  @override
  void initState() {
    initEvents();
    widget.controller.addListener(_updateState);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  @override
  void didUpdateWidget(MonthItem oldWidget) {
    initEvents();
    super.didUpdateWidget(oldWidget);
  }

  void initEvents() {
    // due multiple allocations we lose some performance
    // but we must to initialize new Jiffy instance because
    // all operations under them changes self

    final display =
        DateTime.utc(widget.displayMonth.year, widget.displayMonth.month)
            .toJiffy();
    _beginOffset = (widget.firstWeekDay.index > display.day - 1)
        ? display.day - 1 + (WeekDay.values.length - widget.firstWeekDay.index)
        : display.day - 1 - widget.firstWeekDay.index;
    _daysInMonth = display.daysInMonth;
    _beginRange = Jiffy(Jiffy(display).subtract(days: _beginOffset));
    _endRange = Jiffy(Jiffy(display).add(days: _daysInMonth - 1));
    if (_endRange.day != WeekDay.sunday.index + 1) {
      _endRange.add(
          days: WeekDay.values.length -
              _endRange.day +
              widget.firstWeekDay.index);
    }

    _weeksEvents = _calculateWeeks();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _getDaysOfWeek(),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraint) {
              final size = _getConstrainedSize(constraint);
              final itemWidth = size.width;
              final itemHeight = size.height;

              return SingleChildScrollView(
                physics: itemWidth == itemHeight
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: Container(
                  height: itemHeight * _weekCount,
                  child: ValueListenableBuilder(
                    builder: (context, value, _) {
                      return widget.controller.isShowingEvents.value
                          ? _getMonthCalendarWidget(itemWidth, itemHeight)
                          : Stack(
                              children: <Widget>[
                                _getMonthCalendarWidget(
                                  itemWidth,
                                  itemHeight,
                                ),
                                IgnorePointer(
                                  child: EventsOverlay(
                                    eventBuilder: widget.eventBuilder,
                                    maxLines: widget.maxEventLines,
                                    topPadding: widget.eventTopPadding ??
                                        (itemHeight /
                                            Contract.kDayItemTopPaddingCoef),
                                    itemWidth: itemWidth,
                                    itemHeight: itemHeight,
                                    begin: _beginRange,
                                    weekList: _weeksEvents,
                                  ),
                                ),
                              ],
                            );
                    },
                    valueListenable: widget.controller.isShowingEvents,
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  void _updateState() => setState(() {});

  Size _getConstrainedSize(BoxConstraints constraint) {
    final itemWidth = constraint.maxWidth / WeekDay.values.length;
    double itemHeight;
    if ((constraint.maxHeight / Contract.kMaxWeekPerMoth) > itemWidth) {
      itemHeight = constraint.maxHeight / Contract.kMaxWeekPerMoth;
    } else {
      final isAdaptive =
          DatePickerSettings.of(context)?.landscapeDaysResizeMode ==
              LandscapeDaysResizeMode.adaptive;
      if (isAdaptive) {
        itemHeight = constraint.maxHeight / Contract.kMaxWeekPerMoth;
      } else {
        itemHeight = itemWidth;
      }
    }
    return Size(itemWidth, itemHeight);
  }

  /// Builds MonthCalendarWidget
  MonthCalendarWidget _getMonthCalendarWidget(
      double itemWidth, double itemHeight) {
    return MonthCalendarWidget(
      controller: widget.controller,
      key: _monthKey,
      itemWidth: itemWidth,
      itemHeight: itemHeight,
      currentDay: widget.currentDay,
      dayItemBuilder: widget.dayItemBuilder,
      begin: _beginRange,
      end: _endRange,
      daysInMonth: _daysInMonth,
      beginOffset: _beginOffset,
      overflowedEvents: _overflowedEvents,
      weekCount: widget.forceSixWeek ? Contract.kMaxWeekPerMoth : _weekCount,
      onDayTap: widget.onDayTap,
      onDaySelected: widget.onDaySelected,
      onRangeSelected: widget.onRangeSelected,
      touchMode: widget.touchMode,
    );
  }

  /// Returns list of week days representation
  List<Widget> _getDaysOfWeek() {
    final week = List<Widget>.generate(WeekDay.values.length, (index) {
      final sortedWeekDays = sortWeekdays(widget.firstWeekDay);
      return widget.weekDaysBuilder?.call(sortedWeekDays[index]) ??
          DefaultWeekdayWidget(day: sortedWeekDays[index]);
    });
    return week;
  }

  /// Returns list of events for current month
  List<WeekDrawer> _calculateWeeks() {
    final begin = _beginRange;
    final end = _endRange;
    _weekCount = widget.forceSixWeek
        ? Contract.kMaxWeekPerMoth
        : (end.diff(begin, Units.WEEK) + 1).toInt(); // inclusive

    final drawersForWeek = <List<EventProperties>>[];
    final weeks = List.generate(_weekCount, (index) {
      final eventDrawers = resolveEventDrawersForWeek(
          index, _beginRange, widget.controller.events ?? []);
      final placedEvents =
          placeEventsToLines(eventDrawers, widget.maxEventLines);
      drawersForWeek.add(eventDrawers);
      return WeekDrawer(placedEvents);
    });

    _overflowedEvents.weeks =
        calculateOverflowedEvents(drawersForWeek, widget.maxEventLines);

    return weeks;
  }
}
