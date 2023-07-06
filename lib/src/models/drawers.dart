import 'dart:ui';

import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';

final class WeekDrawer {
  WeekDrawer(this.lines);

  List<EventsLineDrawer> lines;
}

final class EventsLineDrawer {
  List<EventProperties> events = []; // max 7
}

/// Event widget properties used in [EventBuilder].
final class EventProperties {
  EventProperties({
    required this.begin,
    required this.end,
    required this.name,
    required this.backgroundColor,
  });

  /// Begin day number.
  int begin; // min 1 / max 7
  /// End day number.
  int end; // min 1 / max 7
  /// Background color.
  Color backgroundColor;

  /// Name displayed at start of the event widget.
  String name;

  int size() => end - begin + 1;
}
