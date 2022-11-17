import 'dart:ui';

import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';

class WeekDrawer<T> {
  WeekDrawer(this.lines);

  List<EventsLineDrawer<T>> lines;
}

class EventsLineDrawer<T> {
  List<EventProperties<T>> events = []; // max 7
}

/// Event widget properties used in [EventBuilder].
class EventProperties<T> {
  EventProperties(
      {required this.begin,
      required this.end,
      required this.name,
      required this.backgroundColor,
      this.id,
      this.value});

  /// Begin day number.
  int begin; // min 1 / max 7
  /// End day number.
  int end; // min 1 / max 7
  /// Background color.
  Color backgroundColor;

  /// Name displayed at start of the event widget.
  String name;

  int size() => end - begin + 1;

  T? value;
  int? id;
}
