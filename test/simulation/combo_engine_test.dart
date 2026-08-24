import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';

void main() {
  test('suggestNext returns the only outgoing edge', () {
    final graph = AdjacencyGraph(const [
      AdjacencyEdge(
        fromTaskId: 'kitchen.dishes',
        toTaskId: 'kitchen.clear_counter',
        prompt: 'Clear the counter?',
        estimatedMinutes: 2.0,
      ),
    ]);
    final engine = ComboEngine(graph);

    final suggestion = engine.suggestNext('kitchen.dishes', completedThisRun: {});

    expect(suggestion?.toTaskId, 'kitchen.clear_counter');
  });

  test('suggestNext skips tasks already completed this run', () {
    final graph = AdjacencyGraph(const [
      AdjacencyEdge(
        fromTaskId: 'kitchen.dishes',
        toTaskId: 'kitchen.clear_counter',
        prompt: 'Clear the counter?',
        estimatedMinutes: 2.0,
      ),
    ]);
    final engine = ComboEngine(graph);

    final suggestion = engine.suggestNext(
      'kitchen.dishes',
      completedThisRun: {'kitchen.clear_counter'},
    );

    expect(suggestion, isNull);
  });

  test('suggestNext picks the lowest-friction option among several edges', () {
    final graph = AdjacencyGraph(const [
      AdjacencyEdge(
        fromTaskId: 'kitchen.garbage',
        toTaskId: 'kitchen.wipe_counter',
        prompt: 'Wipe the counter too?',
        estimatedMinutes: 5.0,
      ),
      AdjacencyEdge(
        fromTaskId: 'kitchen.garbage',
        toTaskId: 'kitchen.new_bag',
        prompt: 'Put in a new bag?',
        estimatedMinutes: 1.0,
      ),
    ]);
    final engine = ComboEngine(graph);

    final suggestion = engine.suggestNext('kitchen.garbage', completedThisRun: {});

    expect(suggestion?.toTaskId, 'kitchen.new_bag');
  });

  test('suggestNext returns null when there are no outgoing edges', () {
    final graph = AdjacencyGraph(const []);
    final engine = ComboEngine(graph);

    expect(engine.suggestNext('kitchen.new_bag', completedThisRun: {}), isNull);
  });
}
