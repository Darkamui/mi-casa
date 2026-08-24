import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/entropy_engine.dart';

void main() {
  const engine = EntropyEngine();

  test('needLevel is zero right after completion', () {
    final now = DateTime(2026, 1, 8, 12);

    final level = engine.needLevel(
      risePerHour: 1 / 168,
      lastCompletedAt: now,
      now: now,
    );

    expect(level, 0.0);
  });

  test('needLevel rises linearly with elapsed time', () {
    final last = DateTime(2026, 1, 1, 12);
    final now = last.add(const Duration(hours: 84));

    final level = engine.needLevel(
      risePerHour: 1 / 168,
      lastCompletedAt: last,
      now: now,
    );

    expect(level, closeTo(0.5, 0.0001));
  });

  test('needLevel clamps at 1.0 however long it has been', () {
    final last = DateTime(2026, 1, 1);
    final now = last.add(const Duration(days: 30));

    final level = engine.needLevel(
      risePerHour: 1 / 168,
      lastCompletedAt: last,
      now: now,
    );

    expect(level, 1.0);
  });

  test('verbalState maps need level to the five coarse states', () {
    expect(engine.verbalState(0.0), NeedState.thriving);
    expect(engine.verbalState(0.3), NeedState.comfortable);
    expect(engine.verbalState(0.5), NeedState.slipping);
    expect(engine.verbalState(0.7), NeedState.struggling);
    expect(engine.verbalState(0.9), NeedState.critical);
  });

  test('learnedRisePerHour falls back to default with under 2 data points', () {
    final rate = engine.learnedRisePerHour(
      defaultRisePerHour: 1 / 168,
      completionHistory: [DateTime(2026, 1, 1)],
    );

    expect(rate, 1 / 168);
  });

  test('learnedRisePerHour recalibrates to the median actual interval', () {
    final history = [
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 10), // 9 days later
      DateTime(2026, 1, 22), // 12 days later
      DateTime(2026, 2, 1), // 10 days later
    ];

    final rate = engine.learnedRisePerHour(
      defaultRisePerHour: 1 / 168,
      completionHistory: history,
    );

    // Median interval is 10 days = 240 hours: needLevel should reach
    // 1.0 right around the cadence the user actually follows, not the
    // 7-day default (spec §3.8: "stops suggesting every 7").
    expect(rate, closeTo(1 / 240, 0.00001));
  });
}
