import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/dish_pile_painter.dart';

void main() {
  test('has four dish offsets', () {
    expect(DishPilePainter.dishOffsets.length, 4);
  });

  test('shouldRepaint is always false (static content)', () {
    const a = DishPilePainter();
    const b = DishPilePainter();

    expect(a.shouldRepaint(b), isFalse);
  });

  test('paint does not throw', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    const DishPilePainter().paint(canvas, const Size(120, 80));

    recorder.endRecording();
  });
}
