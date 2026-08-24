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

class ParticleBurst extends StatefulWidget {
  final bool active;
  const ParticleBurst({super.key, required this.active});

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<Particle> _particles = const [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    if (widget.active) _fire();
  }

  @override
  void didUpdateWidget(covariant ParticleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _fire();
  }

  void _fire() {
    _particles = generateBurstParticles(seed: DateTime.now().millisecondsSinceEpoch);
    _controller.forward(from: 0);
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
        builder: (context, _) => CustomPaint(
          painter: ParticlePainter(particles: _particles, progress: _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  const ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final position = center + particle.direction * distance;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      canvas.drawCircle(position, 4, Paint()..color = particle.color.withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
