import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/content_loader.dart';

void main() {
  const loader = ContentLoader();

  test('parseRoomTypes parses a JSON array of room types', () {
    const source = '''
    [
      {"id": "kitchen", "name": "Kitchen", "taskIds": ["kitchen.dishes"]}
    ]
    ''';

    final result = loader.parseRoomTypes(source);

    expect(result, hasLength(1));
    expect(result.first.id, 'kitchen');
    expect(result.first.name, 'Kitchen');
    expect(result.first.taskIds, ['kitchen.dishes']);
  });

  test('parseTasks parses a JSON array of tasks', () {
    const source = '''
    [
      {
        "id": "kitchen.dishes",
        "roomTypeId": "kitchen",
        "label": "Put the dishes away",
        "baseDurationMinutes": 2.0,
        "defaultRisePerHour": 0.005952
      }
    ]
    ''';

    final result = loader.parseTasks(source);

    expect(result, hasLength(1));
    expect(result.first.id, 'kitchen.dishes');
    expect(result.first.label, 'Put the dishes away');
  });

  test('parseAdjacencyEdges parses a JSON array of edges', () {
    const source = '''
    [
      {
        "fromTaskId": "kitchen.dishes",
        "toTaskId": "kitchen.clear_counter",
        "prompt": "Clear the counter?",
        "estimatedMinutes": 2.0
      }
    ]
    ''';

    final result = loader.parseAdjacencyEdges(source);

    expect(result, hasLength(1));
    expect(result.first.fromTaskId, 'kitchen.dishes');
    expect(result.first.toTaskId, 'kitchen.clear_counter');
  });
}
