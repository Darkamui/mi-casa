class DurationLearner {
  const DurationLearner({this.alpha = 0.3});

  /// How much weight the most recent actual duration carries, in
  /// [0, 1]. Higher reacts faster to new data; lower is more stable.
  final double alpha;

  double updateEstimate({
    required double currentEstimateMinutes,
    required double actualMinutes,
  }) {
    return currentEstimateMinutes +
        alpha * (actualMinutes - currentEstimateMinutes);
  }
}
