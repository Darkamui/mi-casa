class RoomTypeDefinition {
  const RoomTypeDefinition({
    required this.id,
    required this.name,
    required this.taskIds,
    this.available = true,
  });

  final String id;
  final String name;
  final List<String> taskIds;
  final bool available;

  factory RoomTypeDefinition.fromJson(Map<String, dynamic> json) {
    return RoomTypeDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      taskIds: (json['taskIds'] as List).cast<String>(),
      available: json['available'] as bool? ?? true,
    );
  }
}
