import 'dart:async';

import 'package:flutter/services.dart';

import 'haptic_score.dart';

/// Plays the patterns in [HapticScore].
///
/// An interface so tests can watch what was played without a device - the
/// only way to check §4.3's real requirement, which is that the four
/// patterns stay distinct from each other.
abstract class Haptics {
  /// Fires the first tap immediately and schedules the rest.
  ///
  /// Never returns a future to await. CLAUDE.md: DONE -> local state ->
  /// haptic; a haptic something has to wait for is not feedback.
  void play(HapticCue cue);

  /// Drops anything still scheduled.
  void cancel();
}

/// The device, through Flutter's own coarse impacts.
///
/// Phase 0 builds the patterns out of the taps every platform already gives
/// us, sequenced in Dart. The finer control §4.3 eventually wants - Core
/// Haptics on iOS, a waveform channel on Android - changes this class and
/// nothing else, because the patterns themselves live in [HapticScore].
class SystemHaptics implements Haptics {
  SystemHaptics({this.score = const HapticScore()});

  final HapticScore score;
  final List<Timer> _pending = [];

  @override
  void play(HapticCue cue) {
    // Latest wins. Two patterns overlapping is one indistinct buzz, which is
    // the opposite of "distinct, learnable patterns".
    cancel();

    for (final beat in score.beatsFor(cue)) {
      if (beat.at == Duration.zero) {
        _tap(beat.strength);
        continue;
      }
      _pending.add(Timer(beat.at, () => _tap(beat.strength)));
    }
  }

  @override
  void cancel() {
    for (final timer in _pending) {
      timer.cancel();
    }
    _pending.clear();
  }

  void _tap(HapticStrength strength) {
    switch (strength) {
      case HapticStrength.light:
        HapticFeedback.lightImpact();
      case HapticStrength.medium:
        HapticFeedback.mediumImpact();
      case HapticStrength.heavy:
        HapticFeedback.heavyImpact();
    }
  }
}

/// Nothing at all - for tests, and for anywhere a buzz would be wrong.
class SilentHaptics implements Haptics {
  const SilentHaptics();

  @override
  void play(HapticCue cue) {}

  @override
  void cancel() {}
}
