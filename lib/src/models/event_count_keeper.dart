/// Keeps non-fitted event count for week
final class NotFittedWeekEventCount {
  NotFittedWeekEventCount(this.eventCount);

  List<int> eventCount;
}

/// Keeps non-fitted event count for month page
final class NotFittedPageEventCount {
  List<NotFittedWeekEventCount> weeks = [];
}
