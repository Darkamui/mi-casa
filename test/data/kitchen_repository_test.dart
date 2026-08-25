import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/data/database.dart';
import 'package:micasa/data/kitchen_repository.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/entropy_engine.dart';
import 'package:micasa/simulation/kitchen_session.dart';
import 'package:micasa/simulation/models/task_definition.dart';

final _tasks = [
  const TaskDefinition(
    id: 'kitchen.dishes',
    roomTypeId: 'kitchen',
    label: 'Put the dishes away',
    baseDurationMinutes: 2,
    // 0.05/h -> 20h to fully decay.
    defaultRisePerHour: 0.05,
  ),
  const TaskDefinition(
    id: 'kitchen.wipe_counter',
    roomTypeId: 'kitchen',
    label: 'Wipe the counter',
    baseDurationMinutes: 2,
    defaultRisePerHour: 0.05,
  ),
];

final _t0 = DateTime.utc(2026, 8, 25, 12);

void main() {
  late AppDatabase db;
  late KitchenRepository repository;
  late KitchenSessionEngine engine;

  setUp(() async {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    repository = KitchenRepository(db);
    engine = KitchenSessionEngine(
      tasks: _tasks,
      comboEngine: ComboEngine(AdjacencyGraph(const [])),
    );
    await repository.ensureSeeded(_tasks, _t0);
  });

  tearDown(() => db.close());

  /// What the app does on launch.
  Future<KitchenSession> reopen(DateTime now) =>
      repository.restore(engine, engine.seed(now: now));

  test('seeding twice does not duplicate the kitchen', () async {
    await repository.ensureSeeded(_tasks, _t0);

    expect((await db.roomsDao.getAllRooms()).length, 1);
    expect((await db.choresDao.getActiveChores()).length, _tasks.length);
  });

  test('a completed task is still completed after a relaunch', () async {
    await repository.recordCompletion(
      taskId: 'kitchen.dishes',
      at: _t0,
      actualMinutes: 2,
    );

    final session = await reopen(_t0.add(const Duration(hours: 1)));

    expect(session.lastCompletedAt['kitchen.dishes'], _t0);
    expect(engine.needLevel(session, 'kitchen.dishes',
            _t0.add(const Duration(hours: 1))),
        closeTo(0.05, 0.001),
        reason: 'one hour of decay since it was really done, not sixteen');
  });

  test('a task never done keeps its seeded head start', () async {
    await repository.recordCompletion(
      taskId: 'kitchen.dishes',
      at: _t0,
      actualMinutes: 2,
    );

    final session = await reopen(_t0);

    // Restoring must not quietly reset untouched tasks to "done just now".
    expect(session.lastCompletedAt['kitchen.wipe_counter'],
        _t0.subtract(const Duration(hours: 16)));
  });

  test('the duration estimate survives a relaunch', () async {
    // Consistently slower than the 2 min the content advertises.
    for (var i = 0; i < 4; i++) {
      await repository.recordCompletion(
        taskId: 'kitchen.dishes',
        at: _t0.add(Duration(days: i)),
        actualMinutes: 9,
      );
    }

    final session = await reopen(_t0.add(const Duration(days: 4)));

    expect(engine.offeredMinutes(session, 'kitchen.dishes'), greaterThan(3),
        reason: 'the app should stop advertising two minutes');
  });

  test('the room learns the real cadence rather than the authored one',
      () async {
    // Actually done every 48h, against an authored 20h decay.
    for (var i = 0; i < 4; i++) {
      await repository.recordCompletion(
        taskId: 'kitchen.dishes',
        at: _t0.add(Duration(hours: 48 * i)),
        actualMinutes: 2,
      );
    }

    final session = await reopen(_t0.add(const Duration(hours: 144)));

    // Spec §3.8 - it stops insisting on a schedule the user does not keep.
    expect(session.risePerHour['kitchen.dishes'], closeTo(1 / 48, 0.0001));
    expect(session.risePerHour['kitchen.wipe_counter'], 0.05,
        reason: 'a task with no history has nothing to learn from');
  });

  test('a fresh install opens on the seeded state, not an empty one', () async {
    final session = await reopen(_t0);

    expect(session.phase, RunPhase.idle);
    for (final task in _tasks) {
      expect(session.lastCompletedAt[task.id], isNotNull);
    }
    expect(engine.vitality(session, _t0), isNot(NeedState.thriving));
  });
}
