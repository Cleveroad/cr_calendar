import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';

/// Builder for customization week days row at top of the calendar widget.
typedef WeekDaysBuilder = Widget Function(WeekDay day);

/// Builder for customization of days cells.
typedef DayItemBuilder = Widget Function(DayItemProperties properties);

/// Builder for customization of events. Events look like lines over calendar
/// days.
typedef EventBuilder = Widget Function(EventProperties eventDrawer);

/// Builder for [YearPickerWidget] item.
typedef YearPickerItemBuilder = Widget Function(int year, bool isSelected);

/// Builder for [CrDatePickerDialog] title over calendar widget and in control bar.
typedef DateTitleBuilder = Widget Function(DateTime date);

/// Builder for buttons used in [CrDatePickerDialog]. Call [onPress] function in
/// onPressed of your button.
typedef PickerButtonBuilder = Widget? Function(Function? onPress);

/// Callback for getting date range data from [CrDatePickerDialog].
typedef OnDateRangeSelected = void Function(
    DateTime? rangeBegin, DateTime? rangeEnd);
