import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'room_vitality.dart';

/// The room breathing (direction doc §7, §8).
///
/// [VitalityTreatment] has always declared `ambientSparkles`, and nothing
/// ever drew them - so a Thriving kitchen and a Critical one differed only in
/// colour and sat equally still. §7's dimmer is *colour, warmth, and ambient
/// motion*; this is the third one.
///
/// Two things, both cheap and both slow. The light through the window swells
/// and settles on a long cycle, and when the room is being looked after,
/// motes drift up through it. Nothing here is interactive and nothing here
/// reacts to the simulation beyond the treatment it is handed: it is the
/// difference between a photograph of a room and a room.
class AmbientLife extends StatefulWidget {
  const AmbientLife({
    super.key,
    required this.treatment,
    required this.lightSpot,
  });

  final VitalityTreatment treatment;

  /// Where the room's own light source sits, normalised. Data, not code -
  /// it is a fact about the painting (see [RoomDefinition.lightSpot]).
  final ({double x, double y}) lightSpot;

  @override
  State<AmbientLife> createState() => _AmbientLifeState();
}

class _AmbientLifeState extends State<AmbientLife>
    with SingleTickerProviderStateMixin {
  /// Long enough that the eye never catches the loop. A room that pulses on
  /// a noticeable beat is a screensaver.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
            painter: _AmbientPainter(
              t: _controller.value,
              treatment: widget.treatment,
              spot: widget.lightSpot,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({
    required this.t,
    required this.treatment,
    required this.spot,
  });

  /// 0..1 through the cycle.
  final double t;
  final VitalityTreatment treatment;
  final ({double x, double y}) spot;

  /// How alive the room is allowed to look, 0..1. A neglected room does not
  /// go still all at once - it just stops shimmering.
  double get _life => ((treatment.saturation - 0.5) / 0.62).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(spot.x * size.width, spot.y * size.height);
    final breath = 0.5 + 0.5 * math.sin(t * 2 * math.pi);

    // The light swells and settles. Small on purpose: this must read as the
    // sun moving behind leaves, never as a fade.
    final glow = (0.05 + 0.07 * breath) * _life;
    if (glow > 0.002) {
      final radius = size.shortestSide * (0.55 + 0.05 * breath);
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFE2A6).withValues(alpha: glow),
              const Color(0xFFFFD27D).withValues(alpha: glow * 0.25),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: centre, radius: radius)),
      );
    }

    if (!treatment.ambientSparkles) return;

    // Motes, rising and fading through the light. Seeded off their own index
    // so the drift is fixed rather than random per frame - dust that jitters
    // is snow.
    final mote = Paint()..color = Colors.white;
    for (var i = 0; i < 22; i++) {
      final seed = i * 0.61803398875;
      final phase = (t + seed) % 1.0;

      final x = centre.dx +
          (seed % 1.0 - 0.5) * size.width * 0.78 +
          math.sin((t * 2 * math.pi) + i) * size.width * 0.012;
      final y = size.height * (0.9 - phase * 0.72) + (seed % 0.31) * 60;

      // In at the bottom, out at the top - never a mote blinking out mid-air.
      final fade = math.sin(phase * math.pi);
      canvas.drawCircle(
        Offset(x, y),
        0.9 + (seed % 0.9),
        mote..color = Colors.white.withValues(alpha: 0.16 * fade * _life),
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) =>
      old.t != t || old.treatment != treatment || old.spot != spot;
}
