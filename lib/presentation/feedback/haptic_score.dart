/// How hard a single tap hits.
///
/// Our own scale rather than Flutter's, so the score below stays pure Dart
/// and can be read and tested without a device, a plugin, or a binding.
enum HapticStrength { light, medium, heavy }

/// One tap in a pattern: how hard, and how long after the pattern started.
class HapticBeat {
  const HapticBeat(this.at, this.strength);

  final Duration at;
  final HapticStrength strength;

  @override
  bool operator ==(Object other) =>
      other is HapticBeat && other.at == at && other.strength == strength;

  @override
  int get hashCode => Object.hash(at, strength);

  @override
  String toString() => '${at.inMilliseconds}ms ${strength.name}';
}

/// The moments Phase 0 actually has to say something about.
///
/// Spec §4.3 names four patterns, one of which - "boss complete" - belongs
/// to §6 and has no Phase 0 event. [roomRestored] takes its place because it
/// is the same beat in the run: the payoff at the end, and the only moment
/// that has earned the strongest thing we can do.
enum HapticCue {
  /// DONE. §4.3: "short crisp tap".
  taskComplete,

  /// The adjacent thing, offered. §4.3: "double tap".
  combo,

  /// §4.3's escalating pattern, bound to the x4 chain §4.2 already treats as
  /// a musical event ("melody at x4"). Phase 0 has no rare finds to find.
  momentumMilestone,

  /// End of run. §4.3: "strong satisfying impact".
  roomRestored,
}

/// What each moment feels like (spec §4.3).
///
/// Pure and authored in one place, for the reason §4.3 gives: the patterns
/// have to be *distinct and learnable*, and that is a property of the set,
/// not of any one of them. Scattered `HapticFeedback.mediumImpact()` calls
/// across the widget tree cannot be checked against each other; this can.
class HapticScore {
  const HapticScore();

  /// The chain length that earns the escalating pattern.
  static const momentumMilestone = 4;

  List<HapticBeat> beatsFor(HapticCue cue) {
    switch (cue) {
      case HapticCue.taskComplete:
        return const [HapticBeat(Duration.zero, HapticStrength.medium)];

      case HapticCue.combo:
        // Far enough apart to read as two taps rather than one long one,
        // close enough to still be one gesture.
        return const [
          HapticBeat(Duration.zero, HapticStrength.light),
          HapticBeat(Duration(milliseconds: 95), HapticStrength.light),
        ];

      case HapticCue.momentumMilestone:
        return const [
          HapticBeat(Duration.zero, HapticStrength.light),
          HapticBeat(Duration(milliseconds: 80), HapticStrength.medium),
          HapticBeat(Duration(milliseconds: 190), HapticStrength.heavy),
        ];

      case HapticCue.roomRestored:
        return const [HapticBeat(Duration.zero, HapticStrength.heavy)];
    }
  }

  /// Whether finishing a task at [momentum] is the escalating moment.
  bool isMilestone(int momentum) => momentum == momentumMilestone;

  /// How long a pattern runs. Nothing waits on this - it is here so a second
  /// cue can tell whether it is interrupting one.
  Duration lengthOf(HapticCue cue) => beatsFor(cue).last.at;
}
