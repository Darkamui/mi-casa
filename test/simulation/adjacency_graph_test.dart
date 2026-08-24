import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';

void main() {
  test('edgesFrom returns only edges starting at the given task', () {
    final graph = AdjacencyGraph(const [
      AdjacencyEdge(
        fromTaskId: 'kitchen.dishes',
        toTaskId: 'kitchen.clear_counter',
        prompt: 'Clear the counter?',
        estimatedMinutes: 2.0,
      ),
      AdjacencyEdge(
        fromTaskId: 'kitchen.garbage',
        toTaskId: 'kitchen.new_bag',
        prompt: 'Put in a new bag?',
        estimatedMinutes: 1.0,
      ),
    ]);

    final edges = graph.edgesFrom('kitchen.dishes');

    expect(edges, hasLength(1));
    expect(edges.single.toTaskId, 'kitchen.clear_counter');
  });

  test('edgesFrom returns an empty list for a task with no outgoing edges', () {
    final graph = AdjacencyGraph(const []);

    expect(graph.edgesFrom('kitchen.new_bag'), isEmpty);
  });
}
