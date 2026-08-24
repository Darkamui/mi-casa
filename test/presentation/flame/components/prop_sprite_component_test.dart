import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/prop_sprite_component.dart';

void main() {
  testWithFlameGame('floorContact anchors bottom-center at position',
      (game) async {
    final image = await generateImage(64, 96);
    final component = PropSpriteComponent(
      sprite: Sprite(image),
      position: Vector2(100, 200),
    );
    await game.ensureAdd(component);

    expect(component.anchor, Anchor.bottomCenter);
    expect(component.floorY, 200);
  });

  testWithFlameGame('verticalCenter anchors center at position',
      (game) async {
    final image = await generateImage(64, 96);
    final component = PropSpriteComponent(
      sprite: Sprite(image),
      position: Vector2(100, 200),
      pivot: PropPivot.verticalCenter,
    );
    await game.ensureAdd(component);

    expect(component.anchor, Anchor.center);
    expect(component.floorY, 200 + component.size.y / 2);
  });

  testWithFlameGame('size matches the sprite source size', (game) async {
    final image = await generateImage(64, 96);
    final component = PropSpriteComponent(
      sprite: Sprite(image),
      position: Vector2.zero(),
    );
    await game.ensureAdd(component);

    expect(component.size, Vector2(64, 96));
  });
}
