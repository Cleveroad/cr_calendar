import 'package:flutter/material.dart';

class CalendarEventModel {
  CalendarEventModel({
    required this.name,
    required this.begin,
    required this.end,
    this.eventColor = Colors.green,
  });

  String name;
  DateTime begin;
  DateTime end;
  Color eventColor;
}
