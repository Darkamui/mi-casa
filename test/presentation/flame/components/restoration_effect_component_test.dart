import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/restoration_effect_component.dart';

void main() {
  testWithFlameGame('is inert until fire() is called', (game) async {
    final component = RestorationEffectComponent(position: Vector2(50, 50));
    await game.ensureAdd(component);

    game.update(0.5);

    expect(component.isActive, isFalse);
  });

  testWithFlameGame('fire() makes it active, and it expires after its duration',
      (game) async {
    final component = RestorationEffectComponent(position: Vector2(50, 50));
    await game.ensureAdd(component);

    component.fire();
    expect(component.isActive, isTrue);

    game.update(1.0);
    expect(component.isActive, isFalse);
  });
}
