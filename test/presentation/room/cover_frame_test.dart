import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/room/kitchen_room_view.dart';

const _kitchen = 1.59879;

void main() {
  test('a wider viewport is filled by matching width', () {
    // The old contain-fit left black bars down both sides here.
    final frame = coverFrame(const Size(1200, 600), _kitchen);

    expect(frame.width, 1200);
    expect(frame.height, closeTo(1200 / _kitchen, 1e-9));
    expect(frame.height, greaterThan(600), reason: 'must overflow, not letterbox');
  });

  test('a taller viewport is filled by matching height', () {
    final frame = coverFrame(const Size(600, 900), _kitchen);

    expect(frame.height, 900);
    expect(frame.width, closeTo(900 * _kitchen, 1e-9));
    expect(frame.width, greaterThan(600));
  });

  test('the cover frame never distorts', () {
    const viewports = [
      Size(1280, 720),
      Size(390, 844),
      Size(1586, 992),
      Size(2000, 500),
    ];

    for (final viewport in viewports) {
      final frame = coverFrame(viewport, _kitchen);

      expect(frame.width, greaterThanOrEqualTo(viewport.width - 1e-9),
          reason: 'gap at the sides for $viewport');
      expect(frame.height, greaterThanOrEqualTo(viewport.height - 1e-9),
          reason: 'gap at top/bottom for $viewport');
      expect(frame.width / frame.height, closeTo(_kitchen, 1e-9),
          reason: 'aspect drifted for $viewport');
    }
  });

  test('an exactly-matching viewport is used as-is', () {
    final frame = coverFrame(const Size(1586, 992), _kitchen);

    expect(frame.width, closeTo(1586, 0.01));
    expect(frame.height, closeTo(992, 0.01));
  });

  group('the frame the room is actually drawn in', () {
    test('a near-matching window is still filled edge to edge', () {
      // A desktop window is close enough to the painting that letterboxing
      // it would frame the room like a video.
      for (final viewport in const [
        Size(1586, 992),
        Size(1280, 720),
        Size(1200, 600),
        Size(800, 600),
      ]) {
        final frame = roomFrame(viewport, _kitchen);

        expect(frame.width, greaterThanOrEqualTo(viewport.width - 1e-9),
            reason: 'gap at the sides for $viewport');
        expect(frame.height, greaterThanOrEqualTo(viewport.height - 1e-9),
            reason: 'gap at top/bottom for $viewport');
      }
    });

    test('a phone held upright shows the whole painting', () {
      // 1440x3120 at 3x. Covering this keeps under a third of the width -
      // an aggressive zoom into one corner, with two of the four kitchen
      // hotspots pushed off-screen.
      const viewport = Size(480, 1040);
      final frame = roomFrame(viewport, _kitchen);

      expect(frame.width, closeTo(480, 1e-9), reason: 'nothing may be cropped');
      expect(frame.height, closeTo(480 / _kitchen, 1e-9));
      expect(frame.height, lessThan(1040));
    });

    test('never crops more than a quarter away', () {
      const viewports = [
        Size(1586, 992),
        Size(1280, 720),
        Size(1200, 600),
        Size(800, 600),
        Size(480, 1040),
        Size(390, 844),
        Size(2000, 500),
        Size(1040, 480),
      ];

      for (final viewport in viewports) {
        final frame = roomFrame(viewport, _kitchen);

        expect(frame.width / frame.height, closeTo(_kitchen, 1e-9),
            reason: 'aspect drifted for $viewport');
        // Either axis losing more than a quarter means tappable room is
        // being hidden, not margin.
        expect(1 - viewport.width / frame.width, lessThanOrEqualTo(0.25 + 1e-9),
            reason: 'cropped too much width at $viewport');
        expect(
            1 - viewport.height / frame.height, lessThanOrEqualTo(0.25 + 1e-9),
            reason: 'cropped too much height at $viewport');
      }
    });
  });
}
