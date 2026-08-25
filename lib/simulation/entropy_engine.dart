enum NeedState { thriving, comfortable, slipping, struggling, critical }

class EntropyEngine {
  const EntropyEngine();

  double needLevel({
    required double risePerHour,
    required DateTime lastCompletedAt,
    required DateTime now,
  }) {
    final hoursElapsed = now.difference(lastCompletedAt).inMinutes / 60.0;
    final raw = hoursElapsed * risePerHour;
    return raw.clamp(0.0, 1.0);
  }

  NeedState verbalState(double needLevel) {
    if (needLevel < 0.2) return NeedState.thriving;
    if (needLevel < 0.4) return NeedState.comfortable;
    if (needLevel < 0.6) return NeedState.slipping;
    if (needLevel < 0.8) return NeedState.struggling;
    return NeedState.critical;
  }

  double learnedRisePerHour({
    required double defaultRisePerHour,
    required List<DateTime> completionHistory,
  }) {
    if (completionHistory.length < 2) return defaultRisePerHour;

    final sorted = [...completionHistory]..sort();
    final intervalsHours = <double>[
      for (var i = 1; i < sorted.length; i++)
        sorted[i].difference(sorted[i - 1]).inMinutes / 60.0,
    ];

    final medianHours = _median(intervalsHours);
    if (medianHours <= 0) return defaultRisePerHour;
    return 1.0 / medianHours;
  }

  /// The task was offered and the user said it was not actually needed.
  ///
  /// Spec §3.8's objective is "maintain the home with the least unnecessary
  /// work", so being told the suggestion was unnecessary is the most direct
  /// evidence the engine ever gets. It backs off by a third rather than
  /// abandoning the task, so a single impatient tap cannot silence a chore
  /// forever - repeated ones compound, which is the intended way to stop
  /// being asked about something you genuinely do not do.
  double slowedCadence(double risePerHour) {
    const floor = 1.0 / (24 * 90); // Ninety days. Not never.
    final slowed = risePerHour * 0.667;
    return slowed < floor ? floor : slowed;
  }

  double _median(List<double> values) {
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2.0;
  }
}
