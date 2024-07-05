import 'package:flutter/material.dart';

final class CalendarEventModel<T> {
  CalendarEventModel({
    required this.name,
    required this.begin,
    required this.end,
    this.eventColor = Colors.green,
    this.data,
  });

  String name;
  DateTime begin;
  DateTime end;
  Color eventColor;
  T? data;
}
