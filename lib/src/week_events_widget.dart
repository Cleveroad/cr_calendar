import 'package:cr_calendar/src/contract.dart';
import 'package:cr_calendar/src/customization/builders.dart';
import 'package:cr_calendar/src/models/drawers.dart';
import 'package:flutter/material.dart';

class WeekEventsWidget extends StatelessWidget {
  WeekEventsWidget({
    required this.itemHeight,
    required this.itemWidth,
    required this.eventLines,
    required this.lineHeight,
    this.topPadding = 0,
    this.row = 0,
    this.eventBuilder,
    EdgeInsets? padding,
    super.key,
  }) {
    this.padding = padding ?? EdgeInsets.zero;
  }

  final double lineHeight;
  final double itemHeight;
  final double itemWidth;
  final double topPadding;
  final int row;
  final List<EventsLineDrawer> eventLines;
  late final EdgeInsets padding;
  final EventBuilder? eventBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topPadding),
      height: itemHeight - topPadding,
      child: Stack(
        children: _makePositionedEvents(),
      ),
    );
  }

  ///Draw events
  List<Widget> _makePositionedEvents() {
    final widgets = <Widget>[];
    for (var i = 0; i < eventLines.length; i++) {
      for (var j = 0; j < eventLines[i].events.length; j++) {
        final item = eventLines[i].events[j];
        widgets.add(
          Positioned(
            top: i * lineHeight,
            left: (item.begin - 1) * itemWidth + padding.left,
            right: (Contract.kWeekDaysCount - item.end) * itemWidth +
                padding.right,
            child: Container(
              height:
                  lineHeight - itemHeight / Contract.kDistanceBetweenEventsCoef,
              width: itemWidth * item.size() - Contract.kLinesPadding,
              child: eventBuilder != null
                  ? eventBuilder?.call(item)
                  : Container(
                      color: item.backgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}
