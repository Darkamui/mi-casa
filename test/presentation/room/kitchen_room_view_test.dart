import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

Widget _view({bool showAffordances = true, void Function(RoomHotspot)? onTap}) {
  return MaterialApp(
    home: KitchenRoomView(
      room: RoomDefinition.parse(_source),
      vitality: RoomVitality.slipping,
      showDishPile: true,
      companionMood: null,
      showAffordances: showAffordances,
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
    final frame = coverFrame(size, 1.59879);
    final origin = tester.getCenter(find.byType(KitchenRoomView));
    final rect = RoomDefinition.parse(_source).hotspotById('sink')!.resolve(frame);
    await tester.tapAt(
      origin - Offset(frame.width / 2, frame.height / 2) + rect.center,
    );

    expect(tapped?.id, 'sink');
  });
}
