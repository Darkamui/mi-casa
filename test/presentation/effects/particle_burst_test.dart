import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/effects/particle_burst.dart';

void main() {
  test('a burst is deterministic for a given completion', () {
    final a = generateBurstParticles(seed: 7);
    final b = generateBurstParticles(seed: 7);
    final other = generateBurstParticles(seed: 8);

    expect(a.map((p) => p.direction), b.map((p) => p.direction));
    expect(a.map((p) => p.direction), isNot(other.map((p) => p.direction)));
  });

  test('particles are thrown in every direction, not one', () {
    final particles = generateBurstParticles(count: 40, seed: 3);

    expect(particles.any((p) => p.direction.dx > 0.5), isTrue);
    expect(particles.any((p) => p.direction.dx < -0.5), isTrue);
    expect(particles.any((p) => p.direction.dy > 0.5), isTrue);
    expect(particles.any((p) => p.direction.dy < -0.5), isTrue);
  });

  testWidgets('the burst plays once and stops', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: ParticleBurst(seed: 1))),
    ));

    // If it looped, there would be no steady state to settle into and this
    // would time out. Celebration is a moment, not an ambience.
    await tester.pumpAndSettle();
    expect(find.byType(ParticleBurst), findsOneWidget);
  });
}
