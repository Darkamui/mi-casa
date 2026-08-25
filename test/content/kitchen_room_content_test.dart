import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/room/room_definition.dart';

/// Guards the authored room data itself, not the code that reads it.
/// Hotspot areas are hand-placed against the painting, so the mistakes
/// they invite are geometric ones a type system will never catch.
void main() {
  late RoomDefinition room;

  setUpAll(() {
    room = RoomDefinition.parse(
      File('content/rooms/kitchen_room.json').readAsStringSync(),
    );
  });

  test('no two hotspots overlap', () {
    // Overlapping rects are silently resolved by stack order, so the
    // hotspot authored first quietly loses its taps to a later one.
    for (var i = 0; i < room.hotspots.length; i++) {
      for (var j = i + 1; j < room.hotspots.length; j++) {
        final a = room.hotspots[i];
        final b = room.hotspots[j];
        expect(a.area.overlaps(b.area), isFalse,
            reason: '${a.id} and ${b.id} overlap; ${b.id} would steal '
                'the shared taps');
      }
    }
  });

  test('every hotspot sits inside the painting', () {
    const frame = Rect.fromLTWH(0, 0, 1, 1);
    for (final hotspot in room.hotspots) {
      expect(frame.contains(hotspot.area.topLeft), isTrue,
          reason: '${hotspot.id} starts outside the room');
      expect(hotspot.area.right, lessThanOrEqualTo(1.0),
          reason: '${hotspot.id} runs off the right edge');
      expect(hotspot.area.bottom, lessThanOrEqualTo(1.0),
          reason: '${hotspot.id} runs off the bottom edge');
    }
  });

  test('every hotspot is big enough to hit', () {
    // Roughly a finger's width against the shortest sensible render.
    for (final hotspot in room.hotspots) {
      expect(hotspot.area.width, greaterThan(0.05), reason: hotspot.id);
      expect(hotspot.area.height, greaterThan(0.05), reason: hotspot.id);
    }
  });

  test('every referenced asset exists on disk', () {
    expect(File(room.baseAsset).existsSync(), isTrue,
        reason: 'missing ${room.baseAsset}');
    for (final overlay in room.overlays) {
      expect(File(overlay.asset).existsSync(), isTrue,
          reason: 'missing ${overlay.asset}');
    }
  });

  test('the companion stands inside the room', () {
    expect(room.companionSpot.x, inInclusiveRange(0.0, 1.0));
    expect(room.companionSpot.y, inInclusiveRange(0.0, 1.0));
  });

  test('nothing important hides in the part a phone crops away', () {
    // The painting fills the screen, so the narrowest phone in circulation -
    // 20:9 - decides how much of its width survives. Anything authored into
    // the margins is unreachable there, and a hotspot nobody can tap is
    // worse than one that was never drawn.
    const narrowestPhone = 9 / 20;
    final visible = (narrowestPhone / room.aspectRatio).clamp(0.0, 1.0);
    final margin = (1 - visible) / 2;

    for (final hotspot in room.hotspots) {
      expect(hotspot.area.center.dx, inInclusiveRange(margin, 1 - margin),
          reason: '${hotspot.id} is cropped off a tall phone');
    }
    expect(room.companionSpot.x, inInclusiveRange(margin, 1 - margin),
        reason: 'the companion is cropped off a tall phone');
  });
}
