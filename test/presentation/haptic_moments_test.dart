import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/feedback/haptic_score.dart';
import 'package:micasa/presentation/feedback/haptics.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';
import 'package:micasa/presentation/screens/kitchen_screen.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';
import 'package:micasa/simulation/models/task_definition.dart';

/// Records what the room asked for, without buzzing anything.
class RecordingHaptics implements Haptics {
  final List<HapticCue> played = [];

  @override
  void play(HapticCue cue) => played.add(cue);

  @override
  void cancel() {}
}

const _tasks = [
  TaskDefinition(
    id: 'kitchen.dishes',
    roomTypeId: 'kitchen',
    label: 'Put the dishes away',
    baseDurationMinutes: 10,
    defaultRisePerHour: 0.05,
  ),
  TaskDefinition(
    id: 'kitchen.wipe',
    roomTypeId: 'kitchen',
    label: 'Wipe the counter',
    baseDurationMinutes: 4,
    defaultRisePerHour: 0.05,
  ),
  TaskDefinition(
    id: 'kitchen.sink',
    roomTypeId: 'kitchen',
    label: 'Clear the sink',
    baseDurationMinutes: 3,
    defaultRisePerHour: 0.05,
  ),
  TaskDefinition(
    id: 'kitchen.bin',
    roomTypeId: 'kitchen',
    label: 'Take the bag out',
    baseDurationMinutes: 2,
    defaultRisePerHour: 0.05,
  ),
];

final _engine = KitchenSessionEngine(
  tasks: _tasks,
  comboEngine: ComboEngine(AdjacencyGraph(const [
    AdjacencyEdge(
      fromTaskId: 'kitchen.dishes',
      toTaskId: 'kitchen.wipe',
      prompt: 'The counter is right there',
      estimatedMinutes: 4,
    ),
    AdjacencyEdge(
      fromTaskId: 'kitchen.wipe',
      toTaskId: 'kitchen.sink',
      prompt: 'And the sink',
      estimatedMinutes: 3,
    ),
    AdjacencyEdge(
      fromTaskId: 'kitchen.sink',
      toTaskId: 'kitchen.bin',
      prompt: 'The bag is full',
      estimatedMinutes: 2,
    ),
  ])),
);

final _t0 = DateTime.utc(2026, 8, 25, 12);

void main() {
  late RecordingHaptics haptics;
  late ProviderContainer container;
  late KitchenSceneController controller;

  Future<void> openRoom(WidgetTester tester) async {
    haptics = RecordingHaptics();
    container = ProviderContainer(overrides: [
      kitchenEngineProvider.overrideWith((ref) async => _engine),
      kitchenRepositoryProvider.overrideWithValue(null),
      clockProvider.overrideWithValue(() => _t0),
      hapticsProvider.overrideWithValue(haptics),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: KitchenScreen()),
    ));
    // Not pumpAndSettle: the hotspot affordances pulse forever by design.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    controller = container.read(kitchenSessionProvider.notifier);
  }

  /// Let the room's own timers - the celebration, the ROOM RESTORED card -
  /// finish, so the test ends with nothing pending.
  Future<void> drain(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 4));

  /// Finish the task in play and let the celebration run its course.
  Future<void> finishTask(WidgetTester tester) async {
    controller.completeTask();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
  }

  group('what the room says with the buzz (spec 4.3)', () {
    testWidgets('a finished task taps once', (tester) async {
      await openRoom(tester);
      controller.offerQuest('kitchen.dishes');
      controller.startRun();
      await tester.pump();

      controller.completeTask();
      await tester.pump();

      expect(haptics.played, [HapticCue.taskComplete]);

      await drain(tester);
    });

    testWidgets('the combo offer is its own pattern', (tester) async {
      await openRoom(tester);
      controller.offerQuest('kitchen.dishes');
      controller.startRun();
      await tester.pump();

      await finishTask(tester);

      // The whole point of §5.2 item 9 is that finishing does not end the
      // run - so the combo has to feel like a different event, not a repeat.
      expect(haptics.played, contains(HapticCue.combo));
      expect(haptics.played.last, HapticCue.combo);

      await drain(tester);
    });

    testWidgets('the end of the run is the strongest moment', (tester) async {
      await openRoom(tester);
      controller.offerQuest('kitchen.dishes');
      controller.startRun();
      await tester.pump();
      await finishTask(tester);

      controller.declineCombo();
      await tester.pump();

      expect(haptics.played.last, HapticCue.roomRestored);

      await drain(tester);
    });

    testWidgets('the fourth link in a chain escalates', (tester) async {
      await openRoom(tester);
      controller.offerQuest('kitchen.dishes');
      controller.startRun();
      await tester.pump();

      // §4.2 already treats x4 as a musical event ("melody at x4"). The buzz
      // agrees with the music rather than inventing a moment of its own.
      for (var i = 0; i < 3; i++) {
        await finishTask(tester);
        controller.acceptCombo();
        await tester.pump();
      }
      await finishTask(tester);

      expect(haptics.played, contains(HapticCue.momentumMilestone));
      expect(
        haptics.played.where((cue) => cue == HapticCue.momentumMilestone),
        hasLength(1),
      );

      await drain(tester);
    });

    testWidgets('nothing buzzes when nothing happened', (tester) async {
      await openRoom(tester);

      controller.offerQuest('kitchen.dishes');
      await tester.pump();
      controller.dismissQuest();
      await tester.pump();

      // Opening and closing an offer is not an achievement.
      expect(haptics.played, isEmpty);
    });
  });
}
