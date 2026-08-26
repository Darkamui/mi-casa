import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/audio/room_audio.dart';
import 'package:micasa/presentation/feedback/haptics.dart';
import 'package:micasa/presentation/room/room_definition.dart';
import 'package:micasa/presentation/room/room_definition_loader.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';
import 'package:micasa/presentation/screens/kitchen_screen.dart';
import 'package:micasa/presentation/widgets/mute_button.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/models/task_definition.dart';

/// Records what the room asked for, without making a sound.
class RecordingAudio implements RoomAudio {
  final List<String> log = [];
  bool muted = false;

  @override
  void startMusic() => log.add('music.start');

  @override
  void stopMusic() => log.add('music.stop');

  @override
  void setMuted(bool value) {
    muted = value;
    log.add('mute.$value');
  }

  @override
  void play(AudioCue cue) => log.add('cue.${cue.name}');

  @override
  void dispose() {}
}

const _tasks = [
  TaskDefinition(
    id: 'kitchen.dishes',
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

final _t0 = DateTime.utc(2026, 8, 26, 12);

void main() {
  late RecordingAudio audio;
  late ProviderContainer container;
  late KitchenSceneController controller;

  // Off disk rather than through the asset bundle: a bundle read does not
  // settle under a pumped fake clock, and none of this is about loading.
  final room = RoomDefinition.parse(
    File('content/rooms/kitchen_room.json').readAsStringSync(),
  );

  Future<void> openRoom(WidgetTester tester) async {
    audio = RecordingAudio();
    container = ProviderContainer(overrides: [
      kitchenEngineProvider.overrideWith((ref) async => _engine),
      kitchenRepositoryProvider.overrideWithValue(null),
      clockProvider.overrideWithValue(() => _t0),
      hapticsProvider.overrideWithValue(const SilentHaptics()),
      roomAudioProvider.overrideWithValue(audio),
      roomDefinitionProvider.overrideWith((ref, roomId) => room),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: KitchenScreen()),
    ));
    // Not pumpAndSettle: the hotspot affordances pulse forever by design.
    await tester.pump();
    await tester.pump();

    controller = container.read(kitchenSessionProvider.notifier);
  }

  Future<void> startRun(WidgetTester tester) async {
    controller.offerQuest('kitchen.dishes');
    controller.startRun();
    await tester.pump();
  }

  group('the bed under a run (spec 4.2)', () {
    testWidgets('nothing plays until the clock is running', (tester) async {
      await openRoom(tester);

      // An idle room is silent. Music that starts when the app opens is
      // music the user has to go and turn off before they can think.
      expect(audio.log, isEmpty);

      controller.offerQuest('kitchen.dishes');
      await tester.pump();
      expect(audio.log, isEmpty, reason: 'an offer is not a run');
    });

    testWidgets('starting a run starts the music', (tester) async {
      await openRoom(tester);
      await startRun(tester);

      expect(audio.log, ['music.start']);
    });

    testWidgets('pausing stops it, resuming brings it back', (tester) async {
      await openRoom(tester);
      await startRun(tester);

      controller.pauseRun();
      await tester.pump();
      // A paused clock that keeps humming still says "you are on the hook".
      expect(audio.log.last, 'music.stop');

      controller.resumeRun();
      await tester.pump();
      expect(audio.log.last, 'music.start');
    });

    testWidgets('finishing the task stops it', (tester) async {
      await openRoom(tester);
      await startRun(tester);

      controller.completeTask();
      await tester.pump();

      expect(audio.log.last, 'music.stop');
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('the mute button is always reachable', (tester) async {
      await openRoom(tester);

      // Not behind a settings screen, and not only while something is
      // playing: sound that starts on its own must be stoppable from where
      // it started.
      expect(find.byType(MuteButton), findsOneWidget);

      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pump();

      expect(audio.muted, isTrue);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pump();
      expect(audio.muted, isFalse);
    });
  });

  group('the companion answers, and that is all (spec 2.2)', () {
    testWidgets('tapping it makes a sound', (tester) async {
      await openRoom(tester);

      final companion = find.byWidgetPredicate(
        (w) => w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.contains('companion'),
      );
      await tester.tap(companion.first, warnIfMissed: false);
      await tester.pump();

      expect(audio.log, contains('cue.companion'));
    });

    testWidgets('tapping it does not hand out a chore', (tester) async {
      await openRoom(tester);

      final companion = find.byWidgetPredicate(
        (w) => w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.contains('companion'),
      );
      await tester.tap(companion.first, warnIfMissed: false);
      await tester.pump();

      // The one warm, no-stakes thing on the screen. Petting it used to open
      // the room's most neglected task, which made the only safe place to
      // put a finger nowhere at all.
      expect(
        container.read(kitchenSessionProvider).valueOrNull?.phase,
        RunPhase.idle,
      );
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
