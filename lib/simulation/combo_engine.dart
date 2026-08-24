import 'adjacency_graph.dart';
import 'models/adjacency_edge.dart';

class ComboEngine {
  const ComboEngine(this.graph);

  final AdjacencyGraph graph;

  /// The lowest-friction (lowest [AdjacencyEdge.estimatedMinutes])
  /// adjacent action following [completedTaskId], excluding any task
  /// already finished this run. Null if nothing adjacent is left.
  AdjacencyEdge? suggestNext(
    String completedTaskId, {
    required Set<String> completedThisRun,
  }) {
    final candidates = graph
        .edgesFrom(completedTaskId)
        .where((edge) => !completedThisRun.contains(edge.toTaskId))
        .toList();

    if (candidates.isEmpty) return null;

    return candidates.reduce(
      (a, b) => a.estimatedMinutes <= b.estimatedMinutes ? a : b,
    );
  }
}
