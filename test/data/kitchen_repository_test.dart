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
import 'package:micasa/simulation/models/task_rung.dart';

final _tasks = [
  const TaskDefinition(
    id: 'kitchen.dishes',
    roomTypeId: 'kitchen',
    label: 'Put the dishes away',
    baseDurationMinutes: 2,
    // 0.05/h -> 20h to fully decay.
    defaultRisePerHour: 0.05,
    rungs: [
      TaskRung(
        id: 'kitchen.dishes.rack',
        label: 'Just empty the rack',
        durationMinutes: 1,
        credit: 0.5,
      ),
      TaskRung(
        id: 'kitchen.dishes.one',
        label: 'Put away one thing',
        durationMinutes: 0.5,
        credit: 0.2,
        setupQuest: true,
      ),
    ],
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

    final expected = _tasks.fold<int>(0, (n, t) => n + 1 + t.rungs.length);

    expect((await db.roomsDao.getAllRooms()).length, 1);
    expect((await db.choresDao.getActiveChores()).length, expected,
        reason: 'rungs are stored acts too, and are seeded exactly once');
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

  group('rungs survive a relaunch (spec 3.7)', () {
    test('a rung finished yesterday still shows in today\'s room', () async {
      final at = _t0.subtract(const Duration(hours: 8));
      await repository.recordCompletion(
        taskId: 'kitchen.dishes.rack',
        at: at,
        actualMinutes: 1,
      );

      final withRung = await reopen(_t0);
      final withoutRung = engine.seed(now: _t0);

      // Half the sixteen-hour backlog was cleared eight hours ago, so the
      // dishes must read better than a room where nothing happened.
      expect(engine.needLevel(withRung, 'kitchen.dishes', _t0),
          lessThan(engine.needLevel(withoutRung, 'kitchen.dishes', _t0)));
    });

    test('a rung is never restored as a finished chore', () async {
      await repository.recordCompletion(
        taskId: 'kitchen.dishes.rack',
        at: _t0,
        actualMinutes: 1,
      );

      final session = await reopen(_t0);

      expect(session.lastCompletedAt['kitchen.dishes'], isNot(_t0));
      expect(engine.needLevel(session, 'kitchen.dishes', _t0),
          greaterThan(0),
          reason: 'emptying the rack is not doing the dishes');
    });

    test('two small acts add up to more than one', () async {
      await repository.recordCompletion(
        taskId: 'kitchen.dishes.one',
        at: _t0.subtract(const Duration(hours: 2)),
        actualMinutes: 0.5,
      );
      final once = await reopen(_t0);

      await repository.recordCompletion(
        taskId: 'kitchen.dishes.one',
        at: _t0.subtract(const Duration(hours: 1)),
        actualMinutes: 0.5,
      );
      final twice = await reopen(_t0);

      expect(engine.needLevel(twice, 'kitchen.dishes', _t0),
          lessThan(engine.needLevel(once, 'kitchen.dishes', _t0)));
    });

    test('a rung before the last real completion is spent, not re-credited',
        () async {
      await repository.recordCompletion(
        taskId: 'kitchen.dishes.rack',
        at: _t0.subtract(const Duration(hours: 10)),
        actualMinutes: 1,
      );
      await repository.recordCompletion(
        taskId: 'kitchen.dishes',
        at: _t0.subtract(const Duration(hours: 4)),
        actualMinutes: 2,
      );

      final session = await reopen(_t0);

      // The chore was actually done after that rung: the rung's partial
      // credit is history, and must not pull the clock back again.
      expect(session.lastCompletedAt['kitchen.dishes'],
          _t0.subtract(const Duration(hours: 4)));
    });

    test('a rung teaches its own estimate across a relaunch', () async {
      for (var i = 0; i < 4; i++) {
        await repository.recordCompletion(
          taskId: 'kitchen.dishes.rack',
          at: _t0.add(Duration(days: i)),
          actualMinutes: 4,
        );
      }

      final session = await reopen(_t0.add(const Duration(days: 4)));

      expect(session.estimateMinutes['kitchen.dishes.rack'], greaterThan(1.5));
      expect(engine.offeredMinutes(session, 'kitchen.dishes'), 2,
          reason: 'the rung learned about itself, not about the dishes');
    });
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
