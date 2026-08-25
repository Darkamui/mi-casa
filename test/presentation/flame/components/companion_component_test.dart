import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/companion_component.dart';

void main() {
  testWithFlameGame('tapping invokes onTap', (game) async {
    var tapped = false;
    final idle = Sprite(await generateImage(96, 112));
    final celebrating = Sprite(await generateImage(96, 112));
    final component = CompanionComponent(
      idleSprite: idle,
      celebratingSprite: celebrating,
      position: Vector2(100, 100),
      onTap: () => tapped = true,
    );
    await game.ensureAdd(component);

    component.onTap();

    expect(tapped, isTrue);
  });

  testWithFlameGame('starts idle and switches sprite on mood change',
      (game) async {
    final idle = Sprite(await generateImage(96, 112));
    final celebrating = Sprite(await generateImage(96, 112));
    final component = CompanionComponent(
      idleSprite: idle,
      celebratingSprite: celebrating,
      position: Vector2.zero(),
      onTap: () {},
    );
    await game.ensureAdd(component);

    expect(component.mood, CompanionMood.idle);
    expect(component.sprite, idle);

    component.mood = CompanionMood.celebrating;

    expect(component.sprite, celebrating);
  });

  testWithFlameGame('anchors bottom-center per parent-doc §24', (game) async {
    final idle = Sprite(await generateImage(96, 112));
    final component = CompanionComponent(
      idleSprite: idle,
      celebratingSprite: idle,
      position: Vector2(50, 300),
      onTap: () {},
    );
    await game.ensureAdd(component);

    expect(component.anchor, Anchor.bottomCenter);
    expect(component.floorY, 300);
  });
}
