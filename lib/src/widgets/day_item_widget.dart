import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Represent day in calendar
class DayItemWidget extends StatelessWidget {
  const DayItemWidget({
    this.body,
    this.dayItemMargin,
    this.width,
    super.key,
  });

  final Widget? body;
  final EdgeInsets? dayItemMargin;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: dayItemMargin,
      child: body,
    );
  }
}
