import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/parallax_controller.dart';

void main() {
  test('scales drag offset by the layer rate', () {
    final offset = computeParallaxOffset(
      dragOffset: Vector2(10, 0),
      layerRate: 0.5,
    );

    expect(offset.x, closeTo(5.0, 0.0001));
    expect(offset.y, closeTo(0.0, 0.0001));
  });

  test('clamps the result to maxOffset while preserving direction', () {
    final offset = computeParallaxOffset(
      dragOffset: Vector2(100, 0),
      layerRate: 0.8,
      maxOffset: 12.0,
    );

    expect(offset.length, closeTo(12.0, 0.0001));
    expect(offset.x, greaterThan(0));
  });

  test('zero drag produces zero offset', () {
    final offset = computeParallaxOffset(
      dragOffset: Vector2.zero(),
      layerRate: 0.65,
    );

    expect(offset, Vector2.zero());
  });

  test('a lower layer rate moves less than a higher one for the same drag', () {
    final drag = Vector2(20, 0);
    final back = computeParallaxOffset(dragOffset: drag, layerRate: 0.15);
    final foreground = computeParallaxOffset(dragOffset: drag, layerRate: 0.80);

    expect(back.length, lessThan(foreground.length));
  });
}
