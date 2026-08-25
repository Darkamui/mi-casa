import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/entropy_engine.dart';
import 'package:micasa/simulation/kitchen_session.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';
import 'package:micasa/simulation/models/task_definition.dart';

/// Mirrors the shape of the shipped content without depending on its exact
/// numbers, so tuning `tasks.json` cannot silently break these rules.
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
    id: 'kitchen.clear_counter',
    roomTypeId: 'kitchen',
    label: 'Clear the counter',
    baseDurationMinutes: 2,
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

final _edges = [
  const AdjacencyEdge(
    fromTaskId: 'kitchen.dishes',
    toTaskId: 'kitchen.clear_counter',
    prompt: 'Clear the counter?',
    estimatedMinutes: 2,
  ),
  const AdjacencyEdge(
    fromTaskId: 'kitchen.clear_counter',
    toTaskId: 'kitchen.wipe_counter',
    prompt: 'Wipe it?',
    estimatedMinutes: 2,
  ),
];

KitchenSessionEngine _engine() => KitchenSessionEngine(
      tasks: _tasks,
      comboEngine: ComboEngine(AdjacencyGraph(_edges)),
    );

final _t0 = DateTime.utc(2026, 8, 24, 12);

void main() {
  group('seeding', () {
    test('a fresh kitchen has history, an estimate, and no run', () {
      final session = _engine().seed(now: _t0);

      expect(session.phase, RunPhase.idle);
      expect(session.currentTaskId, isNull);
      expect(session.momentum, 0);
      expect(session.lastCompletedAt.keys, containsAll(_tasks.map((t) => t.id)));
      expect(session.estimateMinutes['kitchen.dishes'], 2);
    });

    test('the opening state falls out of decay rates, not a hardcoded word',
        () {
      final engine = _engine();

      // Same seed, different elapsed time -> the room must read worse.
      final fresh = engine.seed(now: _t0, hoursSinceCompletion: 1);
      final stale = engine.seed(now: _t0, hoursSinceCompletion: 18);

      expect(engine.vitality(fresh, _t0).index,
          lessThan(engine.vitality(stale, _t0).index));
    });
  });

  group('entropy drives what is shown', () {
    test('vitality decays as time passes with nothing done', () {
      final engine = _engine();
      final session = engine.seed(now: _t0, hoursSinceCompletion: 0);

      expect(engine.vitality(session, _t0), NeedState.thriving);
      expect(
        engine.vitality(session, _t0.add(const Duration(hours: 19))),
        NeedState.critical,
      );
    });

    test('completing a task visibly restores the room', () {
      final engine = _engine();
      final now = _t0.add(const Duration(hours: 19));
      var session = engine.seed(now: _t0, hoursSinceCompletion: 0);

      final before = engine.vitality(session, now);

      session = engine.offerQuest(session, 'kitchen.dishes');
      session = engine.startRun(session, now);
      session = engine.completeTask(session, now);

      expect(engine.vitality(session, now).index, lessThan(before.index),
          reason: 'finishing something must make the room better, not equal');
    });

    test('the dish pile tracks the dishes, not the phase', () {
      final engine = _engine();
      final clean = engine.seed(now: _t0, hoursSinceCompletion: 0);
      final dirty = engine.seed(now: _t0, hoursSinceCompletion: 15);

      expect(engine.showsDishPile(clean, _t0), isFalse);
      expect(engine.showsDishPile(dirty, _t0), isTrue);
    });
  });

  group('the run', () {
    test('happy path chains through the combo graph', () {
      final engine = _engine();
      var session = engine.seed(now: _t0);

      session = engine.offerQuest(session, 'kitchen.dishes');
      expect(session.phase, RunPhase.questOffered);

      session = engine.startRun(session, _t0);
      expect(session.phase, RunPhase.running);

      session = engine.completeTask(session, _t0.add(const Duration(minutes: 3)));
      expect(session.phase, RunPhase.celebrating);
      expect(session.momentum, 1);

      session = engine.finishCelebration(session);
      expect(session.phase, RunPhase.comboOffered);
      expect(session.comboOffer?.toTaskId, 'kitchen.clear_counter');

      session = engine.acceptCombo(session, _t0);
      expect(session.phase, RunPhase.running);
      expect(session.currentTaskId, 'kitchen.clear_counter');

      session = engine.completeTask(session, _t0.add(const Duration(minutes: 2)));
      expect(session.momentum, 2, reason: 'the chain should be building');
    });

    test('the chain ends when nothing adjacent is left', () {
      final engine = _engine();
      var session = engine.seed(now: _t0);

      // wipe_counter is the end of the authored chain.
      session = engine.offerQuest(session, 'kitchen.wipe_counter');
      session = engine.startRun(session, _t0);
      session = engine.completeTask(session, _t0);
      session = engine.finishCelebration(session);

      expect(session.phase, RunPhase.restored);
      expect(session.comboOffer, isNull);
    });

    test('a task already done this run is never re-offered', () {
      final engine = _engine();
      var session = engine.seed(now: _t0);

      session = engine.offerQuest(session, 'kitchen.dishes');
      session = engine.startRun(session, _t0);
      session = engine.completeTask(session, _t0);
      session = engine.finishCelebration(session);
      session = engine.acceptCombo(session, _t0);
      session = engine.completeTask(session, _t0);
      session = engine.finishCelebration(session);

      expect(session.comboOffer?.toTaskId, isNot('kitchen.dishes'));
    });

    test('declining a combo ends the run warmly, keeping the work done', () {
      final engine = _engine();
      var session = engine.seed(now: _t0);

      session = engine.offerQuest(session, 'kitchen.dishes');
      session = engine.startRun(session, _t0);
      session = engine.completeTask(session, _t0);
      session = engine.finishCelebration(session);
      session = engine.declineCombo(session);

      expect(session.phase, RunPhase.restored);
      // The completion still counts - stopping is not a penalty (§3.7).
      expect(session.lastCompletedAt['kitchen.dishes'], _t0);
    });

    test('starting a new run resets the in-session chain', () {
      final engine = _engine();
      var session = engine.seed(now: _t0);

      session = engine.offerQuest(session, 'kitchen.dishes');
      session = engine.startRun(session, _t0);
      session = engine.completeTask(session, _t0);
      session = engine.finishCelebration(session);
      session = engine.declineCombo(session);
      session = engine.offerQuest(session, 'kitchen.wipe_counter');

      expect(session.momentum, 0, reason: 'momentum is in-session only');
      expect(session.completedThisRun, isEmpty);
    });
  });

  group('the run timer (spec items 7-8)', () {
    KitchenSession runningOn(KitchenSessionEngine engine) {
      var session = engine.seed(now: _t0);
      session = engine.offerQuest(session, 'kitchen.dishes');
      return engine.startRun(session, _t0);
    }

    test('time accrues while the run is going', () {
      final engine = _engine();
      final session = runningOn(engine);

      expect(engine.activeElapsed(session, _t0), Duration.zero);
      expect(engine.activeElapsed(session, _t0.add(const Duration(minutes: 3))),
          const Duration(minutes: 3));
    });

    test('a paused run stops the clock rather than slowing it', () {
      final engine = _engine();
      var session = runningOn(engine);

      session = engine.pauseRun(session, _t0.add(const Duration(minutes: 2)));

      // An hour on the sofa must not read as an hour of work.
      expect(engine.activeElapsed(session, _t0.add(const Duration(hours: 1))),
          const Duration(minutes: 2));
    });

    test('resuming picks up where it stopped, not where the clock is', () {
      final engine = _engine();
      var session = runningOn(engine);

      session = engine.pauseRun(session, _t0.add(const Duration(minutes: 2)));
      session = engine.resumeRun(session, _t0.add(const Duration(hours: 1)));

      expect(
        engine.activeElapsed(
            session, _t0.add(const Duration(hours: 1, minutes: 1))),
        const Duration(minutes: 3),
      );
    });

    test('paused time never reaches the estimate the app learns from', () {
      final engine = _engine();
      var session = runningOn(engine);
      final before = engine.offeredMinutes(session, 'kitchen.dishes');

      session = engine.pauseRun(session, _t0.add(const Duration(minutes: 2)));
      session = engine.resumeRun(session, _t0.add(const Duration(hours: 4)));
      session =
          engine.completeTask(session, _t0.add(const Duration(hours: 4)));

      // Two minutes of work either side of a four-hour gap: the estimate may
      // drift a little, but nothing here justifies a jump toward 4 hours.
      expect(engine.offeredMinutes(session, 'kitchen.dishes'),
          lessThan(before + 1));
    });

    test('run time accumulates across a chain, task time does not', () {
      final engine = _engine();
      var session = runningOn(engine);

      session = engine.completeTask(session, _t0.add(const Duration(minutes: 4)));
      session = engine.finishCelebration(session);
      final resumedAt = _t0.add(const Duration(minutes: 5));
      session = engine.acceptCombo(session, resumedAt);

      final now = resumedAt.add(const Duration(minutes: 2));
      expect(engine.activeElapsed(session, now), const Duration(minutes: 2),
          reason: 'the new task starts its own clock at zero');
      expect(engine.runElapsed(session, now), const Duration(minutes: 6),
          reason: 'the run keeps its total - that is what gets rewarded');
    });

    test('skipping costs nothing and earns nothing', () {
      final engine = _engine();
      var session = runningOn(engine);
      final before = engine.offeredMinutes(session, 'kitchen.dishes');
      final lastDone = session.lastCompletedAt['kitchen.dishes'];

      session = engine.skipTask(session);

      expect(session.phase, RunPhase.idle);
      expect(session.momentum, 0);
      expect(session.lastCompletedAt['kitchen.dishes'], lastDone,
          reason: 'a skipped task was not done');
      expect(engine.offeredMinutes(session, 'kitchen.dishes'), before,
          reason: 'abandoning is not evidence about how long the task takes');
    });

    test('skipping mid-chain keeps the work already finished', () {
      final engine = _engine();
      var session = runningOn(engine);

      session = engine.completeTask(session, _t0.add(const Duration(minutes: 2)));
      session = engine.finishCelebration(session);
      session = engine.acceptCombo(session, _t0);
      session = engine.skipTask(session);

      expect(session.phase, RunPhase.restored,
          reason: 'ending on a completion is a win, not a return to idle');
      expect(session.lastCompletedAt['kitchen.dishes'],
          _t0.add(const Duration(minutes: 2)));
    });

    test('pause and resume are ignored outside a live run', () {
      final engine = _engine();
      final idle = engine.seed(now: _t0);

      expect(engine.pauseRun(idle, _t0).isPaused, isFalse);
      expect(engine.resumeRun(idle, _t0).phase, RunPhase.idle);
      expect(engine.skipTask(idle).phase, RunPhase.idle);
    });
  });

  group('adaptive duration (spec item 13)', () {
    test('an estimate moves toward how long it actually took', () {
      final engine = _engine();
      var session = engine.seed(now: _t0);
      final offered = engine.offeredMinutes(session, 'kitchen.dishes');

      session = engine.offerQuest(session, 'kitchen.dishes');
      session = engine.startRun(session, _t0);
      // Took much longer than the 2 min it advertised.
      session = engine.completeTask(session, _t0.add(const Duration(minutes: 10)));

      expect(engine.offeredMinutes(session, 'kitchen.dishes'),
          greaterThan(offered));
    });

    test('a fast finish pulls the estimate back down', () {
      final engine = _engine();
      var session = engine.seed(now: _t0);
      final offered = engine.offeredMinutes(session, 'kitchen.dishes');

      session = engine.offerQuest(session, 'kitchen.dishes');
      session = engine.startRun(session, _t0);
      session = engine.completeTask(session, _t0.add(const Duration(seconds: 20)));

      expect(engine.offeredMinutes(session, 'kitchen.dishes'), lessThan(offered));
    });
  });

  group('illegal transitions are ignored, not crashes', () {
    test('you cannot start a run that was never offered', () {
      final engine = _engine();
      final session = engine.seed(now: _t0);

      expect(engine.startRun(session, _t0).phase, RunPhase.idle);
      expect(engine.completeTask(session, _t0).phase, RunPhase.idle);
      expect(engine.acceptCombo(session, _t0).phase, RunPhase.idle);
    });

    test('dismissing cannot abandon a run already underway', () {
      final engine = _engine();
      var session = engine.seed(now: _t0);
      session = engine.offerQuest(session, 'kitchen.dishes');
      session = engine.startRun(session, _t0);

      expect(engine.dismissQuest(session).phase, RunPhase.running);
    });

    test('an unknown task id is refused rather than offered', () {
      final engine = _engine();
      final session = engine.seed(now: _t0);

      expect(engine.offerQuest(session, 'kitchen.nope').phase, RunPhase.idle);
    });
  });
}
