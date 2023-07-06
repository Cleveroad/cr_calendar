import 'dart:async';

import 'package:flutter/material.dart';

final class Debounce {
  Debounce(this.milliseconds);

  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    dispose();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
