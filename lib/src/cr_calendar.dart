import 'package:cr_calendar/src/contract.dart';
import 'package:cr_calendar/src/customization/builders.dart';
import 'package:cr_calendar/src/extensions/datetime_ext.dart';
import 'package:cr_calendar/src/models/calendar_event_model.dart';
import 'package:cr_calendar/src/month_item.dart';
import 'package:cr_calendar/src/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import 'models/date_range.dart';

///Week days representation.
enum WeekDay {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

/// On calendar scroll callback. Fires every time when user swipes calendar.
typedef OnSwipeCallback = Function(int year, int month);

/// On calendar's day tap callback.
///
/// * events - Events that happens on selected day,
/// * day - [DateTime] instance of selected day.
typedef OnTapCallback = Function(List<CalendarEventModel> events, DateTime day);

/// On date range selected callback
///
/// * events - Events that happens in selected range
/// * begin - [DateTime] instance of range beginning
/// * end - [DateTime] instance of range ending
typedef OnRangeSelectedCallback = Function(
    List<CalendarEventModel> events, DateTime? begin, DateTime? end);

typedef OnDateSelectCallback = Function(DateTime selectedDate);

/// Controller for [CrCalendar].
final class CrCalendarController extends ChangeNotifier {
  /// Default constructor.
  CrCalendarController({
    this.onSwipe,
    this.events,
  });

  /// All calendar event currently stored by controller.
  final List<CalendarEventModel>? events;

  /// Current opened date in calendar.
  late DateTime date;

  /// Callback for detection calendar page changed.
  OnSwipeCallback? onSwipe;

  /// Selected day in calendar.
  ///
  /// null if there is no selected day.
  DateTime? selectedDate;

  /// List of events which are in selected day or selected range.
  List<CalendarEventModel>? selectedEvents;

  /// See [DateRangeModel].
  DateRangeModel selectedRange = DateRangeModel();

  /// Current calendar view page.
  int page = Contract.kDefaultInitialPage;

  int _initialPage = Contract.kDefaultInitialPage;

  int _maxPage = Contract.kDefaultInitialPage * 2;

  PageController _controller = PageController(
      initialPage: Contract.kDefaultInitialPage, keepPage: false);

  /// Need to update PageController initial page in case calendar widget was
  /// recreated when we were on other page.
  PageController _getUpdatedPageController() {
    return _controller = PageController(initialPage: page, keepPage: false);
  }

  final _doShowEvents = ValueNotifier<bool>(false);

  /// Events visibility.
  ValueNotifier<bool> get isShowingEvents => _doShowEvents;

  /// Add list of events.
  void addEvents(List<CalendarEventModel> events) {
    events.addAll(events);
    _redrawCalendar();
  }

  /// Add one event.
  void addEvent(CalendarEventModel event) {
    events?.add(event);
    _redrawCalendar();
  }

  /// Clear selected day
  void clearSelected() {
    selectedDate = null;
    selectedRange
      ..begin = null
      ..end = null;
    _redrawCalendar();
  }

  /// Swipe to the next month page.
  void swipeToNextMonth([Duration? animationDuration, Curve? curve]) {
    final targetPage = page + 1;
    if (targetPage <= _maxPage) {
      _controller.animateToPage(
        targetPage,
        duration: animationDuration ??
            const Duration(milliseconds: Contract.kDefaultAnimationDurationMs),
        curve: curve ?? Curves.linear,
      );
    }
  }

  /// Swipe to the previous month page.
  void swipeToPreviousPage([Duration? animationDuration, Curve? curve]) {
    final targetPage = page - 1;
    if (targetPage >= 0) {
      _controller.animateToPage(
        targetPage,
        duration: animationDuration ??
            const Duration(milliseconds: Contract.kDefaultAnimationDurationMs),
        curve: curve ?? Curves.linear,
      );
    }
  }

  /// Show or hide events
  void toggleEvents() {
    _doShowEvents.value = !_doShowEvents.value;
  }

  /// Go to [dateToGoTo]
  /// [selectDate] - will date be selected
  /// [durationAnimation], [curve] - animation parameters
  void goToDate(
    DateTime dateToGoTo, {
    bool selectDate = false,
    Duration? durationAnimation,
    Curve? curve,
  }) {
    final targetDate = dateToGoTo;
    final utcDay =
        DateTime.utc(targetDate.year, targetDate.month, targetDate.day);
    final sought = DateTime(utcDay.year, utcDay.month).toJiffy();
    final offset = date.toJiffy().diff(sought, unit: Unit.month).ceil();
    if (selectDate) {
      clearSelected();
      selectedDate = utcDay;
      if (offset == 0) {
        _redrawCalendar();
      }
    }
    _controller.animateToPage(
      page - offset,
      duration: durationAnimation ??
          const Duration(milliseconds: Contract.kDefaultAnimationDurationMs),
      curve: curve ?? Curves.linear,
    );
  }

