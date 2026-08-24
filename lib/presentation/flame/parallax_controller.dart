import 'package:flame/extensions.dart';

/// Maps a drag delta and a per-layer parallax rate to a clamped render
/// offset (parent doc §18's example table: background 0.15x, back
/// furniture 0.30x, mid furniture 0.50x, characters 0.65x, foreground
/// 0.80x). Pure — no Flame instance required. Offset direction is
/// preserved when clamped.
Vector2 computeParallaxOffset({
  required Vector2 dragOffset,
  required double layerRate,
  double maxOffset = 12.0,
}) {
  final raw = dragOffset * layerRate;
  final magnitude = raw.length;
  if (magnitude <= maxOffset || magnitude == 0) {
    return raw;
  }
  return raw * (maxOffset / magnitude);
}
