import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/effects/particle_burst.dart';

void main() {
  test('generates the requested particle count', () {
    final particles = generateBurstParticles(count: 10, seed: 1);

    expect(particles.length, 10);
  });

  test('is deterministic for a fixed seed', () {
    final a = generateBurstParticles(count: 5, seed: 42);
    final b = generateBurstParticles(count: 5, seed: 42);

    for (var i = 0; i < a.length; i++) {
      expect(a[i].direction, b[i].direction);
      expect(a[i].speed, b[i].speed);
      expect(a[i].color, b[i].color);
    }
  });

  testWidgets('builds without error when inactive and active', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ParticleBurst(active: false)),
    ));
    expect(find.byType(ParticleBurst), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ParticleBurst(active: true)),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(ParticleBurst), findsOneWidget);
  });
}
