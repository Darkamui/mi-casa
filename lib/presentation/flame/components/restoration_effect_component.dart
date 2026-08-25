import 'dart:ui';

import 'package:flame/components.dart';

import '../../effects/particle_burst.dart' show Particle, generateBurstParticles;

/// Flame version of ParticleBurst — needs a world position (the
/// restoration anchor), not a screen position, so it moves into
/// EffectsLayer as a component instead of a Stack-positioned widget.
/// Reuses the existing pure generateBurstParticles/Particle rather than
/// duplicating burst logic.
class RestorationEffectComponent extends PositionComponent {
  RestorationEffectComponent({required Vector2 position})
      : super(position: position, size: Vector2.zero());

  static const double _duration = 0.9;

  List<Particle> _particles = const [];
  double _elapsed = _duration;

  bool get isActive => _elapsed < _duration;

  void fire() {
    _particles = generateBurstParticles(seed: DateTime.now().millisecondsSinceEpoch);
    _elapsed = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_elapsed < _duration) {
      _elapsed += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;
    final progress = (_elapsed / _duration).clamp(0.0, 1.0);
    for (final particle in _particles) {
      final offset = particle.direction * (particle.speed * progress);
      final opacity = (1 - progress).clamp(0.0, 1.0);
      canvas.drawCircle(
        offset,
        4,
        Paint()..color = particle.color.withValues(alpha: opacity),
      );
    }
  }
}
