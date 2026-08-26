import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/room/room_definition.dart';

const _source = '''
{
  "id": "kitchen",
  "aspectRatio": 1.59879,
  "base": "art/kitchen.png",
  "overlays": [
    { "id": "dish_pile", "asset": "art/dishes.png", "area": [0.5, 0.25, 0.2, 0.1] }
  ],
  "hotspots": [
    { "id": "sink", "label": "Dishes", "taskId": "kitchen.dishes",
      "area": [0.5, 0.4, 0.2, 0.2] }
  ],
  "companionSpot": [0.7, 0.8]
}
''';

void main() {
  test('parses layers, overlays, hotspots, and the companion spot', () {
    final room = RoomDefinition.parse(_source);

    expect(room.id, 'kitchen');
    expect(room.aspectRatio, closeTo(1.59879, 1e-9));
    expect(room.baseAsset, 'art/kitchen.png');
    expect(room.hotspots.single.taskId, 'kitchen.dishes');
    expect(room.overlays.single.asset, 'art/dishes.png');
    expect(room.companionSpot.x, 0.7);
    expect(room.companionSpot.y, 0.8);
  });

  test('hotspot areas are normalised and resolve against any frame size', () {
    final hotspot = RoomDefinition.parse(_source).hotspotById('sink')!;

    // The same authored data must land correctly at any render size —
    // that is the whole point of storing fractions rather than pixels.
    final small = hotspot.resolve(const Size(100, 100));
    expect(small.left, 50);
    expect(small.width, 20);

    final large = hotspot.resolve(const Size(1000, 500));
    expect(large.left, 500);
    expect(large.top, 200);
    expect(large.width, 200);
    expect(large.height, 100);
  });

  test('overlay areas resolve the same way', () {
    final overlay = RoomDefinition.parse(_source).overlayById('dish_pile')!;
    final rect = overlay.resolve(const Size(200, 200));

    expect(rect.left, 100);
    expect(rect.top, 50);
    expect(rect.width, 40);
    expect(rect.height, 20);
  });

  test('lookups return null for ids the room does not define', () {
    final room = RoomDefinition.parse(_source);

    expect(room.hotspotById('nope'), isNull);
    expect(room.overlayById('nope'), isNull);
  });

  test('a malformed area is rejected rather than silently mispositioned', () {
    const bad = '''
    {
      "id": "x", "aspectRatio": 1.0,
      "base": "b.png",
      "hotspots": [{"id":"a","label":"A","taskId":"t","area":[0.1,0.2]}],
      "companionSpot": [0.5, 0.5]
    }
    ''';

    expect(() => RoomDefinition.parse(bad), throwsFormatException);
  });
}
