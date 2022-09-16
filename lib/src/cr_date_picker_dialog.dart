import 'package:cr_calendar/cr_calendar.dart';
import 'package:cr_calendar/src/models/date_range.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'contract.dart';

///[adaptive] - days cells will change their height according to parent height.
///
///[scrollable] - days cells will change their height according to parent height
///as long as it is larger than the cells width. The month scrolls if there is not enough space
///
enum LandscapeDaysResizeMode {
  adaptive,
  scrollable,
}

/// Properties holder for date picker.
///
/// If you need to hide some element (e.g. picker title widget) pass SizedBox()
/// to [DateTitleBuilder].
@immutable
class DatePickerProperties {
  /// Default constructor.
  const DatePickerProperties({
    required this.onDateRangeSelected,
    this.weekDaysBuilder,
    this.backgroundColor = Colors.white,
    this.initialPickerDate,
    this.padding = const EdgeInsets.all(8),
    this.dayItemBuilder,
    this.pickerMode,
    this.pickerTitleBuilder,
    this.pickerTitleAlignInLandscape = Alignment.centerLeft,
    this.backButton,
    this.forwardButton,
    this.controlBarTitleBuilder,
    this.showControlBar = true,
    this.yearPickerItemBuilder,
    this.okButtonBuilder,
    this.cancelButtonBuilder,
    this.minDate,
    this.maxDate,
    this.forceSixWeek = false,
    this.firstWeekDay = WeekDay.sunday,
    this.landscapeDaysResizeMode = LandscapeDaysResizeMode.adaptive,
  });

  /// Background color for date picker dialog and year selection widget.
  final Color backgroundColor;

  /// Initial date to be opened on dialog creation.
  final DateTime? initialPickerDate;

  /// The minimum date until which the calendar can scroll.
  final DateTime? minDate;

  /// The maximum date until which the calendar can scroll.
  final DateTime? maxDate;

  /// Picker dialog padding.
  final EdgeInsets padding;

  /// Builder for day item in dialog.
  final DayItemBuilder? dayItemBuilder;

  /// Picker selection mode.
  final TouchMode? pickerMode;

  /// Builder for row of days over month view.
  final WeekDaysBuilder? weekDaysBuilder;

  /// Title builder for widget on top of picker dialog.
  final DateTitleBuilder? pickerTitleBuilder;

  /// [Alignment] of picker title in landscape mode.
  final Alignment pickerTitleAlignInLandscape;

  /// Back button for picker control bar.
  final Widget? backButton;

  /// Forward button for picker control bar.
  final Widget? forwardButton;

  /// Builder for control bar title showed between [backButton]
  /// and [forwardButton].
  final DateTitleBuilder? controlBarTitleBuilder;

  /// Option for hiding control bar.
  final bool showControlBar;

  /// [YearPickerWidget] item builder.
  final YearPickerItemBuilder? yearPickerItemBuilder;

  /// Builder for confirm selection button.
  final PickerButtonBuilder? okButtonBuilder;

  /// Builder for cancel button.
  final PickerButtonBuilder? cancelButtonBuilder;

  /// Callback fired when [okButtonBuilder] button pressed.
  ///
  /// If one day was selected it will be returned in [DateRangeModel] as begin
  /// and end date.
  final OnDateRangeSelected onDateRangeSelected;

  /// Force showing six week rows in month view.
  final bool forceSixWeek;

  /// First day of date picker calendar.
  final WeekDay firstWeekDay;

  /// Days resize mode.
  final LandscapeDaysResizeMode landscapeDaysResizeMode;
}

/// To share [isDialogMode] through the calendar.
class DatePickerSettings extends InheritedWidget {
  const DatePickerSettings({
    required super.child,
    required this.landscapeDaysResizeMode,
    super.key,
  });

  final LandscapeDaysResizeMode landscapeDaysResizeMode;

  @override
  bool updateShouldNotify(DatePickerSettings oldWidget) => false;

  static DatePickerSettings? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DatePickerSettings>();
}

///  Customizable date picker dialog that uses [CrCalendar] in date pick mode.
///
/// to use call [showCrDatePicker].
class CrDatePickerDialog extends StatefulWidget {
  const CrDatePickerDialog({
    required this.pickerProperties,
    super.key,
  });

  /// Properties for customization of date picker dialog.
  final DatePickerProperties pickerProperties;

  @override
  _CrDatePickerDialogState createState() => _CrDatePickerDialogState();
}

class _CrDatePickerDialogState extends State<CrDatePickerDialog> {
  Size? _dialogSize;
  late CrCalendarController _calendarController;
  late DateTime _date;
  DateTime? _rangeBegin;
  DateTime? _rangeEnd;
  late CrCalendar _calendarWidget;

  DatePickerProperties get _properties => widget.pickerProperties;

  /// Toggle between calendar and year picker.
  bool _isCalendarMode = true;

