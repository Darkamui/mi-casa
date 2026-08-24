class AdjacencyEdge {
  const AdjacencyEdge({
    required this.fromTaskId,
    required this.toTaskId,
    required this.prompt,
    required this.estimatedMinutes,
  });

  final String fromTaskId;
  final String toTaskId;
  final String prompt;
  final double estimatedMinutes;

  factory AdjacencyEdge.fromJson(Map<String, dynamic> json) {
    return AdjacencyEdge(
      fromTaskId: json['fromTaskId'] as String,
      toTaskId: json['toTaskId'] as String,
      prompt: json['prompt'] as String,
      estimatedMinutes: (json['estimatedMinutes'] as num).toDouble(),
    );
  }
}
