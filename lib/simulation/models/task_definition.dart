class TaskDefinition {
  const TaskDefinition({
    required this.id,
    required this.roomTypeId,
    required this.label,
    required this.baseDurationMinutes,
    required this.defaultRisePerHour,
  });

  final String id;
  final String roomTypeId;
  final String label;
  final double baseDurationMinutes;
  final double defaultRisePerHour;

  factory TaskDefinition.fromJson(Map<String, dynamic> json) {
    return TaskDefinition(
      id: json['id'] as String,
      roomTypeId: json['roomTypeId'] as String,
      label: json['label'] as String,
      baseDurationMinutes: (json['baseDurationMinutes'] as num).toDouble(),
      defaultRisePerHour: (json['defaultRisePerHour'] as num).toDouble(),
    );
  }
}
