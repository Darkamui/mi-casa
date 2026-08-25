import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';
import 'package:micasa/presentation/voice/voice_recognizer.dart';
import 'package:micasa/presentation/widgets/voice_button.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/models/task_definition.dart';

/// A recognizer we can put words into.
class FakeRecognizer implements VoiceRecognizer {
  FakeRecognizer({this.isAvailable = true});

  final bool isAvailable;
  final _controller = StreamController<String>.broadcast();

  bool started = false;
  bool stopped = false;

  void say(String utterance) => _controller.add(utterance);

  @override
  Future<bool> available() async => isAvailable;

  @override
  Stream<String> get utterances => _controller.stream;

  @override
  Future<void> start() async => started = true;

  @override
  Future<void> stop() async => stopped = true;
}

const _tasks = [
  TaskDefinition(
    id: 'dishes',
    roomTypeId: 'kitchen',
    label: 'Put the dishes away',
    baseDurationMinutes: 10,
    defaultRisePerHour: 0.05,
  ),
];

final _t0 = DateTime.utc(2026, 8, 25, 12);

final _engine = KitchenSessionEngine(
  tasks: _tasks,
  comboEngine: ComboEngine(AdjacencyGraph(const [])),
);

ProviderContainer _container(VoiceRecognizer recognizer) {
  final container = ProviderContainer(overrides: [
    kitchenEngineProvider.overrideWith((ref) async => _engine),
    kitchenRepositoryProvider.overrideWithValue(null),
    clockProvider.overrideWithValue(() => _t0),
    voiceRecognizerProvider.overrideWithValue(recognizer),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('an utterance drives the run', () {
    late ProviderContainer container;
    late KitchenSceneController controller;

    setUp(() async {
      container = _container(FakeRecognizer());
      await container.read(kitchenSessionProvider.future);
      controller = container.read(kitchenSessionProvider.notifier);
    });

    KitchenSession state() => container.read(kitchenSessionProvider).value!;

    test('"next" plays the offer, "done" finishes it', () {
      controller.offerQuest('dishes');

      expect(controller.hear('next'), VoiceIntent.next);
      expect(state().phase, RunPhase.running);

      expect(controller.hear("okay I'm done"), VoiceIntent.done);
      expect(state().phase, RunPhase.celebrating);
      expect(state().momentum, 1);
    });

    test('an unrecognised phrase is silence, not an error', () {
      controller.offerQuest('dishes');

      expect(controller.hear('what is the weather like'), isNull);
      expect(state().phase, RunPhase.questOffered);
    });

    test('a command that does not apply here reports nothing happened', () {
      controller.offerQuest('dishes');

      // Nothing is running, so there is nothing to pause - and the caller
      // must not flash "PAUSED" at someone whose run never stopped.
      expect(controller.hear('pause'), isNull);
      expect(state().phase, RunPhase.questOffered);
    });

    test('"not done" never records a completion', () {
      controller.offerQuest('dishes');
      controller.hear('next');

      expect(controller.hear("I'm not done"), isNull);
      expect(state().phase, RunPhase.running);
      expect(state().momentum, 0);
    });
  });

  group('the microphone button', () {
    Widget host(VoiceRecognizer recognizer) {
      return UncontrolledProviderScope(
        container: _container(recognizer),
        child: const MaterialApp(home: Scaffold(body: VoiceButton())),
      );
    }

    testWidgets('a device that cannot listen shows nothing at all',
        (tester) async {
      await tester.pumpWidget(host(FakeRecognizer(isAvailable: false)));
      await tester.pumpAndSettle();

      // Not a disabled button explaining what the user is missing: every
      // spoken command has a tap that does the same thing.
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('the default build cannot listen', (tester) async {
      await tester.pumpWidget(host(const UnavailableVoiceRecognizer()));
      await tester.pumpAndSettle();

      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('tapping starts and stops listening', (tester) async {
      final recognizer = FakeRecognizer();
      await tester.pumpWidget(host(recognizer));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(recognizer.started, isTrue);
      expect(find.byIcon(Icons.mic), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(recognizer.stopped, isTrue);
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('the microphone is released when the screen goes away',
        (tester) async {
      final recognizer = FakeRecognizer();
      await tester.pumpWidget(host(recognizer));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();

      expect(recognizer.stopped, isTrue);
    });
  });
}
