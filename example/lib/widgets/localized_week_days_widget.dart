import 'package:cr_calendar/cr_calendar.dart';
import 'package:cr_calendar_example/res/colors.dart';
import 'package:flutter/material.dart';

/// Widget that represents week days in row above calendar month view.
class LocalizedWeekDaysWidget extends StatelessWidget {
  const LocalizedWeekDaysWidget({
    required this.weekDay,
    super.key,
  });

  /// [String] value from [LocalizedWeekDaysBuilder].
  final String weekDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
          width: 0.3,
        ),
      ),
      height: 40,
      child: Center(
        child: Text(
          weekDay,
          style: TextStyle(
            color: violet.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}
