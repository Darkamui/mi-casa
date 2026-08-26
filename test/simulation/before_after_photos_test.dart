import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/kitchen_session.dart';
import 'package:micasa/simulation/models/task_definition.dart';

const _tasks = [
  TaskDefinition(
    id: 'dishes',
    roomTypeId: 'kitchen',
    label: 'Put the dishes away',
    baseDurationMinutes: 10,
    defaultRisePerHour: 0.05,
  ),
];

final _engine = KitchenSessionEngine(
  tasks: _tasks,
  comboEngine: ComboEngine(AdjacencyGraph(const [])),
);

final _t0 = DateTime.utc(2026, 8, 25, 12);

KitchenSession _offered() =>
    _engine.offerQuest(_engine.seed(now: _t0), 'dishes');

/// An offer, played through to the end of the run.
KitchenSession _restored({String? withBefore}) {
  var session = _offered();
  if (withBefore != null) {
    session = _engine.attachBeforePhoto(session, withBefore);
  }
  session = _engine.startRun(session, _t0);
  session = _engine.completeTask(session, _t0.add(const Duration(minutes: 6)));
  return _engine.finishCelebration(session);
}

void main() {
  group('the before/after pair (spec 2.4)', () {
    test('the before is taken while the offer is still open', () {
      final after = _engine.attachBeforePhoto(_offered(), '/photos/a.jpg');

      expect(after.beforePhoto, '/photos/a.jpg');
      expect(after.phase, RunPhase.questOffered);
    });

    test('the after is taken once the run is over', () {
      final session = _engine.attachAfterPhoto(
        _restored(withBefore: '/photos/a.jpg'),
        '/photos/b.jpg',
      );

      expect(session.afterPhoto, '/photos/b.jpg');
      expect(session.hasComparison, isTrue);
    });

    test('an after with no before is refused', () {
      // The mechanic is the pair. A lone photograph of a clean kitchen makes
      // none of the argument the slider makes.
      final session = _engine.attachAfterPhoto(_restored(), '/photos/b.jpg');

      expect(session.afterPhoto, isNull);
      expect(session.hasComparison, isFalse);
    });

    test('a before survives the run it belongs to', () {
      final session = _restored(withBefore: '/photos/a.jpg');

      expect(session.beforePhoto, '/photos/a.jpg');
    });
  });

  group('a photograph is never a step', () {
    test('a run with no photos plays exactly like a run with them', () {
      final withPhoto = _restored(withBefore: '/photos/a.jpg');
      final without = _restored();

      expect(withPhoto.phase, without.phase);
      expect(withPhoto.momentum, without.momentum);
      expect(withPhoto.runActive, without.runActive);
      expect(withPhoto.lastCompletedAt, without.lastCompletedAt);
    });

    test('the before cannot be taken once the work has started', () {
      // By then the room in the photograph is no longer the room before.
      final running = _engine.startRun(_offered(), _t0);

      expect(
        _engine.attachBeforePhoto(running, '/photos/a.jpg'),
        same(running),
      );
    });

    test('the after cannot be taken mid-run', () {
      final running = _engine.startRun(
        _engine.attachBeforePhoto(_offered(), '/photos/a.jpg'),
        _t0,
      );

      expect(_engine.attachAfterPhoto(running, '/photos/b.jpg').afterPhoto,
          isNull);
    });
  });

  group('the pair can always be thrown away', () {
    test('discarding clears both', () {
      var session = _engine.attachAfterPhoto(
        _restored(withBefore: '/photos/a.jpg'),
        '/photos/b.jpg',
      );
      session = _engine.discardPhotos(session);

      expect(session.beforePhoto, isNull);
      expect(session.afterPhoto, isNull);
      expect(session.hasComparison, isFalse);
    });

    test('discarding nothing changes nothing', () {
      final session = _restored();

      expect(_engine.discardPhotos(session), same(session));
    });

    test('a new run drops the last one\'s pair', () {
      // Otherwise the app quietly accumulates photographs of someone's home,
      // which is exactly what "local-only" is supposed to rule out.
      final session = _engine.offerQuest(
        _engine.attachAfterPhoto(
          _restored(withBefore: '/photos/a.jpg'),
          '/photos/b.jpg',
        ),
        'dishes',
      );

      expect(session.beforePhoto, isNull);
      expect(session.afterPhoto, isNull);
    });
  });
}