  void _redrawCalendar() {
    notifyListeners();
  }
}

/// Touch modes of [CrCalendar].
///

///
/// [rangeSelection] -
///
/// [none] - disable interaction with calendar days.
enum TouchMode {
  /// Allows to select only one day. Fires [onDayClicked] callback when day in
  /// calendar is tapped.
  singleTap,

  /// Allows to select range of days or one day. Fires [OnRangeSelectedCallback]
  /// when day in calendar is tapped.
  rangeSelection,

  /// Disables interaction with calendar days.
  none,
}

/// Stateful calendar widget.
///
/// Each month is represented by one page in [PageView].
class CrCalendar extends StatefulWidget {
  /// Default constructor.
  CrCalendar({
    required this.controller,
    required this.initialDate,
    this.weekDaysBuilder,
    this.onDayClicked,
    this.firstDayOfWeek = WeekDay.sunday,
    this.dayItemBuilder,
    this.forceSixWeek = false,
    this.maxEventLines = 4,
    this.backgroundColor,
    this.eventBuilder,
    this.touchMode = TouchMode.singleTap,
    this.eventsTopPadding = 12.0,
    this.onRangeSelected,
    this.onSwipeCallbackDebounceMs = 100,
    this.minDate,
    this.maxDate,
    this.weeksToShow,
    this.localizedWeekDaysBuilder,
    super.key,
  })  : assert(maxEventLines <= 6, 'maxEventLines should be less then 6'),
        assert(minDate == null || maxDate == null || minDate.isBefore(maxDate),
            'minDate should be before maxDate'),
        assert(weeksToShow == null || weeksToShow.isNotEmpty,
            'If provided, weeksToShow cannot be empty'),
        assert(weeksToShow == null || weeksToShow.length <= 6,
            'weeksToShow cannot contain more that 6 elements'),
        assert(
            weeksToShow == null ||
                weeksToShow.every((element) => 0 <= element && element <= 5),
            'weeksToShow can contain either 0,1,2,3,4 or 5 only.') {
    weeksToShow?.sort();
  }

  /// The minimum date until which the calendar can scroll
  final DateTime? minDate;

  /// The maximum date until which the calendar can scroll
  final DateTime? maxDate;

  /// Calendar controller.
  final CrCalendarController controller;

  /// Start day of the week. Default is [WeekDay.sunday].
  final WeekDay firstDayOfWeek;

  /// Number of events widgets to be displayed over day item cell.
  ///
  /// If day has more events than this number, [DayItemBuilder] will have
  /// notFittedEventsCount bigger than 0.
  final int maxEventLines;

  /// Initial date to be opened when calendar is created.
  final DateTime initialDate;

  /// Callback fired when calendar day is tapped in calendar
  /// with [TouchMode.singleTap] touch mode.
  final OnTapCallback? onDayClicked;

  /// See [WeekDaysBuilder].
  final WeekDaysBuilder? weekDaysBuilder;

  /// See [DayItemBuilder].
  final DayItemBuilder? dayItemBuilder;

  /// Force calendar to display sixth row in month view even if this week is
  /// not in current month.
  final bool forceSixWeek;

  /// Background color of calendar.
  final Color? backgroundColor;

  /// See [EventBuilder].
  final EventBuilder? eventBuilder;

  /// Padding over events widgets to for correction of their alignment.
  final double eventsTopPadding;

  /// Touch mode of calendar.
  ///
  /// See [TouchMode].
  final TouchMode touchMode;

  /// Callback for receiving selected range when calendar is used as date picker.
  final OnRangeSelectedCallback? onRangeSelected;

  /// Time in milliseconds for debounce [CrCalendarController] onSwipe callback.
  ///
  /// Reduces number of callbacks when [CrCalendarController] goToDate is used.
  final int onSwipeCallbackDebounceMs;

  /// List of weeks to show of a month, eg. first three weeks: 0,1,2
  /// Takes a full 6 week month as a basis, therefore week numbers must be between 0 and 6, inclusive.
  /// If [weeksToShow] is not null, [forceSixWeek] will have no effect.
  final List<int>? weeksToShow;

  /// Builder function for week day customization at the top of the calendar.
  ///
  /// When this parameter is not null, it will be called with each week days first
  /// letter as a String, eg. S for Sunday, M for Monday, etc.
  ///
  /// When this parameter is not null, the first day of the week is determined
  /// by the app's current locale, which is en_US in Flutter by default.
  ///
  /// The week day names will be translated for the current locale as well,
  /// eg. if the current locale is German, then M for Montag, D for Dienstag etc.
  ///
  /// When this parameter is not null, [firstDayOfWeek] and [weekDaysBuilder]
  /// parameters are ignored.
  final LocalizedWeekDaysBuilder? localizedWeekDaysBuilder;

  @override
  _CrCalendarState createState() => _CrCalendarState();
}

class _CrCalendarState extends State<CrCalendar> {
  late Debounce _onSwipeDebounce;

  late DateTime _initialDate;

  final _minPage = 1;

