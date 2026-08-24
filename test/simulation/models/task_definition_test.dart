import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/models/task_definition.dart';

void main() {
  test('parses a task definition from JSON', () {
    final task = TaskDefinition.fromJson(const {
      'id': 'kitchen.dishes',
      'roomTypeId': 'kitchen',
      'label': 'Put the dishes away',
      'baseDurationMinutes': 2.0,
      'defaultRisePerHour': 0.005952,
    });

    expect(task.id, 'kitchen.dishes');
    expect(task.roomTypeId, 'kitchen');
    expect(task.label, 'Put the dishes away');
    expect(task.baseDurationMinutes, 2.0);
    expect(task.defaultRisePerHour, 0.005952);
  });
}
