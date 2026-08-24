import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/companion_component.dart';
import 'package:micasa/presentation/flame/components/prop_sprite_component.dart';
import 'package:micasa/presentation/flame/components/restoration_effect_component.dart';
import 'package:micasa/presentation/flame/layers/back_layer.dart';
import 'package:micasa/presentation/flame/layers/character_layer.dart';
import 'package:micasa/presentation/flame/layers/decor_layer.dart';
import 'package:micasa/presentation/flame/layers/effects_layer.dart';
import 'package:micasa/presentation/flame/layers/entropy_layer.dart';
import 'package:micasa/presentation/flame/layers/foreground_layer.dart';
import 'package:micasa/presentation/flame/layers/furniture_layer.dart';
import 'package:micasa/presentation/flame/layers/mid_layer.dart';

Future<PropSpriteComponent> _prop() async => PropSpriteComponent(
      sprite: Sprite(await generateImage(32, 32)),
      position: Vector2.zero(),
    );

void main() {
  testWithFlameGame('BackLayer holds its given props', (game) async {
    final layer = BackLayer(props: [await _prop(), await _prop()]);
    await game.ensureAdd(layer);

    expect(layer.children.length, 2);
  });

  testWithFlameGame('FurnitureLayer, MidLayer, DecorLayer hold their props',
      (game) async {
    final furniture = FurnitureLayer(props: [await _prop()]);
    final mid = MidLayer(props: [await _prop()]);
    final decor = DecorLayer(props: [await _prop(), await _prop()]);
    await game.ensureAddAll([furniture, mid, decor]);

    expect(furniture.children.length, 1);
    expect(mid.children.length, 1);
    expect(decor.children.length, 2);
  });

  testWithFlameGame('EntropyLayer starts with given props and can be replaced',
      (game) async {
    final layer = EntropyLayer(props: [await _prop()]);
    await game.ensureAdd(layer);
    expect(layer.children.length, 1);

    await layer.setProps([await _prop(), await _prop()]);
    game.update(0);

    expect(layer.children.length, 2);
  });

  testWithFlameGame('EntropyLayer.setProps can clear to empty', (game) async {
    final layer = EntropyLayer(props: [await _prop()]);
    await game.ensureAdd(layer);

    await layer.setProps(const []);
    game.update(0);

    expect(layer.children.length, 0);
  });

  testWithFlameGame('CharacterLayer holds the companion', (game) async {
    final companion = CompanionComponent(
      idleSprite: Sprite(await generateImage(32, 32)),
      celebratingSprite: Sprite(await generateImage(32, 32)),
      position: Vector2.zero(),
      onTap: () {},
    );
    final layer = CharacterLayer(companion: companion);
    await game.ensureAdd(layer);

    expect(layer.children.length, 1);
    expect(layer.companion, companion);
  });

  testWithFlameGame('EffectsLayer holds the restoration effect', (game) async {
    final effect = RestorationEffectComponent(position: Vector2.zero());
    final layer = EffectsLayer(restorationEffect: effect);
    await game.ensureAdd(layer);

    expect(layer.children.length, 1);
    expect(layer.restorationEffect, effect);
  });

  testWithFlameGame('ForegroundLayer starts empty', (game) async {
    final layer = ForegroundLayer();
    await game.ensureAdd(layer);

    expect(layer.children.length, 0);
  });
}
