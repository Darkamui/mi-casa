import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/feedback/haptics.dart';
import 'package:micasa/presentation/room/kitchen_room_view.dart';
import 'package:micasa/presentation/room/room_definition.dart';
import 'package:micasa/presentation/room/room_definition_loader.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';
import 'package:micasa/presentation/screens/kitchen_screen.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/models/task_definition.dart';

/// The room is the screen (direction doc §1). Not a banner across the top of
/// it, and not something that changes size when a card opens.
///
/// Scaffold hands its body loose constraints, so a bare Stack shrinks to its
/// largest non-positioned child. That was the vitality chip - which pinned
/// the whole kitchen into a strip at the top of the phone, then let it snap
/// to full height the moment a centred card appeared.
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

void main() {
  late ProviderContainer container;

  // Read from disk rather than through the asset bundle: a bundle read is a
  // real async round trip that does not settle under a pumped fake clock, and
  // this file is about how the room is laid out, not how it is loaded.
  final room = RoomDefinition.parse(
    File('content/rooms/kitchen_room.json').readAsStringSync(),
  );

  Future<void> openRoom(WidgetTester tester, Size physical) async {
    tester.view.physicalSize = physical;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    container = ProviderContainer(overrides: [
      kitchenEngineProvider.overrideWith((ref) async => _engine),
      kitchenRepositoryProvider.overrideWithValue(null),
      clockProvider.overrideWithValue(() => DateTime.utc(2026, 8, 25, 12)),
      hapticsProvider.overrideWithValue(const SilentHaptics()),
      roomDefinitionProvider.overrideWith((ref, roomId) => room),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: KitchenScreen()),
    ));
    // Not pumpAndSettle: the hotspot affordances pulse forever by design.
    // One frame for the engine future, one for the room to build in.
    await tester.pump();
    await tester.pump();
    expect(find.byType(KitchenRoomView), findsOneWidget);
  }

  testWidgets('the room is the whole screen, upright', (tester) async {
    await openRoom(tester, const Size(1440, 3120));

    expect(
      tester.getSize(find.byType(KitchenRoomView)),
      tester.getSize(find.byType(KitchenScreen)),
    );
  });

  testWidgets('the room is the whole screen, on its side', (tester) async {
    await openRoom(tester, const Size(3120, 1440));

    expect(
      tester.getSize(find.byType(KitchenRoomView)),
      tester.getSize(find.byType(KitchenScreen)),
    );
  });

  testWidgets('opening a quest does not resize the room', (tester) async {
    await openRoom(tester, const Size(1440, 3120));

    final before = tester.getRect(find.byType(KitchenRoomView));

    container.read(kitchenSessionProvider.notifier).offerQuest('kitchen.dishes');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // A room that jumps when a card opens reads as a violent zoom, and the
    // hotspots move out from under the finger that was aiming at them.
    expect(tester.getRect(find.byType(KitchenRoomView)), before);
  });
}
