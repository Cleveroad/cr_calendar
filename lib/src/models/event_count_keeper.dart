/// Keeps non-fitted event count for week
class NotFittedWeekEventCount {
  NotFittedWeekEventCount(this.eventCount);

  List<int> eventCount;
}

/// Keeps non-fitted event count for month page
class NotFittedPageEventCount {
  List<NotFittedWeekEventCount> weeks = [];
}
