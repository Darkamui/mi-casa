import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';

void main() {
  test('parses an adjacency edge from JSON', () {
    final edge = AdjacencyEdge.fromJson(const {
      'fromTaskId': 'kitchen.clear_counter',
      'toTaskId': 'kitchen.wipe_counter',
      'prompt': 'Wipe it?',
      'estimatedMinutes': 2.0,
    });

    expect(edge.fromTaskId, 'kitchen.clear_counter');
    expect(edge.toTaskId, 'kitchen.wipe_counter');
    expect(edge.prompt, 'Wipe it?');
    expect(edge.estimatedMinutes, 2.0);
  });
}
