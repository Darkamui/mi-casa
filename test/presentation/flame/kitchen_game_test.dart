import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/kitchen_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame<KitchenGame>(
    'onLoad builds the kitchen room and adds it to the world',
    () => KitchenGame(onCompanionTap: () {}),
    (game) async {
      expect(game.kitchenRoom.isMounted, isTrue);
      expect(game.world.children.contains(game.kitchenRoom), isTrue);
    },
  );

  testWithGame<KitchenGame>(
    'dragging accumulates offset that feeds into room parallax',
    () => KitchenGame(onCompanionTap: () {}),
    (game) async {
      final backBefore = game.kitchenRoom.backLayer.position.clone();
      game.handleDragForTest(Vector2(10, 0));
      game.update(0);

      expect(game.kitchenRoom.backLayer.position, isNot(backBefore));
    },
  );
}
