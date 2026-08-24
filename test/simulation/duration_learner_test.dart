import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/duration_learner.dart';

void main() {
  test('nudges the estimate toward the actual duration', () {
    const learner = DurationLearner();

    final updated = learner.updateEstimate(
      currentEstimateMinutes: 15.0,
      actualMinutes: 7.0,
    );

    expect(updated, closeTo(12.6, 0.0001));
  });

  test('repeated identical actuals converge on that duration', () {
    const learner = DurationLearner();
    var estimate = 15.0;

    for (var i = 0; i < 50; i++) {
      estimate = learner.updateEstimate(
        currentEstimateMinutes: estimate,
        actualMinutes: 7.0,
      );
    }

    expect(estimate, closeTo(7.0, 0.01));
  });

  test('an exact match leaves the estimate unchanged', () {
    const learner = DurationLearner();

    final updated = learner.updateEstimate(
      currentEstimateMinutes: 10.0,
      actualMinutes: 10.0,
    );

    expect(updated, 10.0);
  });
}
