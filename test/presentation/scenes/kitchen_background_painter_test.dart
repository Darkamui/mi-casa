import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/kitchen_background_painter.dart';

void main() {
  test('shouldRepaint is true when restored flag changes', () {
    const messy = KitchenBackgroundPainter(restored: false);
    const clean = KitchenBackgroundPainter(restored: true);

    expect(messy.shouldRepaint(clean), isTrue);
  });

  test('shouldRepaint is false when restored flag is unchanged', () {
    const messyA = KitchenBackgroundPainter(restored: false);
    const messyB = KitchenBackgroundPainter(restored: false);

    expect(messyA.shouldRepaint(messyB), isFalse);
  });

  test('paint does not throw for either state', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    const KitchenBackgroundPainter(restored: false)
        .paint(canvas, const Size(300, 500));
    const KitchenBackgroundPainter(restored: true)
        .paint(canvas, const Size(300, 500));

    recorder.endRecording();
  });
}
