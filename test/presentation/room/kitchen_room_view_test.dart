import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/effects/particle_burst.dart';
import 'package:micasa/presentation/room/kitchen_room_view.dart';
import 'package:micasa/presentation/room/room_definition.dart';
import 'package:micasa/presentation/room/room_vitality.dart';

const _source = '''
{
  "id": "kitchen",
  "aspectRatio": 1.59879,
  "base": "content/art/kitchen/kitchen_room.png",
  "overlays": [
    { "id": "dish_pile", "asset": "content/art/props/dish_pile.png", "area": [0.5, 0.4, 0.2, 0.2] }
  ],
  "hotspots": [
    { "id": "sink", "label": "Dishes", "taskId": "t.a", "area": [0.5, 0.3, 0.2, 0.15] },
    { "id": "island", "label": "Wipe", "taskId": "t.b", "area": [0.3, 0.5, 0.4, 0.2] },
    { "id": "floor", "label": "Trash", "taskId": "t.c", "area": [0.0, 0.8, 0.3, 0.2] }
  ],
  "companionSpot": [0.87, 0.93]
}
''';

Widget _view({
  bool showAffordances = true,
  void Function(RoomHotspot)? onTap,
  RoomCelebration? celebration,
}) {
  return MaterialApp(
    home: KitchenRoomView(
      room: RoomDefinition.parse(_source),
      vitality: RoomVitality.slipping,
      showDishPile: true,
      companionMood: null,
      showAffordances: showAffordances,
      celebration: celebration,
      onHotspotTap: onTap,
    ),
  );
}

void main() {
  testWidgets('an idle room advertises every hotspot', (tester) async {
    await tester.pumpWidget(_view());
    await tester.pump();

    expect(find.byType(HotspotAffordance), findsNWidgets(3));
  });

  testWidgets('affordances go quiet when suppressed', (tester) async {
    // A card is up: the room should stop competing for attention.
    await tester.pumpWidget(_view(showAffordances: false));
    await tester.pump();

    expect(find.byType(HotspotAffordance), findsNothing);
  });

  testWidgets('affordances never intercept the tap they advertise',
      (tester) async {
    RoomHotspot? tapped;
    await tester.pumpWidget(_view(onTap: (h) => tapped = h));
    await tester.pump();

    // Tap dead centre of the sink hotspot - exactly where the glow sits.
    final size = tester.getSize(find.byType(KitchenRoomView));
    final frame = roomFrame(size, 1.59879);
    final origin = tester.getCenter(find.byType(KitchenRoomView));
    final rect = RoomDefinition.parse(_source).hotspotById('sink')!.resolve(frame);
    await tester.tapAt(
      origin - Offset(frame.width / 2, frame.height / 2) + rect.center,
    );

    expect(tapped?.id, 'sink');
  });

  testWidgets('every hotspot is reachable on a phone held upright',
      (tester) async {
    // 1440x3120 at 3x. Covering a 1.6:1 painting here kept under a third of
    // its width, which put the bin (x 0.03) and the back counter (x 1.0)
    // outside the screen with no way to reach them.
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final tapped = <String>[];
    await tester.pumpWidget(_view(onTap: (h) => tapped.add(h.id)));
    await tester.pump();

    final screen = tester.getRect(find.byType(KitchenRoomView));
    final frame = roomFrame(screen.size, 1.59879);
    final origin = screen.center - Offset(frame.width / 2, frame.height / 2);

    for (final hotspot in RoomDefinition.parse(_source).hotspots) {
      final at = origin + hotspot.resolve(frame).center;
      expect(screen.contains(at), isTrue,
          reason: '${hotspot.id} is off-screen at $at');
      await tester.tapAt(at);
    }

    expect(tapped, ['sink', 'island', 'floor']);
  });

  testWidgets('a quiet room celebrates nothing', (tester) async {
    await tester.pumpWidget(_view());
    await tester.pump();

    expect(find.byType(ParticleBurst), findsNothing);
  });

  testWidgets('the celebration lands where the work happened', (tester) async {
    // The sink, not the middle of the screen.
    final sink = RoomDefinition.parse(_source).hotspotById('sink')!;
    await tester.pumpWidget(_view(
      celebration: RoomCelebration(
        id: 1,
        spot: (x: sink.area.center.dx, y: sink.area.center.dy),
      ),
    ));
    await tester.pump();

    final size = tester.getSize(find.byType(KitchenRoomView));
    final frame = roomFrame(size, 1.59879);
    final origin = tester.getCenter(find.byType(KitchenRoomView));
    final expected = origin -
        Offset(frame.width / 2, frame.height / 2) +
        sink.resolve(frame).center;

    final actual = tester.getCenter(find.byType(ParticleBurst));
    expect((actual - expected).distance, lessThan(1.0));
  });

  testWidgets('a second completion restarts the burst rather than reusing it',
      (tester) async {
    const spot = (x: 0.5, y: 0.5);
    await tester
        .pumpWidget(_view(celebration: const RoomCelebration(id: 1, spot: spot)));
    await tester.pump(const Duration(milliseconds: 600));

    final first = tester.state(find.byType(ParticleBurst));

    await tester
        .pumpWidget(_view(celebration: const RoomCelebration(id: 2, spot: spot)));
    await tester.pump();

    // A new State object means the animation started over. Without the id in
    // the key, the second completion would inherit a burst already finished.
    expect(tester.state(find.byType(ParticleBurst)), isNot(same(first)));
  });
}
