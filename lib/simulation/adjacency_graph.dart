import 'models/adjacency_edge.dart';

class AdjacencyGraph {
  AdjacencyGraph(List<AdjacencyEdge> edges) : _edges = List.unmodifiable(edges);

  final List<AdjacencyEdge> _edges;

  List<AdjacencyEdge> edgesFrom(String taskId) {
    return _edges.where((edge) => edge.fromTaskId == taskId).toList();
  }
}
