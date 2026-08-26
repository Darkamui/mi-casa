import 'task_rung.dart';

class TaskDefinition {
  const TaskDefinition({
    required this.id,
    required this.roomTypeId,
    required this.label,
    required this.baseDurationMinutes,
    required this.defaultRisePerHour,
    this.rungs = const [],
  });

  final String id;
  final String roomTypeId;
  final String label;
  final double baseDurationMinutes;
  final double defaultRisePerHour;

  /// The downgrade ladder for this task (spec §3.7), ordered largest first.
  /// Empty is fine - a one-minute task has nowhere left to fall.
  final List<TaskRung> rungs;

  factory TaskDefinition.fromJson(Map<String, dynamic> json) {
    return TaskDefinition(
      id: json['id'] as String,
      roomTypeId: json['roomTypeId'] as String,
      label: json['label'] as String,
      baseDurationMinutes: (json['baseDurationMinutes'] as num).toDouble(),
      defaultRisePerHour: (json['defaultRisePerHour'] as num).toDouble(),
      rungs: [
        for (final rung in (json['rungs'] as List<dynamic>? ?? const []))
          TaskRung.fromJson(rung as Map<String, dynamic>),
      ],
    );
  }
}
