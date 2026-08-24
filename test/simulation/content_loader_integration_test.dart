import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const loader = ContentLoader();

  test('loads the real kitchen room type from content/', () async {
    final roomTypes = await loader.loadRoomTypes();

    expect(roomTypes.any((r) => r.id == 'kitchen'), isTrue);
  });

  test('loads the real kitchen tasks from content/', () async {
    final tasks = await loader.loadTasks();

    expect(tasks.map((t) => t.id), containsAll(<String>[
      'kitchen.dishes',
      'kitchen.clear_counter',
      'kitchen.wipe_counter',
      'kitchen.garbage',
      'kitchen.new_bag',
    ]));
  });

  test('loads the real kitchen adjacency chain from content/', () async {
    final edges = await loader.loadAdjacencyEdges();

    expect(
      edges.any((e) =>
          e.fromTaskId == 'kitchen.dishes' &&
          e.toTaskId == 'kitchen.clear_counter'),
      isTrue,
    );
    expect(
      edges.any((e) =>
          e.fromTaskId == 'kitchen.garbage' &&
          e.toTaskId == 'kitchen.new_bag'),
      isTrue,
    );
  });

  test('every adjacency edge references tasks that actually exist', () async {
    final tasks = await loader.loadTasks();
    final edges = await loader.loadAdjacencyEdges();
    final taskIds = tasks.map((t) => t.id).toSet();

    for (final edge in edges) {
      expect(
        taskIds.contains(edge.fromTaskId),
        isTrue,
        reason: '${edge.fromTaskId} missing from tasks.json',
      );
      expect(
        taskIds.contains(edge.toTaskId),
        isTrue,
        reason: '${edge.toTaskId} missing from tasks.json',
      );
    }
  });

  test('every task belongs to a room type that lists it', () async {
    final tasks = await loader.loadTasks();
    final roomTypes = await loader.loadRoomTypes();
    final roomTaskIds = {
      for (final r in roomTypes) r.id: r.taskIds.toSet(),
    };

    for (final task in tasks) {
      final taskIds = roomTaskIds[task.roomTypeId];
      expect(
        taskIds, isNotNull,
        reason: '${task.roomTypeId} has no room_types.json entry',
      );
      expect(
        taskIds!.contains(task.id), isTrue,
        reason: '${task.id} missing from its room type\'s taskIds',
      );
    }
  });
}