  late WeekDay _firstWeekDay;

  @override
  void initState() {
    super.initState();
    final date = widget.initialDate;
    widget.controller.date = date;
    widget.controller.addListener(_redraw);
    calculateBoundaries();
    _initialDate = date;
    _recalculateDisplayMonth(0);
    _onSwipeDebounce = Debounce(widget.onSwipeCallbackDebounceMs);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_redraw);
    _onSwipeDebounce.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final localizations = MaterialLocalizations.of(context);

    if (widget.localizedWeekDaysBuilder != null) {
      _firstWeekDay = WeekDay.values[localizations.firstDayOfWeekIndex];
    } else {
      _firstWeekDay = widget.firstDayOfWeek;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return PageView.builder(
          itemCount: _minPage + widget.controller._maxPage,
          controller: widget.controller._getUpdatedPageController(),
          itemBuilder: (context, index) {
            final offset = index - widget.controller._initialPage;
            final month = Jiffy.parseFromDateTime(_initialDate)
                .add(months: offset)
                .dateTime;
            return Container(
              color: widget.backgroundColor,
              child: MonthItem(
                eventTopPadding: widget.eventsTopPadding,
                displayMonth: month,
                controller: widget.controller,
                eventBuilder: widget.eventBuilder,
                maxEventLines: widget.maxEventLines,
                forceSixWeek: widget.forceSixWeek,
                currentDay: _returnCurrentDayForDateOrNull(month),
                touchMode: widget.touchMode,
                onDayTap: (day) {
                  _scrollOnUnboundMonth(day);
                },
                onRangeSelected: (events) {
                  final begin = widget.controller.selectedRange.begin;
                  final end = widget.controller.selectedRange.end;

                  if (widget.onRangeSelected != null &&
                      widget.touchMode == TouchMode.rangeSelection) {
                    widget.onRangeSelected?.call(events, begin, end);
                  }
                  widget.controller.selectedEvents = events;
                },
                onDaySelected: (events, day) {
                  if (widget.onDayClicked != null &&
                      widget.touchMode == TouchMode.singleTap) {
                    widget.onDayClicked?.call(events, day.dateTime);
                  }
                  widget.controller.selectedEvents = events;
                },
                weekDaysBuilder: widget.weekDaysBuilder,
                dayItemBuilder: widget.dayItemBuilder,
                weeksToShow: widget.weeksToShow,
                firstWeekDay: _firstWeekDay,
                localizedWeekDaysBuilder: widget.localizedWeekDaysBuilder,
              ),
            );
          },
          onPageChanged: _pageChanged,
        );
      },
    );
  }

  /// Calculates month to display
  void _recalculateDisplayMonth(int offset) {
    widget.controller.date =
        Jiffy.parseFromList([widget.initialDate.year, widget.initialDate.month])
            .add(months: offset)
            .dateTime;
  }

  /// Page change callback. Fires when index of month is changed.
  void _pageChanged(int page) {
    _onSwipeDebounce.run(() {
      widget.controller.page = page;
      final offset = page - widget.controller._initialPage;
      _recalculateDisplayMonth(offset);
      final date = Jiffy.parseFromList(
              [widget.initialDate.year, widget.initialDate.month])
          .add(months: offset)
          .dateTime;
      widget.controller
        ..date = date
        ..onSwipe?.call(date.year, date.month);
    });
  }

  int? _returnCurrentDayForDateOrNull(DateTime display) {
    final now = DateTime.now();
    if (display.year == now.year && display.month == now.month) {
      return now.day;
    }
    return null;
  }

  /// Scrolls to previous or next month if selected day isn't in current month
  void _scrollOnUnboundMonth(Jiffy day) {
    final month = day.month;
    final year = day.year;
    if ((month < widget.controller.date.month &&
            year == widget.controller.date.year) ||
        year < widget.controller.date.year) {
      widget.controller.swipeToPreviousPage();
    }
    if ((month > widget.controller.date.month &&
            year == widget.controller.date.year) ||
        year > widget.controller.date.year) {
      widget.controller.swipeToNextMonth();
    }
  }

  void _redraw() => setState(() {});

  void calculateBoundaries() {
    final initialMoth =
        DateTime(widget.initialDate.year, widget.initialDate.month);
    if (widget.minDate != null) {
      final minMonth = DateTime(widget.minDate!.year, widget.minDate!.month);
      widget.controller._initialPage = Jiffy.parseFromDateTime(initialMoth)
          .diff(
            minMonth.toJiffy(),
            unit: Unit.month,
          )
          .toInt();
      widget.controller.page = widget.controller._initialPage;
    }
    if (widget.maxDate != null) {
      final maxMonth = DateTime(widget.maxDate!.year, widget.maxDate!.month);
      widget.controller._maxPage = Jiffy.parseFromDateTime(initialMoth)
              .diff(
                maxMonth.toJiffy(),
                unit: Unit.month,
              )
              .toInt()
              .abs() +
          widget.controller.page;
    }
  }
}
