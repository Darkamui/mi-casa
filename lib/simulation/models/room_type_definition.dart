class RoomTypeDefinition {
  const RoomTypeDefinition({
    required this.id,
    required this.name,
    required this.taskIds,
  });

  final String id;
  final String name;
  final List<String> taskIds;

  factory RoomTypeDefinition.fromJson(Map<String, dynamic> json) {
    return RoomTypeDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      taskIds: (json['taskIds'] as List).cast<String>(),
    );
  }
}