  @override
  void initState() {
    _initPicker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _dialogSize = _calculateConstraints();

    return Dialog(
      backgroundColor: _properties.backgroundColor,
      child: OrientationBuilder(
        builder: (context, orientation) => Container(
          padding: _properties.padding,
          width: _dialogSize?.width,
          height: _dialogSize?.height,
          child: Row(
            children: [
              if (orientation == Orientation.landscape)
                Expanded(
                  child: Align(
                    alignment: _properties.pickerTitleAlignInLandscape,
                    child: _buildPickerTitle(),
                  ),
                ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Picker title
                    if (orientation == Orientation.portrait)
                      _buildPickerTitle(),

                    /// Picker control bar.
                    if (_properties.showControlBar)
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Row(
                          children: [
                            /// Control bar back button.
                            if (_isCalendarMode)
                              InkWell(
                                onTap: _calendarController.swipeToPreviousPage,
                                child: _properties.backButton ??
                                    const Padding(
                                      padding: EdgeInsets.all(8),
                                      child:
                                          Icon(Icons.arrow_back_ios_outlined),
                                    ),
                              ),

                            /// Control bar title.
                            Expanded(
                              child: InkWell(
                                onTap: _toggleYearPicker,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: _properties.controlBarTitleBuilder
                                            ?.call(_date) ??
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                DateFormat('M/yyyy')
                                                    .format(_date),
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),

                            /// Control bar forward button.
                            if (_isCalendarMode)
                              InkWell(
                                onTap: () {
                                  _calendarController.swipeToNextMonth();
                                },
                                child: _properties.forwardButton ??
                                    const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                          Icons.arrow_forward_ios_outlined),
                                    ),
                              ),
                          ],
                        ),
                      ),

                    /// Calendar range picker stack.
                    ///
                    /// If calendar control bar title pressed, will show [YearPickerWidget].
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: DatePickerSettings(
                                  landscapeDaysResizeMode:
                                      _properties.landscapeDaysResizeMode,
                                  child: _calendarWidget,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _properties.cancelButtonBuilder
                                            ?.call(_cancelButtonPressed) ??
                                        ElevatedButton(
                                          onPressed: _cancelButtonPressed,
                                          child: const Text('Cancel'),
                                        ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: _properties.okButtonBuilder?.call(
                                            _rangeBegin != null
                                                ? _okButtonPressed
                                                : null) ??
                                        ElevatedButton(
                                          onPressed: _okButtonPressed,
                                          child: const Text('OK'),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          /// Year picker showed over calendar range picker in stack.
                          if (!_isCalendarMode)
                            Container(
                              color: _properties.backgroundColor,
                              child: YearPickerWidget(
                                initialYear: _date.year,
                                minYear: _properties.minDate?.year ??
                                    Contract.kMinYear,
                                maxYear: _properties.maxDate?.year ??
                                    Contract.kMaxYear,
                                yearsPerLine: _getYearPerLineCount(),
                                onYearTap: _goToYear,
                                yearPickerItemBuilder:
                                    _properties.yearPickerItemBuilder,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTitle() => Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: _properties.pickerTitleBuilder?.call(_date) ??
            Text(
              DateFormat('MMMM yyyy').format(_date),
              style: const TextStyle(fontSize: 18),
            ),
      );

  Size _calculateConstraints() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final aspectRatio = height / width;
    if (aspectRatio <=
        Contract.kTabletAspectRatioH / Contract.kTabletAspectRatioW) {
      return Size(
        width * Contract.k80PercentMultiplier,
        height * Contract.k80PercentMultiplier,
      );
    } else {
      return Size(
        width * Contract.k80PercentMultiplier,
        height * Contract.k60PercentMultiplier,
      );
    }
  }

  void _onCalendarSwipe(int year, int month) {
    setState(() {
      _date = DateTime(year, month);
    });
  }

  void _toggleYearPicker() {
    setState(() {
      _isCalendarMode = !_isCalendarMode;
    });
  }

  void _goToYear(int year) {
    _isCalendarMode = true;
    setState(() {
      _calendarController.goToDate(DateTime(year, _date.month));
    });
  }

  void _okButtonPressed() {
    _properties.onDateRangeSelected.call(_rangeBegin, _rangeEnd ?? _rangeBegin);
    Navigator.of(context).pop();
  }

  void _cancelButtonPressed() {
    Navigator.of(context).pop();
  }

  void _initPicker() {
    _calendarController = CrCalendarController(onSwipe: _onCalendarSwipe);
    _date = _properties.initialPickerDate ?? DateTime.now();
    _calendarWidget = CrCalendar(
      firstDayOfWeek: _properties.firstWeekDay,
      initialDate: _properties.initialPickerDate ?? DateTime.now(),
      controller: _calendarController,
      dayItemBuilder: _properties.dayItemBuilder,
      touchMode: _properties.pickerMode ?? TouchMode.rangeSelection,
      weekDaysBuilder: _properties.weekDaysBuilder,
      forceSixWeek: _properties.forceSixWeek,
      minDate: _properties.minDate,
      maxDate: _properties.maxDate,
      onSwipeCallbackDebounceMs: 300,
      onRangeSelected: (events, begin, end) {
        _rangeBegin = begin;
        _rangeEnd = end;
        setState(() {});
      },
      onDayClicked: (events, day) {
        _rangeBegin = day;
        _rangeEnd = day;
        setState(() {});
      },
    );
  }

  int _getYearPerLineCount() {
    if (_properties.maxDate == null || _properties.minDate == null) {
      return Contract.kYearsInLine;
    }
    final yearInLine =
        (_properties.minDate!.year) - (_properties.maxDate!.year);
    return yearInLine == 0 ? 1 : yearInLine;
  }
}
