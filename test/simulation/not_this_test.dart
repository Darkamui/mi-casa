import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/entropy_engine.dart';
import 'package:micasa/simulation/kitchen_session.dart';
import 'package:micasa/simulation/models/task_definition.dart';
import 'package:micasa/simulation/models/task_rung.dart';

/// A task with a two-rung ladder, and one with none.
const _dishes = TaskDefinition(
  id: 'dishes',
  roomTypeId: 'kitchen',
  label: 'Put the dishes away',
  baseDurationMinutes: 10,
  defaultRisePerHour: 0.05,
  rungs: [
    TaskRung(
      id: 'dishes.rack',
      label: 'Just empty the rack',
      durationMinutes: 3,
      credit: 0.5,
    ),
    TaskRung(
      id: 'dishes.one',
      label: 'Put away one thing',
      durationMinutes: 1,
      credit: 0.2,
      setupQuest: true,
    ),
  ],
);

const _bag = TaskDefinition(
  id: 'bag',
  roomTypeId: 'kitchen',
  label: 'Put in a new bag',
  baseDurationMinutes: 1,
  defaultRisePerHour: 0.05,
);

final _engine = KitchenSessionEngine(
  tasks: const [_dishes, _bag],
  comboEngine: ComboEngine(AdjacencyGraph(const [])),
);

final _now = DateTime.utc(2026, 8, 25, 12);

KitchenSession _offered() =>
    _engine.offerQuest(_engine.seed(now: _now), 'dishes');

/// Says no [times] times with the same reason, returning what is offered after.
KitchenSession _refuse(
  KitchenSession session,
  NotThisReason reason,
  int times,
) {
  var current = session;
  for (var i = 0; i < times; i++) {
    // Re-open the card between refusals - a closed one has nothing to say no
    // to - but never after the last, so the final phase is the real answer.
    if (current.phase != RunPhase.questOffered) {
      current = _engine.offerQuest(current, 'dishes');
    }
    current = _engine.notThis(current, reason, _now);
  }
  return current;
}

