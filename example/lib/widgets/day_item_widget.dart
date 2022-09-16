import 'package:cr_calendar/cr_calendar.dart';
import 'package:cr_calendar_example/res/colors.dart';
import 'package:flutter/material.dart';

/// Widget of day item cell for calendar
class DayItemWidget extends StatelessWidget {
  const DayItemWidget({
    required this.properties,
    super.key,
  });

  final DayItemProperties properties;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: violet.withOpacity(0.3), width: 0.3)),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 4),
            alignment: Alignment.topCenter,
            child: Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                color: properties.isCurrentDay ? violet : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${properties.dayNumber}',
                    style: TextStyle(
                        color: properties.isCurrentDay
                            ? Colors.white
                            : violet
                                .withOpacity(properties.isInMonth ? 1 : 0.5))),
              ),
            ),
          ),
          if (properties.notFittedEventsCount > 0)
            Container(
              padding: const EdgeInsets.only(right: 2, top: 2),
              alignment: Alignment.topRight,
              child: Text('+${properties.notFittedEventsCount}',
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          violet.withOpacity(properties.isInMonth ? 1 : 0.5))),
            ),
        ],
      ),
    );
  }
}
