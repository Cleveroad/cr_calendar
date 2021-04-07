import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Represent day in calendar
class DayItemWidget extends StatelessWidget {
  const DayItemWidget({
    this.body,
    this.dayItemMargin,
    this.width,
    Key? key,
  }) : super(key: key);

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
