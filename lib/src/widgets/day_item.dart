import 'package:flutter/material.dart';

///Represent calendar day body
class DayItem extends StatelessWidget {
  const DayItem({
    required this.isSelectedDay,
    required this.isCurrentDay,
    this.child,
    this.day = 0,
    this.isWithinMonth = true,
    this.nonFitEventCount = 0,
    this.isWithinRange = false,
    super.key,
  });

  final Widget? child;
  final int day;
  final bool isWithinMonth;
  final bool isCurrentDay;
  final bool isSelectedDay;
  final bool isWithinRange;
  final int nonFitEventCount;

  @override
  Widget build(BuildContext context) {
    return child ??
        Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black12),
            color: isSelectedDay || isWithinRange ? Colors.black12 : null,
          ),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    width: double.infinity,
                    decoration: isCurrentDay
                        ? const BoxDecoration(color: Colors.black38)
                        : null,
                    child: Text(
                      day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _getTextColor(context)),
                    ),
                  ),
                  _buildEventCount()
                ],
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        );
  }

  ///Builds not fitted event count
  Widget _buildEventCount() {
    if (nonFitEventCount > 0) {
      return Container(
        alignment: Alignment.centerRight,
        width: double.infinity,
        child: Text(
          '+$nonFitEventCount',
          maxLines: 1,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: isCurrentDay ? Colors.white : Colors.green,
            fontSize: 12,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Color? _getTextColor(BuildContext context) {
    if (isCurrentDay) {
      return Colors.white;
    } else {
      return isWithinMonth
          ? Theme.of(context).textTheme.caption?.color
          : Theme.of(context).textTheme.caption?.color?.withOpacity(0.75);
    }
  }
}
