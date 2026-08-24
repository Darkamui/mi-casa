import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/depth_sort.dart';

void main() {
  test('assigns ascending priorities in floorY order', () {
    final priorities = assignDepthPriorities(const [
      DepthEntry(id: 'table', floorY: 300),
      DepthEntry(id: 'chair', floorY: 100),
      DepthEntry(id: 'companion', floorY: 500),
    ]);

    expect(priorities['chair'], lessThan(priorities['table']!));
    expect(priorities['table'], lessThan(priorities['companion']!));
  });

  test('assigns contiguous priorities starting at 0', () {
    final priorities = assignDepthPriorities(const [
      DepthEntry(id: 'a', floorY: 10),
      DepthEntry(id: 'b', floorY: 20),
    ]);

    expect(priorities.values.toSet(), {0, 1});
  });

  test('breaks ties by input order, not floorY', () {
    final priorities = assignDepthPriorities(const [
      DepthEntry(id: 'first', floorY: 50),
      DepthEntry(id: 'second', floorY: 50),
    ]);

    expect(priorities['first'], 0);
    expect(priorities['second'], 1);
  });

  test('handles an empty list', () {
    expect(assignDepthPriorities(const []), isEmpty);
  });
}
