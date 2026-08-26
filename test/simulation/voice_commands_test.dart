import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/kitchen_session.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';
import 'package:micasa/simulation/models/task_definition.dart';
import 'package:micasa/simulation/voice_grammar.dart';

const _tasks = [
  TaskDefinition(
    id: 'dishes',
    roomTypeId: 'kitchen',
    label: 'Put the dishes away',
    baseDurationMinutes: 10,
    defaultRisePerHour: 0.05,
  ),
  TaskDefinition(
    id: 'wipe',
    roomTypeId: 'kitchen',
    label: 'Wipe the counter',
    baseDurationMinutes: 4,
    defaultRisePerHour: 0.05,
  ),
];

final _engine = KitchenSessionEngine(
  tasks: _tasks,
  comboEngine: ComboEngine(AdjacencyGraph(const [
    AdjacencyEdge(
      fromTaskId: 'dishes',
      toTaskId: 'wipe',
      prompt: 'The counter is right there',
      estimatedMinutes: 4,
    ),
  ])),
);

final _t0 = DateTime.utc(2026, 8, 25, 12);

KitchenSession _offered() =>
    _engine.offerQuest(_engine.seed(now: _t0), 'dishes');

KitchenSession _running() => _engine.startRun(_offered(), _t0);

void main() {
  group('spoken commands (spec 2.5)', () {
    test('"done" finishes the task in play', () {
      final after = _engine.applyVoice(
        _running(),
        VoiceIntent.done,
        _t0.add(const Duration(minutes: 3)),
      );

      expect(after.phase, RunPhase.celebrating);
      expect(after.momentum, 1);
    });

    test('"next" is PLAY on an offer and YES on a combo', () {
      final played = _engine.applyVoice(_offered(), VoiceIntent.next, _t0);
      expect(played.phase, RunPhase.running);

      final combo = _engine.finishCelebration(
        _engine.completeTask(_running(), _t0.add(const Duration(minutes: 3))),
      );
      expect(combo.phase, RunPhase.comboOffered);

      final accepted = _engine.applyVoice(combo, VoiceIntent.next, _t0);
      expect(accepted.phase, RunPhase.running);
      expect(accepted.currentTaskId, 'wipe');
    });

    test('"skip" leaves whatever is on screen, without penalty', () {
      final mid = _engine.applyVoice(_running(), VoiceIntent.skip, _t0);
      expect(mid.phase, RunPhase.idle);
      expect(mid.momentum, 0);

      final offer = _engine.applyVoice(_offered(), VoiceIntent.skip, _t0);
      expect(offer.phase, RunPhase.idle);
      expect(offer.currentTaskId, isNull);
    });

    test('"pause" and "resume" really stop and restart the clock', () {
      final paused = _engine.applyVoice(
        _running(),
        VoiceIntent.pause,
        _t0.add(const Duration(minutes: 2)),
      );
      expect(paused.isPaused, isTrue);
      expect(
        _engine.activeElapsed(paused, _t0.add(const Duration(minutes: 20))),
        const Duration(minutes: 2),
      );

      final resumed = _engine.applyVoice(
        paused,
        VoiceIntent.resume,
        _t0.add(const Duration(minutes: 20)),
      );
      expect(
        _engine.activeElapsed(resumed, _t0.add(const Duration(minutes: 21))),
        const Duration(minutes: 3),
      );
    });
  });

  group('"five more minutes"', () {
    test('moves the target', () {
      final before = _running();
      final after =
          _engine.applyVoice(before, VoiceIntent.fiveMoreMinutes, _t0);

      expect(
        _engine.currentMinutes(after),
        _engine.currentMinutes(before) + 5,
      );
    });

    test('does not move the clock', () {
      final at = _t0.add(const Duration(minutes: 2));
      final after = _engine.applyVoice(
        _running(),
        VoiceIntent.fiveMoreMinutes,
        at,
      );

      // Asking for longer is permission to keep going, not a way to make two
      // minutes of work count as seven (§2.4).
      expect(_engine.activeElapsed(after, at), const Duration(minutes: 2));
    });

    test('can be asked for twice', () {
      var session = _running();
      final base = _engine.currentMinutes(session);
      session = _engine.applyVoice(session, VoiceIntent.fiveMoreMinutes, _t0);
      session = _engine.applyVoice(session, VoiceIntent.fiveMoreMinutes, _t0);

      expect(_engine.currentMinutes(session), base + 10);
    });

    test('does not carry into the next task', () {
      var session =
          _engine.applyVoice(_running(), VoiceIntent.fiveMoreMinutes, _t0);
      session = _engine.finishCelebration(
        _engine.completeTask(session, _t0.add(const Duration(minutes: 3))),
      );
      session = _engine.acceptCombo(session, _t0);

      expect(_engine.currentMinutes(session), 4);
    });
  });

  group('voice reaches nothing a tap could not', () {
    test('"done" on an idle room completes nothing', () {
      final idle = _engine.seed(now: _t0);

      expect(_engine.applyVoice(idle, VoiceIntent.done, _t0), same(idle));
    });

    test('"done" on an unstarted offer completes nothing', () {
      final offered = _offered();

      expect(
        _engine.applyVoice(offered, VoiceIntent.done, _t0),
        same(offered),
      );
    });

    test('"pause" outside a run does nothing', () {
      final offered = _offered();

      expect(
        _engine.applyVoice(offered, VoiceIntent.pause, _t0),
        same(offered),
      );
    });

    test('"five more minutes" outside a run does nothing', () {
      final idle = _engine.seed(now: _t0);

      expect(
        _engine.applyVoice(idle, VoiceIntent.fiveMoreMinutes, _t0),
        same(idle),
      );
    });
  });
}