void main() {
  group('NOT THIS (spec 3.7)', () {
    test('one no just closes the card - no ladder, no nagging', () {
      final after = _engine.notThis(_offered(), NotThisReason.tooTired, _now);

      expect(after.phase, RunPhase.idle);
      expect(after.currentTaskId, isNull);
      expect(after.activeRung, isNull);
    });

    test('saying no costs nothing', () {
      final before = _offered();
      final after = _engine.notThis(before, NotThisReason.tooTired, _now);

      // No completion, no momentum, and the room is exactly as dirty as it was.
      expect(after.momentum, 0);
      expect(after.lastCompletedAt['dishes'], before.lastCompletedAt['dishes']);
      expect(after.estimateMinutes['dishes'],
          before.estimateMinutes['dishes']);
    });

    test('a repeated no walks down the ladder instead of asking again', () {
      final after = _refuse(_offered(), NotThisReason.takesTooLong, 2);

      expect(after.phase, RunPhase.questOffered);
      expect(_engine.currentLabel(after), 'Just empty the rack');
      expect(_engine.currentMinutes(after), 3);
    });

    test('the ladder keeps descending, and the last rung is the setup quest',
        () {
      final after = _refuse(_offered(), NotThisReason.takesTooLong, 3);

      expect(_engine.currentLabel(after), 'Put away one thing');
      expect(_engine.activeRung(after)!.setupQuest, isTrue);
    });

    test('past the bottom rung it stops offering rather than inventing one',
        () {
      final after = _refuse(_offered(), NotThisReason.takesTooLong, 4);

      expect(after.phase, RunPhase.idle);
      expect(after.activeRung, isNull);
    });

    test('a task with no ladder simply closes', () {
      var session = _engine.offerQuest(_engine.seed(now: _now), 'bag');
      session = _engine.notThis(session, NotThisReason.tooTired, _now);
      session = _engine.offerQuest(session, 'bag');
      session = _engine.notThis(session, NotThisReason.tooTired, _now);

      expect(session.phase, RunPhase.idle);
    });

    test('"can\'t right now" is about the moment, so it never downgrades', () {
      final after = _refuse(_offered(), NotThisReason.cantRightNow, 4);

      // Four interruptions in a row must not conclude the chore is too big:
      // the card closes each time and the task is offered whole the next.
      expect(after.phase, RunPhase.idle);
      expect(after.activeRung, isNull);
      expect(after.rejections['dishes'], isNull);
    });

    test('"not actually needed" stops the nagging and slows the cadence', () {
      final before = _offered();
      final after =
          _engine.notThis(before, NotThisReason.notActuallyNeeded, _now);

      expect(after.phase, RunPhase.idle);
      expect(after.lastCompletedAt['dishes'], _now);
      expect(_engine.needLevel(after, 'dishes', _now), 0);
      expect(after.risePerHour['dishes']!,
          lessThan(before.risePerHour['dishes']!));
    });

    test('"not actually needed" grants no reward', () {
      final after =
          _engine.notThis(_offered(), NotThisReason.notActuallyNeeded, _now);

      expect(after.momentum, 0);
      expect(after.completedThisRun, isEmpty);
    });

    test('NOT THIS is ignored outside an open offer', () {
      final idle = _engine.seed(now: _now);

      expect(
        _engine.notThis(idle, NotThisReason.tooTired, _now),
        same(idle),
      );
    });
  });

  group('finishing a rung (spec 3.6, 3.7)', () {
    /// Two rejections, PLAY, then DONE a minute later.
    KitchenSession runRung(NotThisReason reason, int refusals) {
      var session = _refuse(_offered(), reason, refusals);
      session = _engine.startRun(session, _now);
      return _engine.completeTask(
        session,
        _now.add(const Duration(minutes: 1)),
      );
    }

    test('a rung celebrates like anything else', () {
      final after = runRung(NotThisReason.takesTooLong, 2);

      expect(after.phase, RunPhase.celebrating);
      expect(after.momentum, 1);
    });

    test('a rung clears part of the need, never all of it', () {
      final before = _refuse(_offered(), NotThisReason.takesTooLong, 2);
      final at = _now.add(const Duration(minutes: 1));
      final started = _engine.startRun(before, _now);
      final after = _engine.completeTask(started, at);

      final needBefore = _engine.needLevel(before, 'dishes', at);
      final needAfter = _engine.needLevel(after, 'dishes', at);

      expect(needAfter, lessThan(needBefore));
      expect(needAfter, greaterThan(0));
      // credit 0.5 of a 16h backlog: half the need, give or take the minute.
      expect(needAfter, closeTo(needBefore / 2, 0.01));
    });

    test('a rung does not retire the task it stood in for', () {
      final after = runRung(NotThisReason.takesTooLong, 2);

      // The dishes are still there, so the combo engine must stay free to
      // come back to them.
      expect(after.completedThisRun, isNot(contains('dishes')));
    });

    test('a rung teaches its own estimate, not the task\'s', () {
      final after = runRung(NotThisReason.takesTooLong, 2);

      expect(after.estimateMinutes['dishes'], _dishes.baseDurationMinutes);
      expect(after.estimateMinutes['dishes.rack'], isNot(3));
    });

    test('the ladder resets when the task is offered fresh', () {
      final finished = runRung(NotThisReason.takesTooLong, 2);
      final again = _engine.offerQuest(
        finished.copyWith(phase: RunPhase.idle),
        'dishes',
      );

      expect(again.activeRung, isNull);
      expect(_engine.currentLabel(again), 'Put the dishes away');
    });
  });

  group('slowed cadence', () {
    const entropy = EntropyEngine();

    test('backs off rather than abandoning the task', () {
      final slowed = entropy.slowedCadence(0.05);

      expect(slowed, lessThan(0.05));
      expect(slowed, greaterThan(0));
    });

    test('repeated no compounds', () {
      final once = entropy.slowedCadence(0.05);

      expect(entropy.slowedCadence(once), lessThan(once));
    });

    test('never slows past ninety days - "least work", not "no work"', () {
      var rise = 0.05;
      for (var i = 0; i < 50; i++) {
        rise = entropy.slowedCadence(rise);
      }

      expect(rise, closeTo(1 / (24 * 90), 1e-9));
    });
  });
}
