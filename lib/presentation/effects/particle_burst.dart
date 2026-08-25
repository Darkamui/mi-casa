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
