import 'package:flutter/material.dart';

class CalendarEventModel<T> {
  CalendarEventModel({
    required this.name,
    required this.begin,
    required this.end,
    this.id,
    this.value,
    this.eventColor = Colors.green,
  });

  String name;
  DateTime begin;
  DateTime end;
  Color eventColor;
  T? value;
  int? id;
}
