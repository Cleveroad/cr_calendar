import 'package:cr_calendar/src/contract.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../cr_calendar.dart';

class DefaultWeekdayWidget extends StatelessWidget {
  const DefaultWeekdayWidget({
    required this.day,
    super.key,
  });

  final WeekDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: Contract.kDefaultDayItemBorderWidth,
            color: Colors.transparent),
      ),
      height: 40,
      child: Center(
        child: Text(
          describeEnum(day).substring(0, 1).toUpperCase(),
        ),
      ),
    );
  }
}
