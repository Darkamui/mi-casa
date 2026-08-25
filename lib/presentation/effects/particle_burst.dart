import 'dart:math' as math;

import 'package:flutter/material.dart';

class Particle {
  final Offset direction;
  final double speed;
  final Color color;
  const Particle({required this.direction, required this.speed, required this.color});
}

List<Particle> generateBurstParticles({int count = 24, required int seed}) {
  final random = math.Random(seed);
  const colors = [Color(0xFFFFD27D), Color(0xFFFFF3C4), Color(0xFFFFB870)];

  return List.generate(count, (i) {
    final angle = random.nextDouble() * 2 * math.pi;
    return Particle(
      direction: Offset(math.cos(angle), math.sin(angle)),
      speed: 40 + random.nextDouble() * 60,
      color: colors[random.nextInt(colors.length)],
    );
  });
}

/// The burst that fires where a task was just finished (spec §4.1).
///
/// Warm motes thrown outward that drift up rather than falling: this is the
/// room exhaling, not confetti dropping on it. Plays once and stops - nothing
/// here loops, so it cannot become ambient noise.
class ParticleBurst extends StatefulWidget {
  const ParticleBurst({
    super.key,
    required this.seed,
    this.count = 24,
    this.duration = const Duration(milliseconds: 1100),
  });

  /// Varies the spray between completions so the effect never reads as a
  /// canned stamp, while staying deterministic for a given completion.
  final int seed;

  final int count;
  final Duration duration;

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final List<Particle> _particles =
      generateBurstParticles(count: widget.count, seed: widget.seed);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _BurstPainter(_particles, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter(this.particles, this.t);

  final List<Particle> particles;

  /// 0..1 through the burst.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0) return;
    final centre = size.center(Offset.zero);

    // Fast out, slow down: the throw happens at the moment of DONE.
    final travel = Curves.easeOutCubic.transform(t);
    final fade = t < 0.55 ? 1.0 : 1 - ((t - 0.55) / 0.45);
    final lift = -18 * t;

    for (final particle in particles) {
      final offset = centre +
          particle.direction * particle.speed * travel +
          Offset(0, lift);
      canvas.drawCircle(
        offset,
        (1 - t * 0.6) * 2.6,
        Paint()
          ..color = particle.color.withValues(alpha: fade.clamp(0.0, 1.0) * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
