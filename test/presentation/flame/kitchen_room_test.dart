import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/companion_component.dart';
import 'package:micasa/presentation/flame/kitchen_room.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Rendered props live under content/art/rendered/props/, not Flame's
  // default assets/images/ prefix — KitchenGame.onLoad sets this in the
  // real app; tests that construct KitchenRoom directly need it too.
  Flame.images.prefix = '';

  testWithFlameGame('create() builds all 8 layers as children', (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    expect(room.children.length, 8);
  });

  testWithFlameGame('starts in the messy clutter state (scripted demo, spec §8)',
      (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    expect(room.entropyLayer.children.length, 1);
  });

  testWithFlameGame('setClutterState(pristine) empties the entropy layer',
      (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    await room.setClutterState('pristine');
    game.update(0);

    expect(room.entropyLayer.children.length, 0);
  });

  testWithFlameGame(
      'celebrateCompletion clears clutter, fires effects, and celebrates the companion',
      (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    await room.celebrateCompletion();
    game.update(0);

    expect(room.entropyLayer.children.length, 0);
    expect(room.effectsLayer.restorationEffect.isActive, isTrue);
    expect(room.characterLayer.companion.mood, CompanionMood.celebrating);
  });

  testWithFlameGame('applyParallax offsets layers by their configured rate',
      (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    room.applyParallax(Vector2(10, 0));

    expect(room.backLayer.position.x, greaterThan(0));
    expect(room.foregroundLayer.position.x,
        greaterThan(room.backLayer.position.x));
  });
}
