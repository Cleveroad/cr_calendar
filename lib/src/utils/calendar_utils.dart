import 'package:cr_calendar/src/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../../cr_calendar.dart';

/// Returns date for [dayOfWeek] and for [row] in which it take place
Jiffy mapWeekDayAndRowToDate(Jiffy beginRange, int dayOfWeek, int row) {
  final begin = Jiffy(beginRange)..add(days: dayOfWeek - 1, weeks: row);
  return begin;
}

/// Sort days enum based on first day in week passed to [CrCalendar].
List<WeekDays> sortWeekdays(WeekDays fistDayInWeek) {
  if (fistDayInWeek == WeekDays.sunday) {
    return WeekDays.values;
  } else {
    const days = WeekDays.values;
    final index = fistDayInWeek.index;
    final sorted = days.sublist(index)..addAll(days.sublist(0, index));
    return sorted;
  }
}

/// Show customised date picker dialog.
Future showCrDatePicker(
  BuildContext context, {
  required DatePickerProperties properties,
}) =>
    showDialog(
      context: context,
      builder: (context) => CrDatePickerDialog(
        pickerProperties: properties,
      ),
    );
