import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/feedback/haptic_score.dart';

void main() {
  const score = HapticScore();

  group('the patterns spec 4.3 names', () {
    test('a finished task is one short tap', () {
      expect(score.beatsFor(HapticCue.taskComplete), hasLength(1));
      expect(score.beatsFor(HapticCue.taskComplete).first.at, Duration.zero);
    });

    test('a combo is a double tap', () {
      final beats = score.beatsFor(HapticCue.combo);

      expect(beats, hasLength(2));
      expect(beats.map((beat) => beat.strength).toSet(), hasLength(1));
      // Two taps, not one long one, and not two separate events.
      final gap = beats[1].at - beats[0].at;
      expect(gap, greaterThan(const Duration(milliseconds: 50)));
      expect(gap, lessThan(const Duration(milliseconds: 200)));
    });

    test('the milestone escalates', () {
      final beats = score.beatsFor(HapticCue.momentumMilestone);

      expect(beats.length, greaterThan(2));
      for (var i = 1; i < beats.length; i++) {
        expect(
          beats[i].strength.index,
          greaterThan(beats[i - 1].strength.index),
          reason: 'a "small escalating pattern" has to actually escalate',
        );
        expect(beats[i].at, greaterThan(beats[i - 1].at));
      }
    });

    test('the end of a run is the strongest thing we do', () {
      final restored = score.beatsFor(HapticCue.roomRestored);

      expect(restored, hasLength(1));
      expect(restored.first.strength, HapticStrength.heavy);

      // Stronger than finishing any one task inside it - §4.1 makes the room
      // itself the payoff, and the buzz should not argue with that.
      expect(
        restored.first.strength.index,
        greaterThan(
          score.beatsFor(HapticCue.taskComplete).first.strength.index,
        ),
      );
    });
  });

  group('distinct, learnable patterns', () {
    test('no two cues feel the same', () {
      // This is the property §4.3 is actually asking for, and it is a
      // property of the set - which is why the patterns live in one place
      // rather than scattered across the widgets that fire them.
      final patterns = {
        for (final cue in HapticCue.values) cue: score.beatsFor(cue).toString()
      };

      expect(patterns.values.toSet(), hasLength(HapticCue.values.length));
    });

    test('every pattern starts instantly', () {
      // A tap the user waits for is not feedback (CLAUDE.md).
      for (final cue in HapticCue.values) {
        expect(score.beatsFor(cue).first.at, Duration.zero, reason: '$cue');
      }
    });

    test('no pattern outlasts the moment it belongs to', () {
      for (final cue in HapticCue.values) {
        expect(score.lengthOf(cue), lessThan(const Duration(milliseconds: 400)),
            reason: '$cue');
      }
    });
  });

  group('the escalating moment', () {
    test('is the x4 chain, which is already a musical event (4.2)', () {
      expect(score.isMilestone(4), isTrue);
    });

    test('is not every completion', () {
      expect(score.isMilestone(1), isFalse);
      expect(score.isMilestone(3), isFalse);
      // Once. A pattern that fires on every task past four stops being a
      // milestone and becomes the new normal.
      expect(score.isMilestone(5), isFalse);
    });
  });
}
