/// A smaller version of a task, one step down the downgrade ladder.
///
/// Spec §3.7:
///
/// ```
/// Vacuum upstairs
///    → Vacuum only the visible hallway
///       → Bring the vacuum upstairs
/// ```
///
/// > The last rung sounds absurd and is the most valuable thing in the system.
///
/// A rung is deliberately *not* a [TaskDefinition]. It has no entropy of its
/// own and never nags from the room: it exists only as an answer to "not
/// this", so it cannot dilute the room's vitality or compete for a hotspot.
class TaskRung {
  const TaskRung({
    required this.id,
    required this.label,
    required this.durationMinutes,
    required this.credit,
    this.setupQuest = false,
  });

  final String id;
  final String label;

  final double durationMinutes;

  /// How much of the parent's accumulated need this clears, 0-1.
  ///
  /// Never 1: emptying the drying rack is real progress on the dishes, but it
  /// is not the dishes. Granting full credit would let the ladder launder a
  /// thirty-second act into a finished chore, and the room would then lie
  /// about its own state - which §2.4 ("time is the honest signal") forbids
  /// more than it forbids an unfinished task.
  final double credit;

  /// Spec §3.6: preparatory actions are valid gameplay. Putting the bag by
  /// the door is not a consolation prize for failing to take it out - it is
  /// the thing that removes tomorrow's activation barrier.
  final bool setupQuest;

  factory TaskRung.fromJson(Map<String, dynamic> json) {
    return TaskRung(
      id: json['id'] as String,
      label: json['label'] as String,
      durationMinutes: (json['durationMinutes'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      setupQuest: json['setupQuest'] as bool? ?? false,
    );
  }
}
